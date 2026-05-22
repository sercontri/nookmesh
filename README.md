# NookMesh

[Español](docs/README.es.md)

**Private, secure and self-hosted real-time location sharing for friends, families and teams.**

NookMesh is a self-hosted real-time location sharing platform built around **OwnTracks**, **MQTT**, **Docker**, and a protected **GeoJSON API**.

It allows you to collect live device locations, apply advanced visibility rules, and display positions in map clients such as **Guru Maps**, while maintaining full control over your infrastructure and data.

Unlike commercial tracking platforms, NookMesh is designed with a privacy-first architecture:

- Your server
- Your MQTT broker
- Your API
- Your access rules
- Your tokens
- Your data
- Your groups

NookMesh supports multi-user deployments, group-based visibility, secure token authentication, and multi-device tracking.

---

## Features

- Real-time location tracking using OwnTracks
- Self-hosted MQTT infrastructure
- Full Docker-based deployment
- Token-protected API access
- Group-based visibility filtering
- Selective hidden visibility rules
- MQTT administrative access controls
- Multi-device support per user
- Automatic token generation and selective regeneration
- Protected MapCSS asset delivery
- Guru Maps integration
- Dynamic per-user GeoJSON filtering
- TLS-ready architecture
- Privacy-first design
- No dependency on third-party cloud services

---

## Architecture Overview

NookMesh follows a modular self-hosted architecture:

```text
OwnTracks (iOS / Android)
            │
            │ MQTT over TLS
            ▼
      Mosquitto Broker
            │
            ▼
    OwnTracks Recorder
            │
            ▼
   GeoJSON Export Worker
            │
            ▼
      Filtered FastAPI API
            │
            ├── Protected GeoJSON endpoint
            └── Protected MapCSS endpoint
                    │
                    ▼
                 Guru Maps
```

---

## Use Cases

NookMesh is ideal for:

- Families who want private location sharing
- Groups of friends during trips or events
- Hiking and outdoor teams
- Volunteer coordination
- Mesh network communities
- Privacy-conscious self-hosters
- Technical users who want full infrastructure control

---

## Why NookMesh?

Most commercial location-sharing platforms require trusting a third party with your location history and infrastructure.

NookMesh takes a different approach.

The entire data flow remains under your control:

- The device publishes its location
- Your MQTT broker receives it
- Your recorder stores it
- Your worker transforms it
- Your API decides who can see it
- Your map client consumes it

No external service has access to your location data unless you explicitly expose it.

This makes NookMesh especially suitable for users who value:

- privacy
- data ownership
- transparency
- auditability
- extensibility

---

## Quick Installation

### Requirements

Before deploying NookMesh, you will need:

- A Linux server or NAS compatible with Docker
- Docker
- Docker Compose
- `jq`
- `openssl`
- A domain or subdomains (recommended for production)
- Valid TLS certificates (recommended for MQTT and API)
- OwnTracks app (iOS / Android)
- Guru Maps (for map visualization)

Supported environments include:

- Synology NAS
- Ubuntu Server
- Debian
- Any Linux host with Docker support

---

## Quick Start

Clone the repository:

```bash
git clone https://github.com/sercontri/nookmesh.git
cd nookmesh
```

Copy the example configuration files:

```bash
cp config/users.example.json config/users.json
cp config/filtros.example.env config/filtros.env
cp config/recorder.example.env config/recorder.env
```

Edit the configuration files for your environment:

```bash
vi config/users.json
vi config/filtros.env
vi config/recorder.env
```

Generate authentication and runtime files:

```bash
./auth/generate.sh
```

Start the containers:

```bash
docker compose -f mqtt/docker-compose.yml up -d
docker compose -f recorder/docker-compose.yml up -d
docker compose -f worker/docker-compose.yml up -d
docker compose -f api/docker-compose.yml up -d
```

Verify container status:

```bash
docker ps
```

---

## First Deployment Workflow

Recommended deployment sequence:

1. Configure users (`users.json`)
2. Configure filters (`filtros.env`)
3. Configure recorder (`recorder.env`)
4. Generate runtime authentication files (`generate.sh`)
5. Start MQTT broker
6. Start OwnTracks recorder
7. Start GeoJSON worker
8. Start API
9. Configure OwnTracks clients
10. Configure Guru Maps layer

