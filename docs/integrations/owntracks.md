# OwnTracks Integration

🇪🇸 [Versión en español](owntracks.es.md)

Currently, NookMesh uses **OwnTracks** as the primary client for location capture and publishing.

OwnTracks is a mature, privacy-oriented client particularly well suited for self-hosted MQTT-based architectures.

Official project:

https://owntracks.org/

---

## Role within NookMesh

OwnTracks is the primary source of location data.

Responsibilities:

- capturing GPS location
- detecting movement changes depending on platform
- collecting device metadata
- publishing location events via MQTT

Full flow:

```text
OwnTracks
   ↓
MQTT Broker
   ↓
Recorder
   ↓
Worker
   ↓
GeoJSON API
   ↓
Guru Maps
```

OwnTracks does not interact directly with the API or Guru Maps.

It only publishes locations to the MQTT broker.

---

## Supported platforms

Currently:

- iPhone / iPad (iOS)
- Android

This allows mixed environments with multiple users and different devices.

---

## Data used by NookMesh

Depending on device and configuration, OwnTracks publishes multiple fields.

NookMesh primarily uses:

- latitude (`lat`)
- longitude (`lon`)
- accuracy (`acc`)
- altitude (`alt`)
- speed (`vel`)
- heading (`cog`)
- battery (`batt`)
- connection type (`conn`)
- timestamp (`tst`)
- device identifier (`device`)
- tracker ID (`tid`)
- username (`username`)

Example:

```json
{
  "_type": "location",
  "lat": 38.561445,
  "lon": -0.212222,
  "acc": 13,
  "alt": 683,
  "vel": 10,
  "cog": 221,
  "batt": 80,
  "conn": "m",
  "tid": "SA"
}
```

---

## Communication with NookMesh

NookMesh uses OwnTracks in:

```text
Private MQTT mode
```

Locations are published via MQTT using the standard format:

```text
owntracks/<user>/<device>
```

Example:

```text
owntracks/sandra/iphone
```

NookMesh Recorder automatically consumes these messages from the MQTT broker.

---

## Authentication

Each user uses independent MQTT credentials.

Defined in:

```text
config/users.json
```

Example:

```json
"sergio": {
  "mqtt_password": "PASSWORD_SERGIO"
}
```

After running:

```bash
./auth/generate.sh
```

those credentials become operational in Mosquitto.

Benefits:

- user isolation
- individual revocation
- granular control
- traceability

---

# Basic configuration

## 1. Install OwnTracks

Download the official app for your platform.

---

## 2. Select mode

Configure:

```text
Private MQTT
```

---

## 3. Configure MQTT broker

### Host

Example:

```text
mqtt.yourdomain.com
```

Must point to your NookMesh MQTT broker.

---

### Port

Production with TLS:

```text
8883
```

Lab environments without TLS:

```text
1883
```

---

### Username

Must exist in:

```text
config/users.json
```

Example:

```text
sergio
```

---

### Password

The value defined in:

```json
mqtt_password
```

for that user.

---

## 4. TLS

For real deployments:

enable TLS.

In environments with public certificates:

normally no additional configuration is required.

With self-signed certificates:

manual configuration may be required depending on platform.

See:

[TLS](../configuration/tls.md)

---

## 5. Device ID

Identifies the physical device.

Examples:

```text
iphone
pixel
ipad
tracker
car
```

This generates topics such as:

```text
owntracks/sergio/iphone
```

---

### Important

If you use multiple devices under the same user:

each Device ID must be unique.

Correct:

```text
iphone
ipad
tracker
```

Incorrect:

```text
iphone
iphone
```

Duplicating a Device ID will cause both devices to publish to the same logical topic.

---

## 6. Tracker ID (`tid`)

Short identifier used inside OwnTracks messages.

Examples:

```text
SE
SA
RA
```

In NookMesh it is used for visual map representation.

Example:

```text
SE
```

may be displayed as the user's visual label.

---

# Device ID vs Tracker ID

These are different concepts.

## Device ID

Part of the MQTT topic.

Example:

```text
owntracks/sergio/iphone
```

Represents:

physical device.

---

## Tracker ID (`tid`)

Part of the message payload.

Example:

```json
"tid": "SE"
```

Represents:

short visual identifier.

---

# Multi-device

NookMesh allows multiple devices per user.

Example:

```text
owntracks/sergio/iphone
owntracks/sergio/ipad
owntracks/sergio/tracker
```

Typical scenarios:

- primary phone
- tablet
- dedicated tracker
- temporary device

Visual behavior depends on:

```text
config/filtros.env
```

especially:

```env
MERGE_CLOSEST_DEVICES=true
MERGE_MAX_METROS=100
```

---

# Publishing behavior

OwnTracks may optimize publishing depending on:

- internal configuration
- detected movement
- activity
- operating system restrictions
- power saving
- connectivity

This directly affects the NookMesh experience.

---

# Platform considerations

## iOS

May be affected by:

- background restrictions
- location permissions
- power management policies
- automatic app suspension

---

## Android

Generally more flexible, but depends on manufacturer.

Common issues:

- aggressive battery optimization
- background restrictions
- vendor-specific limitations

Especially on:

- Xiaomi
- Oppo
- Huawei
- Realme
- Samsung (depending on configuration)

---

# Troubleshooting

## Cannot connect to broker

Check:

- MQTT host
- port
- DNS
- firewall
- TLS
- username
- password

---

## Auth failed

Verify:

```text
config/users.json
```

and regenerate:

```bash
./auth/generate.sh
```

if credentials were modified.

---

## MQTT connects but nothing appears on the map

Check layer by layer.

### Broker

```bash
docker logs nookmesh-mqtt
```

---

### Recorder

```bash
docker logs nookmesh-recorder
```

---

### Worker

```bash
docker logs nookmesh-worker
```

---

### API

```bash
docker logs nookmesh-api
```

---

Also check:

```text
data/owntracks/store/last
```

If the device does not appear there:

the problem is upstream of the worker.

---

## Irregular updates

Possible causes:

- battery saving
- location permissions
- background restrictions
- connectivity
- OwnTracks configuration
- operating system suspension

---

## Other users do not appear

Check:

- visibility (`grupos`)
- `oculto_para`
- age (`MAX_EDAD_MIN`)
- proximity filters
- correct API token

---

# Philosophy

OwnTracks fits especially well with NookMesh because it shares similar principles:

- privacy
- user control
- self-hosting
- owned infrastructure
- no mandatory cloud dependency

---

# Current limitation

NookMesh is currently primarily oriented around OwnTracks as its location source.

However, the architecture allows future alternative sources.

---

# Future

Possible future integrations:

- alternative GPS clients
- dedicated trackers
- IoT sources
- Meshtastic
- hybrid LTE + mesh nodes
