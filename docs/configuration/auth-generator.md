# Authentication and Runtime Generator

🇪🇸 [Versión en español](auth-generator.es.md)

NookMesh uses an automated generator to build credentials, MQTT permissions, and internal runtime state from the declarative user configuration.

Main script:

```text
auth/generate.sh
```

This script is a central part of the architecture.

It allows:

```text
config/users.json
```

to act as the single source of truth for:

- MQTT authentication
- MQTT permissions
- API tokens
- runtime visibility
- internal system accounts

---

## Purpose

The generator automates:

- creation of the Mosquitto-compatible MQTT password database
- automatic MQTT ACL generation
- API token creation and maintenance
- selective token regeneration
- automatic removal of deleted user tokens
- visibility runtime generation
- automatic deployment of generated files
- automatic restart of active services

This avoids manually editing sensitive files and reduces operational errors.

---

## Source of truth

All declarative configuration starts from:

```text
config/users.json
```

The complete user model is documented in:

- [Users](users.md)

From that definition, NookMesh automatically generates the actual operational state.

---

# Generated files

🇪🇸 [Versión en español](auth-generator.es.md)

## MQTT password database

Generated at:

```text
config/generated/mqtt-passwords.txt
```

Contains the format required by Mosquitto.

Passwords declared in:

```text
config/users.json
```

are transformed using:

```text
mosquitto_passwd
```

They are not stored as plain text inside the generated file.

---

## MQTT ACL

Generated at:

```text
config/generated/mqtt-acl.txt
```

Defines automatic MQTT permissions per user.

Standard user example:

```text
user sergio
topic read owntracks/sergio/#
topic write owntracks/sergio/#
```

Example with:

```json
"mqtt_admin": true
```

result:

```text
user sergio
topic read owntracks/#
topic write owntracks/sergio/#
```

This grants:

- global read access to the OwnTracks MQTT tree
- write access only within the user's own namespace

---

## API tokens

Generated at:

```text
config/generated/api-tokens.txt
```

Format:

```text
user:token
```

Example:

```text
sergio:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
sandra:yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
```

Each enabled human user receives their own token.

Users marked as:

```json
"system_user": true
```

do not receive a token.

---

## Runtime visibility

Generated at:

```text
data/runtime/visibility.json
```

Contains a processed representation of the visibility model.

Only includes:

- enabled users
- users not marked as `system_user`

Possible fields:

- `grupos`
- `oculto_para`
- `rol`

Example:

```json
{
  "sergio": {
    "grupos": ["family", "friends"],
    "rol": "staff"
  },
  "sandra": {
    "grupos": ["family", "trip1"],
    "oculto_para": ["trip1"]
  }
}
```

This file is used internally by the API to resolve visualization permissions.

---

# General flow

🇪🇸 [Versión en español](auth-generator.es.md)

```text
config/users.json
        ↓
auth/generate.sh
        ↓
mqtt-passwords.txt
mqtt-acl.txt
api-tokens.txt
visibility.json
        ↓
deployment
        ↓
runtime reload
```

---

# MQTT generation

🇪🇸 [Versión en español](auth-generator.es.md)

## Passwords

Source field:

```json
"mqtt_password"
```

Example:

```json
"mqtt_password": "PASSWORD_SERGIO"
```

During generation:

- processed with `mosquitto_passwd`
- added to the MQTT password database

Result:

```text
config/generated/mqtt-passwords.txt
```

---

## Automatic ACLs

Permissions are generated automatically based on user type.

### Standard user

Example:

```text
user sergio
topic read owntracks/sergio/#
topic write owntracks/sergio/#
```

Can only operate within their own MQTT namespace.

---

### User with elevated privileges

If:

```json
"mqtt_admin": true
```

result:

```text
topic read owntracks/#
topic write owntracks/<user>/#
```

Allows global MQTT visibility while keeping write access restricted to the user's own namespace.

---

### Internal system user

Example:

```json
"system_user": true
```

Typical case:

```text
recorder
```

Result:

```text
user recorder
topic read owntracks/#
```

Characteristics:

- no API token
- excluded from visibility logic
- no MQTT write permissions
- internal component use only

---

# API token generation

🇪🇸 [Versión en español](auth-generator.es.md)

## First creation

If the user does not exist in:

```text
config/generated/api-tokens.txt
```

a new token is automatically generated using:

```bash
openssl rand -hex 24
```

Result:

48-character hexadecimal token.

---

## Persistence

If the user already exists:

their token is preserved.

This avoids breaking already configured clients.

Example:

Guru Maps will continue working after unrelated configuration changes.

---

## Selective regeneration

If:

```json
"regen_token": true
```

the token is automatically replaced.

Example:

```json
"sergio": {
  "regen_token": true
}
```

After running:

```bash
./auth/generate.sh
```

the user will receive a new token.

---

## Automatic reset

After regeneration:

```json
"regen_token"
```

is automatically reset to:

```json
false
```

This prevents accidental repeated rotations.

---

## Deleted users

If a user disappears from:

```text
config/users.json
```

their token is automatically removed from the generated file.

No orphaned credentials remain.

---

# Visibility runtime

🇪🇸 [Versión en español](auth-generator.es.md)

The script generates:

```text
data/runtime/visibility.json
```

from:

- groups
- exclusions
- roles

Only includes users that are:

- enabled
- not marked as `system_user`

This decouples declarative configuration from operational runtime.

---

# Execution modes

🇪🇸 [Versión en español](auth-generator.es.md)

## MQTT already running

If the script detects:

```text
nookmesh-mqtt
```

it uses fast mode.

Process:

- copies temporary data into the container
- runs `mosquitto_passwd` inside the container
- retrieves the generated result

Advantages:

- faster
- reuses existing environment
- avoids helper containers

---

## Bootstrap helper

If MQTT is not yet running:

the script temporarily creates:

```text
nookmesh-auth-helper
```

using:

```text
eclipse-mosquitto:latest
```

to run:

```text
mosquitto_passwd
```

This allows credential generation even before the first deployment.

Especially useful during initial installation.

---

# Automatic restart

🇪🇸 [Versión en español](auth-generator.es.md)

After deploying generated files, the script detects active services and automatically restarts those currently running.

Supported services:

```text
nookmesh-mqtt
nookmesh-recorder
nookmesh-worker
nookmesh-api
```

This ensures changes are applied immediately.

---

# Dependencies

🇪🇸 [Versión en español](auth-generator.es.md)

Required:

```text
docker
jq
openssl
```

If any dependency is missing:

the script aborts.

---

# When to run it

🇪🇸 [Versión en español](auth-generator.es.md)

Run:

```bash
./auth/generate.sh
```

whenever you change:

### Users

```text
config/users.json
```

---

### MQTT passwords

```json
mqtt_password
```

---

### MQTT privileges

```json
mqtt_admin
```

---

### Visibility model

```json
grupos
oculto_para
rol
```

---

### Token rotation

```json
regen_token
```

---

# Files you should NOT edit manually

🇪🇸 [Versión en español](auth-generator.es.md)

Do not edit:

```text
config/generated/mqtt-passwords.txt
config/generated/mqtt-acl.txt
config/generated/api-tokens.txt
data/runtime/visibility.json
```

They are regenerated automatically.

Always edit:

```text
config/users.json
```

---

# Security

🇪🇸 [Versión en español](auth-generator.es.md)

Best practices:

- do not version sensitive generated files
- protect `users.json`
- do not share API tokens
- regenerate tokens if compromise is suspected
- use TLS in production

---

# Troubleshooting

🇪🇸 [Versión en español](auth-generator.es.md)

## I changed users.json and nothing happens

Run:

```bash
./auth/generate.sh
```

---

## Token does not change

Verify:

```json
"regen_token": true
```

---

## MQTT rejects authentication

Check:

- `mqtt_password`
- successful `generate.sh` execution
- broker restart

---

## Deleted user still works

Run:

```bash
./auth/generate.sh
```