---

## First User Example

The `config/users.json` file defines users, permissions, groups and authentication behavior.

Minimal example:

```json
{
  "users": {
    "recorder": {
      "enabled": true,
      "mqtt_admin": true,
      "mqtt_password": "CHANGE_ME",
      "system_user": true
    },
    "sergio": {
      "enabled": true,
      "mqtt_password": "CHANGE_ME",
      "regen_token": false,
      "grupos": ["family"]
    }
  }
}
```

After running:

```bash
./auth/generate.sh
```

NookMesh automatically generates:

```text
config/generated/mqtt-passwords.txt
config/generated/mqtt-acl.txt
config/generated/api-tokens.txt
data/runtime/visibility.json
```

---

## What generate.sh Does

The authentication generator automates:

- MQTT credential generation
- MQTT ACL generation
- API token generation
- runtime visibility rule generation
- selective token regeneration
- automatic restart of compatible running services

This avoids manual editing of sensitive authentication files.

---

## API Access

After deployment, protected endpoints follow this structure:

GeoJSON:

```text
https://geojson.yourdomain.com/nookmesh.geojson?token=YOUR_TOKEN
```

MapCSS:

```text
https://style.yourdomain.com/nookmesh_v1.mapcss?token=YOUR_TOKEN
```

Each user receives an individual API token.

---

## Production Recommendations

For production deployments:

- use MQTT over TLS
- use HTTPS for API access
- avoid exposing unnecessary ports
- secure NAS/server administrative access
- use strong MQTT passwords
- use individual API tokens
- maintain regular backups

---

## Configuration

NookMesh separates configuration responsibilities into dedicated files:

```text
config/users.json
config/filtros.env
config/recorder.env
```

---

## users.json

This file defines users, permissions, groups and authentication behavior.

Example:

```json
{
  "_meta": {
    "description": "NookMesh user configuration"
  },
  "users": {
    "recorder": {
      "enabled": true,
      "mqtt_admin": true,
      "mqtt_password": "CHANGE_ME",
      "system_user": true
    },
    "sergio": {
      "enabled": true,
      "mqtt_password": "CHANGE_ME",
      "regen_token": false,
      "grupos": ["family", "staff"],
      "oculto_para": ["staff"],
      "rol": "staff"
    }
  }
}
```

---

## Available Fields

### enabled

Enables or disables a user.

```json
"enabled": true
```

If set to `false`, the user is ignored.

---

### mqtt_password

User MQTT password.

```json
"mqtt_password": "CHANGE_ME"
```

Used by OwnTracks to publish location updates.

---

### mqtt_admin

Grants full MQTT broker read access.

```json
"mqtt_admin": true
```

Intended for privileged users or internal services.

---

### system_user

Marks internal system users.

```json
"system_user": true
```

Typical example:

- recorder

System users:

- do not receive API tokens
- do not appear in map visualization
- may receive infrastructure-specific permissions

---

### regen_token

Forces regeneration of a user's API token.

```json
"regen_token": true
```

Recommended use cases:

- token compromise
- manual revocation
- selective rotation

After regeneration, this value is automatically reset to:

```json
"regen_token": false
```

to prevent unintended future regeneration.

---

### grupos

Defines group membership.

```json
"grupos": ["family", "staff"]
```

Groups control location visibility between users.

---

### oculto_para

Hides a user from specific shared groups.

```json
"oculto_para": ["friends"]
```

Example:

If a user belongs to:

```json
["family", "friends"]
```

and another user shares both groups,

the hidden group will be excluded from visibility calculations.

---

### rol

Optional visual role classification.

```json
"rol": "staff"
```

Currently used for:

- visual differentiation in Guru Maps
- custom rendering logic
- future extensibility

---

## filtros.env

Controls GeoJSON filtering behavior.

Example:

```env
MAX_EDAD_MIN=60
EXCLUDE_VIEWER_IN_OUTPUT=true
EXCLUDE_NEARBY_METROS=80
REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY=true
MERGE_CLOSEST_DEVICES=true
MERGE_MAX_METROS=100
```

---

## Available Filter Parameters

### MAX_EDAD_MIN

Maximum accepted age for location data.

```env
MAX_EDAD_MIN=60
```

