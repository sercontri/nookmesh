# Subscription Service

🇪🇸 [Versión en español](subscriptions.es.md)

NookMesh includes an optional service responsible for automatically processing subscription lifecycles and user expirations.

This service automates user state transitions without relying on operating system schedulers or platform-specific mechanisms.

---

## Purpose

The subscription service is responsible for:

- detecting expired users
- automatically updating user states
- regenerating credentials when required
- updating MQTT ACLs
- updating API tokens
- updating runtime visibility data
- keeping dependent components synchronized

The logic is based on information defined in:

```text
config/users.json
```

---

# Architecture

The service runs as an independent container:

```text
nookmesh-subscriptions
```

This provides:

- operating system independence
- Synology compatibility
- standard Docker compatibility
- consistent deployment across environments

It does not require:

```text
cron
systemd
scheduled tasks
```

or any platform-specific scheduling mechanism.

---

# Configuration

Configuration is performed through:

```text
config/filtros.env
```

Associated parameter:

```env
ENABLE_SUBSCRIPTIONS=true
```

---

## ENABLE_SUBSCRIPTIONS=true

When enabled:

```env
ENABLE_SUBSCRIPTIONS=true
```

the service periodically executes:

```bash
./auth/generate.sh
```

to automatically apply required changes.

It processes:

- expirations
- status transitions
- runtime file regeneration
- credential synchronization

---

## ENABLE_SUBSCRIPTIONS=false

When disabled:

```env
ENABLE_SUBSCRIPTIONS=false
```

the container remains running but performs no actions.

The following will not be applied automatically:

- expirations
- status changes
- credential updates

Changes will only take effect through manual execution of:

```bash
./auth/generate.sh
```

---

## Restart Required

After modifying:

```env
ENABLE_SUBSCRIPTIONS
```

the container must be restarted:

```bash
docker restart nookmesh-subscriptions
```

The value is loaded during startup.

---

# User States

The service operates on the:

```json
"status"
```

field defined in:

```text
config/users.json
```

---

## active

Operational user.

Example:

```json
"status": "active"
```

Characteristics:

- MQTT credentials enabled
- API token enabled
- included in runtime visibility
- visible to other users according to configured rules

---

## disabled

Manually disabled user.

Example:

```json
"status": "disabled"
```

Characteristics:

- does not participate operationally
- cannot be automatically reactivated
- requires explicit administrator intervention

This state takes precedence over expiration dates.

---

## expired

Automatically expired user.

Example:

```json
"status": "expired"
```

Applied when:

```json
"expires_on"
```

contains a date earlier than the current date.

---

# Automatic Expiration Processing

Field used:

```json
"expires_on"
```

Example:

```json
"expires_on": "2026-12-31"
```

When the date is exceeded:

```text
expires_on < current_date
```

the user automatically transitions to:

```json
"status": "expired"
```

during the next service execution.

---

# Renewals

A subscription can be renewed by modifying:

```json
"expires_on"
```

to a future date or by removing the expiration date:

```json
"expires_on": null
```

During the next execution of:

```bash
./auth/generate.sh
```

the user automatically returns to:

```json
"status": "active"
```

provided the user is not marked as:

```json
"status": "disabled"
```

---

# Credential Retention

Field used:

```json
"retain_credentials"
```

Example:

```json
"retain_credentials": true
```

---

## true

Credentials are retained even after expiration.

The following remain available:

- MQTT access
- API token

Useful for:

- temporary renewals
- grace periods
- rapid access restoration

---

## false

Credentials are removed when the user is no longer active.

This implies:

- MQTT access removal
- API token removal
- complete operational removal

---

# Relationship With generate.sh

The service does not directly modify generated files.

All operational logic remains centralized in:

```text
auth/generate.sh
```

The container simply executes this process periodically.

This guarantees a single generation and maintenance source.

---

# Relationship With Other Components

## Users

Primary source:

```text
config/users.json
```

---

## Authentication Generator

Executed process:

```text
auth/generate.sh
```

---

## MQTT

Automatic updates of:

```text
mqtt-passwords.txt
mqtt-acl.txt
```

---

## API

Automatic updates of:

```text
api-tokens.txt
```

---

## Runtime

Automatic updates of:

```text
visibility.json
```

---

# Best Practices

## Use Expirations

Prefer expirations over temporarily removing users.

Example:

```json
"expires_on": "2026-12-31"
```

---

## Reserve disabled for Manual Blocks

Use:

```json
"status": "disabled"
```

only when automatic reactivation must be prevented.

---

## Configure retain_credentials According to Policy

For fast renewals:

```json
"retain_credentials": true
```

For complete revocation:

```json
"retain_credentials": false
```

---

# Troubleshooting

## User Does Not Expire

Verify:

```json
"expires_on"
```

and ensure:

```env
ENABLE_SUBSCRIPTIONS=true
```

---

## User Does Not Reactivate

Verify that:

```json
"status"
```

is not configured as:

```json
"disabled"
```

---

## Changes Are Not Applied

Execute:

```bash
docker restart nookmesh-subscriptions
```

if:

```env
ENABLE_SUBSCRIPTIONS
```

has been modified,

or manually run:

```bash
./auth/generate.sh
```

to force an immediate update.