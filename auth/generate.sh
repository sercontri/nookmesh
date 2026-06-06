#!/bin/bash
set -e

# ------------------------------------------------------------
# NookMesh Auth Generator
# Generates auth/runtime files from config/users.json
# Hybrid mode:
# - If MQTT is running -> fast docker exec (single batch)
# - If MQTT is absent  -> bootstrap helper container
# ------------------------------------------------------------

# ------------------------------------------------------------
# Dependency checks
# ------------------------------------------------------------
if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker is required but not installed."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required but not installed."
  exit 1
fi

if ! command -v openssl >/dev/null 2>&1; then
  echo "ERROR: openssl is required but not installed."
  exit 1
fi

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

CONFIG_DIR="$BASE_DIR/config"
GENERATED_DIR="$CONFIG_DIR/generated"
RUNTIME_DIR="$BASE_DIR/data/runtime"

USERS_JSON="$CONFIG_DIR/users.json"
EXISTING_TOKENS="$GENERATED_DIR/api-tokens.txt"

TMP_DIR="$(mktemp -d)"

API_TOKENS="$TMP_DIR/api-tokens.txt"
MQTT_PASS="$TMP_DIR/mqtt-passwords.txt"
MQTT_ACL="$TMP_DIR/mqtt-acl.txt"
VISIBILITY_JSON="$TMP_DIR/visibility.json"
USERS_TSV="$TMP_DIR/users.tsv"
TOKENS_DB="$TMP_DIR/existing_tokens.tsv"

mkdir -p "$GENERATED_DIR"
mkdir -p "$RUNTIME_DIR"

echo "== Generating files from users.json =="

# ------------------------------------------------------------
# Automatic expiration processing
# ------------------------------------------------------------
echo "== Processing user expirations =="

TODAY="$(date +%F)"