Older positions are excluded.

---

### EXCLUDE_VIEWER_IN_OUTPUT

Hides the authenticated viewer's own position.

```env
EXCLUDE_VIEWER_IN_OUTPUT=true
```

Avoids duplicate display in map clients.

---

### EXCLUDE_NEARBY_METROS

Hides users located too close to the viewer.

```env
EXCLUDE_NEARBY_METROS=80
```

Reduces map clutter.

---

### REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY

Requires the viewer's own position to be recent before proximity filtering is applied.

```env
REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY=true
```

Avoids decisions based on stale viewer positions.

---

### MERGE_CLOSEST_DEVICES

Merges nearby devices belonging to the same user.

```env
MERGE_CLOSEST_DEVICES=true
```

Useful when a user publishes from multiple devices.

---

### MERGE_MAX_METROS

Maximum distance for grouping devices from the same user.

If multiple devices are inside this radius, only the most recent position is shown.

```env
MERGE_MAX_METROS=100
```

---

## recorder.env

OwnTracks Recorder configuration.

Defines environment-specific parameters such as:

- MQTT broker connection
- TLS authentication
- storage configuration
- ports
- service runtime configuration

---

## Visibility Model

One of NookMesh’s core features is its group-based visibility model.

Unlike simple "everyone sees everyone" location sharing systems, NookMesh allows precise control over who can see whom.

Visibility is calculated dynamically for every authenticated GeoJSON request.

---

## Groups

Each user can belong to one or multiple groups:

```json
"grupos": ["family", "friends", "hiking"]
```

Groups represent sharing contexts.

Examples:

- family
- friends
- work
- hiking
- volunteers
- meshtastic
- community

A user will only see positions from other users with whom they share at least one visible group.

---

## Basic Example

User A:

```json
"grupos": ["family"]
```

User B:

```json
"grupos": ["family"]
```

Result:

```text
A can see B
B can see A
```

---

User C:

```json
"grupos": ["work"]
```

Result:

```text
A cannot see C
C cannot see A
```

---

## Multiple Groups

A user may belong to several groups:

```json
"grupos": ["family", "hiking"]
```

Visibility is granted if at least one shared visible group exists.

Example:

User A:

```json
["family", "hiking"]
```

User B:

```json
["hiking"]
```

Result:

```text
A and B can see each other
```

---

## oculto_para

Allows selectively hiding a user from specific groups.

Example:

```json
{
  "grupos": ["family", "friends"],
  "oculto_para": ["friends"]
}
```

Interpretation:

- the user belongs to both groups
- but does not want visibility through the `friends` group

Result:

- users sharing only `friends` will not see this user
- users sharing `family` will still see this user

This allows highly flexible partial visibility.

---

## Real Example

User:

```json
{
  "grupos": ["family", "hiking", "friends"],
  "oculto_para": ["friends"]
}
```

Another user:

```json
{
  "grupos": ["friends"]
}
```

Result:

```text
Not visible
```

---

Another user:

```json
{
  "grupos": ["family"]
}
```

Result:

```text
Visible
```

---

## Roles

Users may optionally define a visual role:

```json
"rol": "staff"
```

Currently this is used for:

- visual differentiation in Guru Maps
- custom rendering logic
- future extensibility

It does not currently affect visibility permissions.

---

## mqtt_admin

Some users may receive administrative MQTT access:

```json
"mqtt_admin": true
```

This grants full read access to MQTT topics:

```text
owntracks/#
```

Intended for:

- administrators
- monitoring
- internal services

This does not directly affect GeoJSON visibility.

---

## system_user

Internal infrastructure users:

```json
"system_user": true
```

Example:

```json
recorder
```

These users are excluded from map visualization.

They exist only for infrastructure responsibilities.

---

## How Visibility Is Calculated

For every authenticated API request:

1. The user is authenticated via API token
2. User configuration is resolved
3. Group membership is loaded
4. `oculto_para` exclusions are applied
5. Shared groups are compared
6. Unauthorized positions are filtered
7. Only permitted data is returned

This happens dynamically in real time.

---

## Design Philosophy

NookMesh avoids rigid visibility models.

Instead, it supports real-world social sharing patterns.

Examples:

- families sharing only among themselves
- event-based friend visibility
- selectively hidden users
- community group segmentation
- mesh network deployments with layered visibility

The goal is flexibility without relying on third-party services.

---

## OwnTracks Configuration

NookMesh uses OwnTracks as its location publishing client.

Supported platforms:

- iPhone / iPad (iOS)
- Android

Each device publishes location updates to the NookMesh MQTT broker using individual credentials.

---

## Basic OwnTracks Settings

Configure OwnTracks as follows:

### Mode

```text
Private MQTT
```

---

### Host

Your MQTT broker hostname:

```text
mqtt.yourdomain.com
```

---

### Port

Recommended with TLS:

```text
8883
```

Local testing without TLS:

```text
1883
```

---

### Username

Defined in:

```text
config/users.json
```

Example:

```text
sergio
```

---

### Password

User MQTT password:

```text
mqtt_password
```

---

### Device ID

Device identifier.

Examples:

```text
iphone
redmi
pixel
car
watch
```

Supports multi-device tracking.

---

### Tracker ID

Short visual identifier.

Examples:

```text
SE
RA
AN
```

Used in Guru Maps visual rendering.

---

## TLS Security

Production deployments should always use:

```text
Use TLS = enabled
```

with valid certificates.

This protects:

- MQTT credentials
- GPS positions
- device metadata

---

## MQTT Topic Structure

NookMesh uses standard OwnTracks topic naming:

```text
owntracks/<user>/<device>
```

Examples:

```text
owntracks/sergio/iphone
owntracks/raul/redmi
```

---

## Request Location

OwnTracks supports remote location requests.

Support depends on:

- client implementation
- MQTT permissions
- client connectivity

NookMesh remains compatible with the standard OwnTracks request flow.

---

## Multi-Device Support

A single user may publish from multiple devices:

```text
owntracks/sergio/iphone
owntracks/sergio/ipad
owntracks/sergio/car
```

NookMesh can:

- display all devices
- merge nearby devices
- display only the most recent device depending on configuration

---

## Map Visualization

NookMesh exposes protected GeoJSON endpoints for compatible map clients.

Example:

GeoJSON:

```text
https://geojson.yourdomain.com/nookmesh.geojson?token=TOKEN
```

MapCSS:

```text
https://style.yourdomain.com/nookmesh_v1.mapcss?token=TOKEN
```

---

## Guru Maps

Example Guru Maps overlay template:

```text
docs/nookmesh_gurumaps_overlay.ms
```

Recommended configuration:

### GeoJSON Layer

Use:

```text
https://geojson.yourdomain.com/nookmesh.geojson?token=TOKEN
```

---

### MapCSS Style

Use:

```text
https://style.yourdomain.com/nookmesh_v1.mapcss?token=TOKEN
```

---

## Per-User Tokens

Each user receives an individual API token.

This enables:

- per-user authentication
- per-user filtering
- selective revocation
- simpler auditing

Do not share API tokens or Guru Maps layers between users.

---

## Compatibility

NookMesh is currently optimized for:

- OwnTracks
- Guru Maps

Because output is standard GeoJSON, other compatible map clients may be supported with minimal adaptation.

---

## Security

NookMesh follows a privacy-first and least-privilege architecture.

The goal is to keep infrastructure, authentication and data ownership fully under the deployer's control.

---

## API Authentication

Visual endpoints are protected with individual API tokens.

Example:

```text
https://geojson.yourdomain.com/nookmesh.geojson?token=TOKEN
```

Each user receives an independent token.

Benefits:

- individual authentication
- selective revocation
- user isolation
- granular access control

---

## Persistent Tokens

Tokens do not change automatically during normal regeneration.

This prevents breaking active Guru Maps client configurations.

Tokens only change when:

```json
"regen_token": true
```

is enabled for a specific user and `generate.sh` is executed.

---

## MQTT Authentication

Each user has independent MQTT credentials:

```json
"mqtt_password": "..."
```

Credentials are never shared.

Benefits:

- isolated access
- per-user revocation
- simpler auditing
- MQTT permission control

---

## MQTT ACL

NookMesh automatically generates MQTT ACL rules.

Regular users:

```text
owntracks/<user>/#
```

MQTT administrators:

```text
owntracks/#
```

