# Users

🇪🇸 [Versión en español](users.es.md)

NookMesh supports multiple users with individualized authentication, visibility, subscription, and operational behavior settings.

All identity configuration is defined in:

```text
config/users.json
```

This file acts as the primary source of configuration for:

- MQTT authentication
- ACL generation
- API token issuance
- visibility runtime model
- user lifecycle management
- subscription management
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
      "system_user": true,
      "mqtt_admin": true,
      "mqtt_password": "PASSWORD_RECORDER"
    },
    "sergio": {
      "status": "active",
      "created_at": "2026-01-01",
      "expires_on": null,
      "retain_credentials": true,
      "mqtt_admin": true,
      "mqtt_password": "PASSWORD_SERGIO",
      "regen_token": false,
      "grupos": ["friends", "family", "trip1", "trip2"],
      "oculto_para": [],
      "rol": "staff"
    },
    "sandra": {
      "status": "active",
      "created_at": "2026-01-01",
      "expires_on": "2027-01-01",
      "retain_credentials": true,
      "mqtt_password": "PASSWORD_SANDRA",
      "regen_token": false,
      "grupos": ["friends", "family"],
      "oculto_para": ["trip1"],
      "rol": "staff"
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
- receive extended MQTT permissions when required
- operate from multiple physical devices
- have an optional expiration date
- retain or remove credentials after expiration
- include optional logical metadata

This allows much more flexible visibility models than a simple global sharing scheme.

---

# File structure

## `_meta`

Descriptive information about the file.

Example:

```json
"_meta": {
  "description": "NookMesh user configuration",
  "managed_by": "nookmesh-auth"
}
```

Used solely for informational and traceability purposes.

It does not affect system behavior.

---

## `users`

Main container of configured identities.

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

# User lifecycle

NookMesh uses a state-based lifecycle model.

## `active`

Normal operational user.

Example:

```json
"status": "active"
```

The user:

- can authenticate via MQTT
- has active ACL permissions
- has an API token
- appears in the visibility runtime

---

## `disabled`

Manually suspended user.

Example:

```json
"status": "disabled"
```

The user:

- cannot publish locations
- is removed from the visibility runtime
- may optionally retain credentials

Typically used for:

- temporary suspensions
- maintenance
- operational incidents

---

## `expired`

Automatically expired user.

Example:

```json
"status": "expired"
```

The user:

- no longer participates in the system
- is removed from the visibility runtime
- may retain or remove credentials depending on configuration

This state is typically managed automatically by the subscription service.

---

# User fields

## `status`

User operational state.

Example:

```json
"status": "active"
```

Supported values:

```text
active
disabled
expired
```

---

## `created_at`

User creation date.

Example:

```json
"created_at": "2026-01-01"
```

Currently used for:

- informational purposes
- administration
- auditing

It does not affect system behavior.

---

## `expires_on`

User expiration date.

Example:

```json
"expires_on": "2027-01-01"
```

or

```json
"expires_on": null
```

If a valid date is present:

- the subscription service may automatically expire the user

If set to:

```json
null
```

the user has no expiration date.

---

## `retain_credentials`

Controls credential retention after expiration.

Example:

```json
"retain_credentials": true
```

Supported values:

```json
true
false
```

### `true`

Retains:

- MQTT password
- API token

This allows later reactivation without redistributing credentials.

### `false`

Removes:

- MQTT credentials
- API token

If the user is reactivated, new credentials must be generated.

---

## `mqtt_admin`

Grants extended MQTT administrative privileges.

Example:

```json
"mqtt_admin": true
```

This provides broad access to the MQTT tree:

```text
owntracks/#
```

Typical use cases:

- administrative accounts
- advanced debugging
- internal automation
- technical services

Not recommended for normal users unless strictly necessary.

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

this password is transformed into operational broker credentials:

```text
config/generated/mqtt-passwords.txt
```

Each user has independent authentication.

---

## `regen_token`

Controls API token regeneration.

Example:

```json
"regen_token": true
```

Behavior:

- if the user has no previous token → one is generated automatically
- if `regen_token=true` → token rotation is forced
- if `regen_token=false` → the existing token is preserved

After forced regeneration, the system automatically resets:

```json
"regen_token": false
```

---

## `grupos`

Defines user membership in one or more groups.

Example:

```json
"grupos": ["friends", "family", "trip1"]
```

Groups represent visibility and sharing domains.

Examples:

- family
- friends
- work
- trip1
- trip2
- hiking
- temporary-event

---

## `oculto_para`

Defines visibility exceptions.

Example:

```json
"oculto_para": ["trip1"]
```

Allows a user to hide from specific groups even if they belong to them.

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

- map styling
- additional rules
- future automation
- custom business logic

Optional.

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
- do not participate in visibility
- may operate with elevated privileges

---

# Multi-device support

A single logical identity can operate from multiple physical devices.

Example:

user:

```text
sergio
```

devices:

```text
iphone
pixel
xiaomi
iphone2
```

As long as each device uses a unique OwnTracks device identifier.

This allows sharing:

- MQTT credentials
- API token
- logical identity

Detailed behavior is documented in:

- [Multi-device](multi-device.md)

---

# Subscriptions and expiration

NookMesh can automatically manage user expiration through:

```text
nookmesh-subscriptions
```

This service:

- checks configured users daily
- compares the current date with `expires_on`
- automatically expires users when required

Example:

```json
{
  "status": "active",
  "expires_on": "2027-01-01"
}
```

After the specified date:

```json
{
  "status": "expired"
}
```

To reactivate a user:

```json
{
  "status": "active",
  "expires_on": null
}
```

The next execution will keep the user operational again.

Detailed documentation can be found in:

```text
subscriptions/INDEX.md
```

---

# Best practices

## Separate real users from internal accounts

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

unless genuinely required.

---

## Use expiration dates for temporary access

Ideal for:

- trips
- events
- guest users
- temporary testing
- seasonal groups

---

## Keep naming consistent

Prefer:

```text
sergio
sandra
raul
```

instead of:

```text
test
user1
abc
```

---

## Use meaningful groups

Prefer:

```text
family
friends
work
alps-trip
```

instead of:

```text
group1
misc
tmp
```

---

# Security

This file contains sensitive information.

It should:

- remain private
- never be committed to the repository
- always be generated from secure templates

The public repository should only include:

```text
users.example.json
```

---

# Relationship with other components

This file directly influences:

- MQTT authentication
- MQTT ACLs
- API tokens
- visibility runtime
- subscription service
- internal automation

---

# Next step

Continue with:

- [Visibility](visibility.md)
- [Multi-device](multi-device.md)
- [MQTT](mqtt.md)
- [Authentication Generator](auth-generator.md)