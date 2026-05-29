# Authentication and Runtime Generator

🇪🇸 [Versión en español](auth-generator.es.md)

NookMesh uses an automated generator to build credentials, MQTT permissions, and internal runtime state from the declarative user configuration.

Main script:

```text
auth/generate.sh
```

This script is a core component of the architecture.

It allows:

```text
config/users.json
```

to act as the single source of truth for:

- MQTT authentication
- MQTT permissions
- API tokens
- runtime visibility
- user lifecycle management
- subscription management
- internal system accounts

---

## Purpose

The generator automates:

- creation of the Mosquitto-compatible MQTT password database
- automatic MQTT ACL generation
- API token creation and maintenance
- selective token rotation
- automatic expiration processing
- user lifecycle management
- optional credential retention
- visibility runtime generation
- automatic deployment of generated files
- automatic restart of active services

This eliminates manual editing of sensitive files and reduces operational errors.

---

## Source of Truth

All declarative configuration originates from:

```text
config/users.json
```

The complete user model is documented in:

- [Users](users.md)

Based on that definition, NookMesh automatically generates the real operational state.

---

# Generated Files

## MQTT Password Database

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

Passwords are not stored in plain text inside the generated file.

The file is also visually organized into categories:

```text
SYSTEM USERS
ACTIVE USERS
DISABLED USERS
EXPIRED USERS
```

to simplify administration and auditing.

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

ACLs are also visually grouped by category:

```text
SYSTEM USERS
ACTIVE USERS
DISABLED USERS
EXPIRED USERS
```

---

## API Tokens

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

Each active human user receives its own token.

Users marked as:

```json
"system_user": true
```

do not receive API tokens.

The file is also organized into operational groups:

```text
ACTIVE USERS
DISABLED USERS
EXPIRED USERS
```

---

## Runtime Visibility

Generated at:

```text
data/runtime/visibility.json
```

Contains a processed representation of the visibility model.

It only includes:

- users with `status="active"`
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

This file is used internally by the API to resolve visibility permissions.

---

# Overall Flow

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

# Automatic Expiration Processing

Before generating credentials and permissions, the script automatically evaluates configured expiration dates.

Example:

```json
{
  "status": "active",
  "expires_on": "2027-01-01"
}
```

If the current date exceeds:

```text
2027-01-01
```

the system automatically updates the user to:

```json
{
  "status": "expired"
}
```

during the next execution.

This ensures expired users automatically stop participating in the system without manual intervention.

---

# MQTT Generation

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

Permissions are automatically generated according to user type.

### Standard User

Example:

```text
user sergio
topic read owntracks/sergio/#
topic write owntracks/sergio/#
```

Can only operate inside its own MQTT namespace.

---

### Elevated Privilege User

If:

```json
"mqtt_admin": true
```

result:

```text
topic read owntracks/#
topic write owntracks/<user>/#
```

Allows global MQTT activity inspection while keeping write access restricted to the user's own namespace.

---

### Internal System User

Example:

```json
"system_user": true
```

typical case:

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
- excluded from visibility
- no MQTT write permissions
- used for internal component communication

---

# Credential Retention

Users may retain or remove credentials when they become inactive.

Field:

```json
"retain_credentials": true
```

---

## Retention Enabled

If:

```json
"retain_credentials": true
```

the user keeps:

- MQTT password
- API token

even after transitioning to:

```json
"status": "expired"
```

or:

```json
"status": "disabled"
```

This allows later reactivation without redistributing credentials.

---

## Retention Disabled

If:

```json
"retain_credentials": false
```

the system automatically removes:

- MQTT credentials
- API token

when the user is no longer active.

Reactivation will require new credentials.

---

# API Token Generation

## Initial Creation

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

its token is preserved.

This avoids breaking already-configured clients.

Example:

Guru Maps continues working after unrelated changes.

---

## Selective Regeneration

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

the user receives a new token.

---

## Automatic Reset

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

## Deleted Users

If a user is completely removed from:

```text
config/users.json
```

its credentials are automatically removed from the system.

---

## Expired Users

If a user becomes:

```json
"status": "expired"
```

behavior depends on:

```json
"retain_credentials"
```

allowing credentials to be preserved or removed according to the selected policy.

---

# Visibility Runtime

The script generates:

```text
data/runtime/visibility.json
```

from:

- groups
- visibility exclusions
- roles

Only includes users that are:

- active
- not marked as `system_user`

This decouples declarative configuration from operational runtime.

---

# Execution Modes

## MQTT Already Running

If it detects:

```text
nookmesh-mqtt
```

it uses fast mode.

Process:

- copies temporary data into the container
- executes `mosquitto_passwd` inside the container
- retrieves the generated result

Advantages:

- faster
- reuses existing environment
- avoids helper containers

---

## Bootstrap Helper

If MQTT is not yet running:

the script temporarily creates:

```text
nookmesh-auth-helper
```

using:

```text
eclipse-mosquitto:latest
```

to execute:

```text
mosquitto_passwd
```

This allows credentials to be generated even before the first deployment.

Especially useful during initial installation.

---

# Automatic Restart

After deploying generated files, the script detects active services and automatically restarts those currently running.

Supported services:

```text
nookmesh-mqtt
nookmesh-recorder
nookmesh-worker
nookmesh-api
```

This guarantees immediate application of changes.

---

# Subscription Integration

The service:

```text
nookmesh-subscriptions
```

periodically executes:

```bash
./auth/generate.sh
```

to apply:

- automatic expirations
- manual reactivations
- status changes
- credential updates

Service activation is controlled through:

```env
ENABLE_SUBSCRIPTIONS=true
```

---

# Dependencies

Required:

```text
docker
jq
openssl
```

If any dependency is missing:

the script aborts.

---

# When to Run It

Execute:

```bash
./auth/generate.sh
```

whenever you modify:

### Users

```text
config/users.json
```

---

### User Status

```json
status
expires_on
retain_credentials
```

---

### MQTT Passwords

```json
mqtt_password
```

---

### MQTT Privileges

```json
mqtt_admin
```

---

### Visibility Model

```json
grupos
oculto_para
rol
```

---

### Token Rotation

```json
regen_token
```

---

# Files You Should NOT Edit Manually

Do not edit:

```text
config/generated/mqtt-passwords.txt
config/generated/mqtt-acl.txt
config/generated/api-tokens.txt
data/runtime/visibility.json
```

These files are regenerated automatically.

Always edit:

```text
config/users.json
```

---

# Security

Recommended practices:

- do not version sensitive generated files
- protect `users.json`
- do not share API tokens
- rotate tokens if compromise is suspected
- use TLS in production

---

# Troubleshooting

## I Changed users.json and Nothing Happens

Run:

```bash
./auth/generate.sh
```

---

## Token Does Not Change

Verify:

```json
"regen_token": true
```

---

## MQTT Authentication Fails

Check:

- `mqtt_password`
- successful execution of `generate.sh`
- broker restart

---

## Deleted User Still Works

Run:

```bash
./auth/generate.sh
```

---

## User Does Not Become Active Again

Verify:

```json
{
  "status": "active",
  "expires_on": null
}
```

and run:

```bash
./auth/generate.sh
```
