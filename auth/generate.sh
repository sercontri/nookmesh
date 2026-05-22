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

# ------------------------------------------------------------
# visibility.json
# Excludes system users
# ------------------------------------------------------------
jq '
.users
| to_entries
| map(select(
    .value.enabled == true
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
# USER | MQTT_PASS | MQTT_ADMIN | SYSTEM_USER | REGEN_TOKEN
# ------------------------------------------------------------
jq -r '
.users
| to_entries
| map(select(.value.enabled == true))
| sort_by(.key)
| map([
    .key,
    .value.mqtt_password,
    (.value.mqtt_admin // false),
    (.value.system_user // false),
    (.value.regen_token // false)
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

    while IFS=$(printf "\t") read -r USER MQTT_PASS MQTT_ADMIN SYSTEM_USER REGEN_TOKEN; do
      echo "Adding password for user $USER"
      mosquitto_passwd -b /tmp/mqtt-passwords.txt "$USER" "$MQTT_PASS" >/dev/null 2>&1
    done < /tmp/users.tsv
  '

  docker cp nookmesh-mqtt:/tmp/mqtt-passwords.txt "$MQTT_PASS" >/dev/null

else

  docker run --rm \
    --name nookmesh-auth-helper \
    -v "$TMP_DIR:/work" \
    eclipse-mosquitto:latest \
    sh -c '
      touch /work/mqtt-passwords.txt
      chmod 600 /work/mqtt-passwords.txt

      while IFS=$(printf "\t") read -r USER MQTT_PASS MQTT_ADMIN SYSTEM_USER REGEN_TOKEN; do
        echo "Adding password for user $USER"
        mosquitto_passwd -b /work/mqtt-passwords.txt "$USER" "$MQTT_PASS" >/dev/null 2>&1
      done < /work/users.tsv
    '

fi

# ------------------------------------------------------------
# Generate API tokens + ACL
# ------------------------------------------------------------
while IFS=$'\t' read -r USER MQTT_PASS_VALUE MQTT_ADMIN SYSTEM_USER REGEN_TOKEN; do

  if [ "$SYSTEM_USER" != "true" ]; then

    EXISTING_TOKEN="$(grep "^$USER:" "$TOKENS_DB" | cut -d: -f2- || true)"

    if [ "$REGEN_TOKEN" = "true" ] || [ -z "$EXISTING_TOKEN" ]; then
      API_TOKEN="$(openssl rand -hex 24)"
      echo "Generating new API token for $USER"
    else
      API_TOKEN="$EXISTING_TOKEN"
    fi

    echo "$USER:$API_TOKEN" >> "$API_TOKENS"
  fi

  echo "user $USER" >> "$MQTT_ACL"

  if [ "$MQTT_ADMIN" = "true" ]; then
    echo "topic read owntracks/#" >> "$MQTT_ACL"
  else
    echo "topic read owntracks/$USER/#" >> "$MQTT_ACL"
  fi

  if [ "$SYSTEM_USER" != "true" ]; then
    echo "topic write owntracks/$USER/#" >> "$MQTT_ACL"
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

echo "== Deployment completed =="

# ------------------------------------------------------------
# Restart running services
# ------------------------------------------------------------
if docker ps --format '{{.Names}}' | grep -q '^nookmesh-mqtt$'; then
  echo "== Restarting MQTT =="
  docker restart nookmesh-mqtt >/dev/null
fi

if docker ps --format '{{.Names}}' | grep -q '^nookmesh-recorder$'; then
  docker restart nookmesh-recorder >/dev/null
fi

if docker ps --format '{{.Names}}' | grep -q '^nookmesh-worker$'; then
  docker restart nookmesh-worker >/dev/null
fi

if docker ps --format '{{.Names}}' | grep -q '^nookmesh-api$'; then
  docker restart nookmesh-api >/dev/null
fi

# ------------------------------------------------------------
# Cleanup
# ------------------------------------------------------------
rm -rf "$TMP_DIR"

echo "== Done =="