This avoids manual editing of sensitive broker permissions.

---

## Recommended TLS Usage

Production deployments should use:

- MQTT over TLS
- HTTPS for API access
- valid certificates

This protects:

- credentials
- GPS positions
- metadata
- authentication traffic

---

## No Mandatory Cloud Dependency

NookMesh does not depend on third-party cloud services.

Your data remains inside your infrastructure:

- MQTT broker
- recorder
- API
- storage
- configuration

---

## Service Separation

The multi-service architecture reduces attack surface.

Logical separation:

- MQTT broker
- recorder
- worker
- API
- authentication generator

Benefits:

- maintainability
- isolation
- troubleshooting
- scalability

---

## Troubleshooting

## Devices Do Not Appear

Check:

- MQTT container is running
- recorder container is running
- MQTT credentials are correct
- OwnTracks configuration is correct
- TLS is properly configured
- client connectivity to the broker

View logs:

```bash
docker logs nookmesh-mqtt
docker logs nookmesh-recorder
```

---

## GeoJSON Is Not Generated

Check:

- worker container is running
- recorder storage is accessible
- mounted paths are correct
- file permissions are valid

View logs:

```bash
docker logs nookmesh-worker
```

---

## API Returns Access Denied

Check:

- API token is correct
- user is enabled
- token has not been revoked
- generated runtime configuration is up to date

Regenerate runtime files:

```bash
./auth/generate.sh
```

---

## Other Users Do Not Appear

Check:

- shared groups
- `oculto_para` rules
- position age filtering
- proximity filters
- viewer self-exclusion settings

---

## OwnTracks Connects but Does Not Publish

Check:

- host
- port
- TLS settings
- username
- MQTT password
- ACL permissions

Expected topic format:

```text
owntracks/<user>/<device>
```

---

## Guru Maps Issues

Check:

- correct GeoJSON URL
- correct MapCSS URL
- valid API token
- HTTPS accessibility
- application cache

Manual test:

```text
https://geojson.yourdomain.com/nookmesh.geojson?token=TOKEN
```

---

## Credential Regeneration

After changing users or permissions:

```bash
./auth/generate.sh
```

This updates:

- MQTT passwords
- MQTT ACL
- API tokens
- runtime visibility configuration

---

## Project Status

NookMesh is an actively evolving project.

The current architecture is functional and used in production, but the platform will continue to evolve.

Planned improvement areas include:

- expanded documentation
- official website
- additional client integrations
- simplified deployment tooling
- improved observability
- visual enhancements
- advanced filtering options

---

## Roadmap

Planned goals:

- full web documentation
- deployment examples
- broader GeoJSON client compatibility
- authentication improvements
- better administration tooling
- more modular configuration
- additional map client integrations

---

## Contributing

Contributions are welcome.

Ways to contribute:

- Open issues
- Propose improvements
- Report bugs
- Improve documentation
- Suggest integrations
- Submit pull requests

Before contributing:

- Never include secrets
- Use example configuration files
- Maintain architectural consistency
- Document meaningful changes

---

## Project Philosophy

NookMesh started from a simple idea:

**location sharing should not require handing your data to third parties.**

The project is built around:

- privacy
- control
- transparency
- self-hosting
- technical simplicity
- extensibility

---

## Support

If NookMesh is useful to you, there are several ways to support the project:

- Star the repository
- Report bugs and suggest improvements
- Contribute code or documentation
- Share the project with others
- Support independent development on Ko-fi:

https://ko-fi.com/nooktrail

Your support helps maintain infrastructure, improve documentation, and continue building privacy-first open tools for the community.

---

## Example Assets

Additional resources are available in `/docs`:

- Spanish documentation (`README.es.md`)
- Guru Maps overlay template (`nookmesh_gurumaps_overlay.ms`)

---

## License

NookMesh is distributed under the **GNU Affero General Public License v3.0 (AGPLv3)**.

In summary:

- you may use NookMesh freely
- you may modify it
- you may deploy it on your own infrastructure
- you may redistribute it
- you may use it as part of a service

However, if you modify NookMesh and offer it as a network-accessible service, you must make those modifications available under the same license.

The goal is to protect the freedom of the project and ensure improvements return to the community.

See the `LICENSE` file for the full legal text.