jq --arg TODAY "$TODAY" '
.users |= with_entries(

  if (
    (.value.system_user // false | not)
    and (.value.status != "disabled")
    and (.value.expires_on == null)
  )

  then
    .value.status = "active"

  elif (
    (.value.system_user // false | not)
    and (.value.status == "active")
    and (.value.expires_on != null)
    and (.value.expires_on < $TODAY)
  )

  then
    .value.status = "expired"

  else
    .
  end
)
' "$USERS_JSON" > "$TMP_DIR/users_expiration.json"

mv "$TMP_DIR/users_expiration.json" "$USERS_JSON"

# ------------------------------------------------------------
# Temp files
# ------------------------------------------------------------
touch "$API_TOKENS"
touch "$MQTT_PASS"
touch "$MQTT_ACL"
touch "$VISIBILITY_JSON"
touch "$TOKENS_DB"

chmod 600 "$MQTT_PASS"

# ------------------------------------------------------------
# Load existing tokens
# ------------------------------------------------------------
if [ -f "$EXISTING_TOKENS" ]; then
  grep -v '^#' "$EXISTING_TOKENS" | grep ':' > "$TOKENS_DB" || true
fi

# ------------------------------------------------------------
# Detect MQTT mode
# ------------------------------------------------------------
USE_RUNNING_MQTT=false

if docker ps --format '{{.Names}}' | grep -q '^nookmesh-mqtt$'; then
  USE_RUNNING_MQTT=true
  echo "== Using running MQTT container =="
else
  echo "== MQTT not running, using bootstrap helper =="
fi

# ------------------------------------------------------------
# Headers
# ------------------------------------------------------------
cat <<EOF > "$MQTT_ACL"
# ------------------------------------------------------------
# NookMesh MQTT ACL
# Generated automatically from config/users.json
# DO NOT EDIT MANUALLY
# ------------------------------------------------------------

EOF

cat <<EOF > "$API_TOKENS"
# ------------------------------------------------------------
# NookMesh API tokens
# Generated automatically from config/users.json
# DO NOT EDIT MANUALLY
# ------------------------------------------------------------

EOF

cat <<EOF > "$MQTT_PASS"
# ------------------------------------------------------------
# NookMesh MQTT passwords
# Generated automatically from config/users.json
# DO NOT EDIT MANUALLY
# ------------------------------------------------------------

EOF

# ------------------------------------------------------------
# visibility.json
# Only active non-system users
# ------------------------------------------------------------
jq '
.users
| to_entries
| map(select(
    .value.status == "active"
    and (.value.system_user // false | not)
))
| sort_by(.key)
| map({
    key: .key,
    value: (
      {
        grupos: .value.grupos
      }
      + (
          if (
            .value.oculto_para
            and (.value.oculto_para | length > 0)
          )
          then { oculto_para: .value.oculto_para }
          else {}
          end
        )
      + (
          if .value.rol
          then { rol: .value.rol }
          else {}
          end
        )
    )
  })
| from_entries
' "$USERS_JSON" | jq -S . > "$VISIBILITY_JSON"

# ------------------------------------------------------------
# Prepare user list
# ORDER:
# 1. SYSTEM USERS
# 2. ACTIVE
# 3. DISABLED
# 4. EXPIRED
# ------------------------------------------------------------
jq -r '
.users
| to_entries
| sort_by(
    if (.value.system_user // false) then 0
    elif .value.status == "active" then 1
    elif .value.status == "disabled" then 2
    else 3
    end,
    .key
)
| map([
    .key,
    .value.mqtt_password,
    (.value.status // "active"),
    (.value.mqtt_admin // false),
    (.value.system_user // false),
    (.value.regen_token // false),
    (.value.retain_credentials // true)
  ])
| .[]
| @tsv
' "$USERS_JSON" > "$USERS_TSV"

# ------------------------------------------------------------
# Generate MQTT password file
# ------------------------------------------------------------
if [ "$USE_RUNNING_MQTT" = true ]; then

  docker cp "$USERS_TSV" nookmesh-mqtt:/tmp/users.tsv >/dev/null

  docker exec nookmesh-mqtt sh -c '
    rm -f /tmp/mqtt-passwords.txt
    touch /tmp/mqtt-passwords.txt
    chmod 600 /tmp/mqtt-passwords.txt

    while IFS=$(printf "\t") read -r USER MQTT_PASS STATUS MQTT_ADMIN SYSTEM_USER REGEN_TOKEN RETAIN_CREDENTIALS; do

      if [ "$STATUS" = "expired" ] || [ "$STATUS" = "disabled" ]; then
        if [ "$RETAIN_CREDENTIALS" != "true" ]; then
          echo "Skipping MQTT credentials for user $USER"
          continue
        fi
      fi

      echo "Adding password for user $USER"

      mosquitto_passwd -b /tmp/mqtt-passwords.txt "$USER" "$MQTT_PASS" >/dev/null 2>&1

    done < /tmp/users.tsv
  '

  docker cp nookmesh-mqtt:/tmp/mqtt-passwords.txt "$MQTT_PASS.raw" >/dev/null

else

  docker run --rm \
    --name nookmesh-auth-helper \
    -v "$TMP_DIR:/work" \
    eclipse-mosquitto:latest \
    sh -c '
      touch /work/mqtt-passwords.txt
      chmod 600 /work/mqtt-passwords.txt

      while IFS=$(printf "\t") read -r USER MQTT_PASS STATUS MQTT_ADMIN SYSTEM_USER REGEN_TOKEN RETAIN_CREDENTIALS; do

        if [ "$STATUS" = "expired" ] || [ "$STATUS" = "disabled" ]; then
          if [ "$RETAIN_CREDENTIALS" != "true" ]; then
            echo "Skipping MQTT credentials for user $USER"
            continue
          fi
        fi

        echo "Adding password for user $USER"

        mosquitto_passwd -b /work/mqtt-passwords.txt "$USER" "$MQTT_PASS" >/dev/null 2>&1

      done < /work/users.tsv
    '

  cp "$TMP_DIR/mqtt-passwords.txt" "$MQTT_PASS.raw"

fi

# ------------------------------------------------------------
# Rebuild MQTT passwords with visual sections
# ------------------------------------------------------------
LAST_SECTION=""

while IFS=$'\t' read -r USER MQTT_PASS_VALUE STATUS MQTT_ADMIN SYSTEM_USER REGEN_TOKEN RETAIN_CREDENTIALS; do

  if [ "$STATUS" = "expired" ] || [ "$STATUS" = "disabled" ]; then
    if [ "$RETAIN_CREDENTIALS" != "true" ]; then
      continue
    fi
  fi

  if [ "$SYSTEM_USER" = "true" ]; then
    SECTION="SYSTEM USERS"
  elif [ "$STATUS" = "active" ]; then
    SECTION="ACTIVE USERS"
  elif [ "$STATUS" = "disabled" ]; then
    SECTION="DISABLED USERS"
  else
    SECTION="EXPIRED USERS"
  fi

  if [ "$SECTION" != "$LAST_SECTION" ]; then
    echo "" >> "$MQTT_PASS"
    echo "# $SECTION" >> "$MQTT_PASS"
    echo "" >> "$MQTT_PASS"
    LAST_SECTION="$SECTION"
  fi

  grep "^$USER:" "$MQTT_PASS.raw" >> "$MQTT_PASS"

done < "$USERS_TSV"

# ------------------------------------------------------------
# Generate API tokens + ACL
# ------------------------------------------------------------
LAST_SECTION=""

while IFS=$'\t' read -r USER MQTT_PASS_VALUE STATUS MQTT_ADMIN SYSTEM_USER REGEN_TOKEN RETAIN_CREDENTIALS; do

  if [ "$SYSTEM_USER" = "true" ]; then
    SECTION="SYSTEM USERS"
  elif [ "$STATUS" = "active" ]; then
    SECTION="ACTIVE USERS"
  elif [ "$STATUS" = "disabled" ]; then
    SECTION="DISABLED USERS"
  else
    SECTION="EXPIRED USERS"
  fi

  # ----------------------------------------------------------
  # Section headers
  # ----------------------------------------------------------
  if [ "$SECTION" != "$LAST_SECTION" ]; then

    echo "" >> "$MQTT_ACL"
    echo "# $SECTION" >> "$MQTT_ACL"
    echo "" >> "$MQTT_ACL"

    if [ "$SECTION" != "SYSTEM USERS" ]; then
      echo "" >> "$API_TOKENS"
      echo "# $SECTION" >> "$API_TOKENS"
      echo "" >> "$API_TOKENS"
    fi

    LAST_SECTION="$SECTION"
  fi

  # ----------------------------------------------------------
  # API Tokens
  # ----------------------------------------------------------
  if [ "$SYSTEM_USER" != "true" ]; then

    if [ "$STATUS" = "expired" ] || [ "$STATUS" = "disabled" ]; then
      if [ "$RETAIN_CREDENTIALS" != "true" ]; then
        echo "Skipping API token for user $USER"
        continue
      fi
    fi

    EXISTING_TOKEN="$(grep "^$USER:" "$TOKENS_DB" | cut -d: -f2- || true)"

    if [ "$REGEN_TOKEN" = "true" ] || [ -z "$EXISTING_TOKEN" ]; then
      API_TOKEN="$(openssl rand -hex 24)"
      echo "Generating new API token for $USER"
    else
      API_TOKEN="$EXISTING_TOKEN"
    fi

    echo "$USER:$API_TOKEN" >> "$API_TOKENS"

  fi

  # ----------------------------------------------------------
  # MQTT ACL
  # ----------------------------------------------------------
  echo "user $USER" >> "$MQTT_ACL"

  if [ "$STATUS" = "active" ] || [ "$SYSTEM_USER" = "true" ]; then

    if [ "$MQTT_ADMIN" = "true" ]; then
      echo "topic read owntracks/#" >> "$MQTT_ACL"
    else
      echo "topic read owntracks/$USER/#" >> "$MQTT_ACL"
    fi

    if [ "$SYSTEM_USER" != "true" ]; then
      echo "topic write owntracks/$USER/#" >> "$MQTT_ACL"
    fi

  fi

  echo "" >> "$MQTT_ACL"

done < "$USERS_TSV"

# ------------------------------------------------------------
# Reset regen_token flags
# ------------------------------------------------------------
jq '
.users |= with_entries(
  if .value.regen_token == true
  then .value.regen_token = false
  else .
  end
)
' "$USERS_JSON" > "$TMP_DIR/users.json"

mv "$TMP_DIR/users.json" "$USERS_JSON"

# ------------------------------------------------------------
# Deploy generated files
# ------------------------------------------------------------
echo "== Deploying generated files =="

cp -f "$API_TOKENS" "$GENERATED_DIR/api-tokens.txt"
cp -f "$MQTT_PASS" "$GENERATED_DIR/mqtt-passwords.txt"
cp -f "$MQTT_ACL" "$GENERATED_DIR/mqtt-acl.txt"
cp -f "$VISIBILITY_JSON" "$RUNTIME_DIR/visibility.json"

chmod 644 "$GENERATED_DIR/mqtt-passwords.txt"
chmod 644 "$GENERATED_DIR/mqtt-acl.txt"
chmod 600 "$GENERATED_DIR/api-tokens.txt"

rm -f "$GENERATED_DIR/api-password.txt"
rm -f "$MQTT_PASS.raw"

echo "== Deployment completed =="

# ------------------------------------------------------------
# Restart running services
# ------------------------------------------------------------
if docker ps --format '{{.Names}}' | grep -q '^nookmesh-mqtt$'; then
  echo "== Restarting MQTT =="
  docker restart nookmesh-mqtt >/dev/null
fi

if docker ps --format '{{.Names}}' | grep -q '^nookmesh-recorder$'; then
  echo "== Restarting Recorder =="
  docker restart nookmesh-recorder >/dev/null
fi

if docker ps --format '{{.Names}}' | grep -q '^nookmesh-worker$'; then
  echo "== Restarting Worker =="
  docker restart nookmesh-worker >/dev/null
fi

if docker ps --format '{{.Names}}' | grep -q '^nookmesh-api$'; then
  echo "== Restarting API =="
  docker restart nookmesh-api >/dev/null
fi

# ------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------
rm -rf "$TMP_DIR"

echo "== Done =="