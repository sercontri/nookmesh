# Users

🇪🇸 [Versión en español](users.es.md)

NookMesh allows management of multiple users with individualized authentication, visibility, and operational behavior settings.

All primary identity configuration is defined in:

```text
config/users.json
```

This file acts as the primary configuration source for:

- MQTT authentication
- ACL generation
- API token issuance
- runtime visibility model
- internal system accounts

---

## General structure

Official example:

```json
{
  "_meta": {
    "description": "NookMesh user configuration",
    "managed_by": "nookmesh-auth"
  },
  "users": {
    "recorder": {
      "enabled": true,
      "mqtt_admin": true,
      "mqtt_password": "PASSWORD_RECORDER",
      "system_user": true
    },
    "sergio": {
      "enabled": true,
      "mqtt_admin": true,
      "mqtt_password": "PASSWORD_SERGIO",
      "regen_token": false,
      "grupos": ["amigos", "familia", "viaje1", "viaje2", "trabajo"],
      "oculto_para": [],
      "rol": "staff"
    },
    "sandra": {
      "enabled": true,
      "mqtt_password": "PASSWORD_SANDRA",
      "regen_token": false,
      "grupos": ["amigos", "familia", "viaje1", "viaje2"],
      "oculto_para": ["viaje1", "viaje2"],
      "rol": "staff"
    },
    "raul": {
      "enabled": true,
      "mqtt_password": "PASSWORD_RAUL",
      "regen_token": false,
      "grupos": ["amigos", "viaje1"],
      "oculto_para": []
    }
  }
}
```

---

## Model philosophy

Each user can:

- authenticate individually via MQTT
- receive their own API token
- belong to multiple groups
- selectively hide from specific groups
- have elevated MQTT privileges if needed
- operate from multiple physical devices
- include optional logical metadata

This allows building visibility models far more flexible than a simple global sharing scheme.

---

# File structure

🇪🇸 [Versión en español](users.es.md)

## `_meta`

Descriptive file metadata.

Example:

```json
"_meta": {
  "description": "NookMesh user configuration",
  "managed_by": "nookmesh-auth"
}
```

Used only for informational and traceability purposes.

It does not affect system behavior.

---

## `users`

Primary container for configured identities.

Example:

```json
"users": {
  ...
}
```

Each key represents a unique logical identity.

Examples:

```text
sergio
sandra
raul
recorder
```

---

# User fields

🇪🇸 [Versión en español](users.es.md)

## `enabled`

Enables or disables the user.

Example:

```json
"enabled": true
```

If a user is disabled:

- MQTT credentials are not generated
- no API token is issued
- the user is excluded from visibility runtime
- associated automated processes ignore the user

---

## `mqtt_admin`

Grants elevated MQTT administrative privileges.

Example:

```json
"mqtt_admin": true
```

This allows broad access to the MQTT tree:

```text
owntracks/#
```

Including read and write access to system MQTT topics.

Typical use cases:

- administrative accounts
- advanced debugging
- internal automation
- technical services

Not recommended for normal users unless genuinely necessary.

---

## `mqtt_password`

User MQTT password.

Example:

```json
"mqtt_password": "PASSWORD_SERGIO"
```

During:

```bash
./auth/generate.sh
```

this password is transformed into broker-compatible operational credentials:

```text
config/generated/mqtt-passwords.txt
```

Each user has independent authentication.

This allows:

- isolation
- selective revocation
- granular access control

---

## `regen_token`

Controls API token regeneration for the user.

Example:

```json
"regen_token": true
```

Behavior:

- if the user has no existing token → one is created automatically
- if `regen_token=true` → token rotation is forced
- if `regen_token=false` → the existing token is preserved
- if a user is removed → the token is deleted
- if a new user is created → a token is automatically assigned

After forced regeneration, the system automatically resets:

```json
"regen_token": false
```

This allows controlled API credential rotation without affecting other users.

---

## `grupos`

Defines group membership.

Example:

```json
"grupos": ["amigos", "familia", "viaje1"]
```

Groups represent visibility and sharing scopes.

Examples:

- family
- friends
- work
- trip1
- trip2
- hiking
- temporary-event

A user may belong to multiple groups simultaneously.

---

## `oculto_para`

Defines visibility exceptions.

Example:

```json
"oculto_para": ["viaje1"]
```

This allows hiding a user from specific groups even if they belong to them.

Conceptual example:

- Sandra belongs to `amigos`, `familia`, `viaje1`
- but hides from `viaje1`

Result:

effective visibility depends on remaining shared groups and the active visibility model rules.

Detailed logic is documented in:

- [Visibility](visibility.md)

---

## `rol`

Optional logical classification.

Example:

```json
"rol": "staff"
```

Possible uses:

- visual differentiation on maps
- additional rules
- future automation
- custom business logic

Not required.

---

## `system_user`

Marks internal system users.

Example:

```json
"system_user": true
```

Typical case:

```json
"recorder"
```

These accounts:

- do not represent real people
- do not receive API tokens
- do not participate in user visibility
- may operate with special privileges

They are used for internal communication between components.

---

# Multi-device

🇪🇸 [Versión en español](users.es.md)

A single logical identity may operate from multiple physical devices.

Example:

User:

```text
sergio
```

Devices:

```text
iphone
pixel
xiaomi
iphone2
```

As long as each device uses a unique identifier in OwnTracks.

This allows reuse of:

- the same MQTT credentials
- the same API token
- the same logical identity

Detailed behavior is documented in:

- [Multi-device](multi-device.md)

---

# Best practices

🇪🇸 [Versión en español](users.es.md)

## Separate real users and internal accounts

Keep separate:

- real people
- internal technical services

Example:

```text
recorder
```

should remain a technical account.

---

## Limit `mqtt_admin`

Do not grant:

```json
"mqtt_admin": true
```

without real necessity.

It provides broad access to the MQTT system.

---

## Keep names consistent

Use clear and stable identities.

Better:

```text
sergio
sandra
raul
```

than:

```text
test
user1
abc
```

---

## Use meaningful groups

Better:

```text
family
friends
work
alps-trip
```

than:

```text
group1
misc
tmp
```

---

# Security

🇪🇸 [Versión en español](users.es.md)

This file contains sensitive information.

It should:

- remain private
- never be committed to the repository
- always be generated from safe templates

The public repository should only include:

```text
users.example.json
```

---

# Relationship with other components

🇪🇸 [Versión en español](users.es.md)

This file directly affects:

- MQTT authentication
- MQTT ACLs
- API tokens
- visibility runtime
- internal automation

---

# Next steps

🇪🇸 [Versión en español](users.es.md)

Continue with:

- [Visibility](visibility.md)
- [Multi-device](multi-device.md)
- [MQTT](mqtt.md)
- [Authentication generator](auth-generator.md)