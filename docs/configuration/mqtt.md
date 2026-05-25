# MQTT

NookMesh uses MQTT as the messaging backbone for real-time location transport.

The current implementation is based on:

```text
Mosquitto
```

MQTT allows publication, transport, and location persistence to remain decoupled.

---

# MQTT's role in NookMesh

Main flow:

```text
OwnTracks
   ↓
MQTT (Mosquitto)
   ↓
OwnTracks Recorder
   ↓
Worker
   ↓
GeoJSON API
```

MQTT is responsible for:

- receiving published locations
- MQTT client authentication
- ACL enforcement (MQTT access control)
- distributing messages to the recorder

It does not directly participate in:

- visibility filtering
- GeoJSON generation
- API authentication
- visual rendering

---

# Current broker

NookMesh uses:

```text
Mosquitto
```

deployed as an independent component:

```text
mqtt/
```

This enables:

- broker isolation
- modular configuration
- stronger security hardening
- independent maintenance

---

# Topics used

OwnTracks publishes using the standard structure:

```text
owntracks/<user>/<device>
```

Examples:

```text
owntracks/sergio/iphone
owntracks/sandra/redmi
owntracks/raul/car
```

Structure:

- `<user>` → logical identity
- `<device>` → physical location source

---

# MQTT users

Each user has independent MQTT credentials defined in:

```text
config/users.json
```

Example:

```json
"sergio": {
  "mqtt_password": "PASSWORD_SERGIO"
}
```

During:

```bash
./auth/generate.sh
```

these credentials are transformed into:

```text
config/generated/mqtt-passwords.txt
```

in a Mosquitto-compatible format.

Advantages:

- user isolation
- individual revocation
- traceability
- granular security

---

# Internal recorder user

NookMesh uses a required internal technical account:

```text
recorder
```

Defined in:

```text
config/users.json
```

Example:

```json
"recorder": {
  "enabled": true,
  "mqtt_admin": true,
  "mqtt_password": "PASSWORD_RECORDER",
  "system_user": true
}
```

And referenced from:

```text
config/recorder.env
```

This account is used by:

```text
OwnTracks Recorder
```

to consume MQTT messages.

It does not represent a human user.

---

# MQTT ACLs

NookMesh automatically generates:

```text
config/generated/mqtt-acl.txt
```

using:

```bash
./auth/generate.sh
```

This file defines per-user MQTT permissions.

---

## Standard user

Example:

```text
user sergio
topic read owntracks/sergio/#
topic write owntracks/sergio/#
```

Allows:

- publishing their own locations
- reading only their own MQTT namespace

---

## User with `mqtt_admin`

If:

```json
"mqtt_admin": true
```

example:

```text
user sergio
topic read owntracks/#
topic write owntracks/sergio/#
```

This grants:

- global read access to the OwnTracks tree
- write access only within the user's own namespace

Important:

```text
mqtt_admin does NOT grant global write access
```

---

## Internal `system_user`

Real case:

```text
user recorder
topic read owntracks/#
```

Characteristics:

- global MQTT read access
- no MQTT write access
- no API token
- excluded from the visibility model

Internal use only.

---

# How authentication works

Simplified process:

### 1. OwnTracks connects

Example:

```text
mqtt.nookmesh.example
```

using:

- MQTT username
- MQTT password

---

### 2. Mosquitto validates credentials

Against:

```text
mqtt-passwords.txt
```

---

### 3. Mosquitto applies ACLs

Against:

```text
mqtt-acl.txt
```

---

### 4. If authorized

the message is distributed.

Example:

```text
OwnTracks → Recorder
```

---

# Changing MQTT credentials

To change credentials:

### 1. Edit

```text
config/users.json
```

---

### 2. Modify

```json
"mqtt_password"
```

---

### 3. Regenerate

```bash
./auth/generate.sh
```

This updates:

```text
mqtt-passwords.txt
mqtt-acl.txt
```

and restarts compatible active services.

---

# Recommended security

## Mandatory authentication

Never expose an open broker.

Always use:

- username
- password

---

## TLS in production

Strongly recommended:

- MQTT over TLS
- valid certificates

Protects:

- credentials
- locations
- MQTT traffic

---

## Principle of least privilege

Prefer:

```text
user → only their own namespace
```

instead of:

```text
unnecessary global read access
```

Only use:

```json
"mqtt_admin": true
```

when genuinely required.

---

# Troubleshooting

## OwnTracks cannot connect

Check:

- broker host
- port
- DNS
- TLS
- username
- password

---

## Authentication failed

Check:

```json
mqtt_password
```

and regenerate:

```bash
./auth/generate.sh
```

---

## Recorder does not receive messages

Check:

- active broker
- recorder credentials
- `config/recorder.env`
- `recorder` user
- broker logs
- recorder logs

---

## MQTT works but no locations appear

MQTT may be functioning correctly while later stages fail.

Check:

```text
Recorder
Worker
API
```

---

# Best practices

## One credential per user

Do not share MQTT accounts between different people.

---

## Keep `recorder` separate

Do not reuse the internal technical account for human users.

---

## Limit `mqtt_admin`

Reduce exposure surface.

---

## Use TLS for real deployments

Especially if the broker is accessible from the Internet.

---

# Relationship with other components

MQTT connects:

- OwnTracks
- Mosquitto
- OwnTracks Recorder

It does not decide:

- which users can see each other
- which GeoJSON gets delivered
- how the map is rendered