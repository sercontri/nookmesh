# Components

This document describes the main components that make up the current NookMesh architecture and their responsibilities within the system.

---

## Overview

Current architecture:

```text
OwnTracks
   ↓
MQTT Broker (Mosquitto)
   ↓
OwnTracks Recorder
   ↓
GeoJSON Worker
   ↓
Protected API
   ↓
Guru Maps / compatible clients
```

Each component maintains a clearly decoupled responsibility.

---

## OwnTracks

Primary client for location capture and publishing.

### Responsibilities

- capture GPS position
- detect movement
- manage accuracy
- collect device metadata
- publish MQTT messages

### Typical data sent

Example:

```json
{
  "_type": "location",
  "lat": 38.561445,
  "lon": -0.212222,
  "tid": "SA",
  "batt": 80,
  "vel": 10,
  "cog": 221,
  "acc": 13,
  "conn": "m"
}
```

### Dependencies

- accessible MQTT broker
- valid MQTT credentials
- correct client configuration

### Current status

It is currently the only officially supported location source.

---

## MQTT Broker

Current implementation:

```text
Mosquitto
```

Acts as the internal messaging backbone.

### Responsibilities

- receive OwnTracks publications
- authenticate MQTT clients
- enforce ACLs
- distribute messages
- decouple producers from consumers

### Inputs

MQTT messages published by clients.

Example:

```text
owntracks/sergio/iphone
```

### Outputs

MQTT events consumed by OwnTracks Recorder.

---

## OwnTracks Recorder

Primary persistence service.

### Responsibilities

- subscribe to the MQTT broker
- consume OwnTracks messages
- persist locations
- maintain latest positions per device

### Inputs

MQTT messages.

### Outputs

Persistent storage in:

```text
data/owntracks/store/
```

including:

```text
data/owntracks/store/last/
```

Real example:

```text
data/owntracks/store/last/sergio/iphone/sergio-iphone.json
```

### Notes

Recorder does NOT apply:

- API authentication
- visibility rules
- visual rendering

Its responsibility is persistence.

---

## GeoJSON Worker

Transformation and enrichment service.

### Responsibilities

- read persisted latest locations
- load runtime configuration
- apply base operational filters
- discard stale locations
- enrich GeoJSON properties
- generate base public GeoJSON

### Inputs

Recorder data:

```text
data/owntracks/store/last/
```

Configuration:

```text
data/runtime/visibility.json
config/filtros.env
```

### Outputs

Generated GeoJSON:

```text
data/public/nookmesh.geojson
```

### Typical processing

Includes:

- age calculation
- heading / direction
- speed
- battery
- accuracy
- connectivity
- device information
- enriched descriptions
- auxiliary rendering properties

### Important

The worker does NOT apply:

- viewer-specific relational visibility
- authentication
- contextual multi-device merging
- proximity filtering between users

That logic happens in the API.

---

## Protected API

HTTP layer for authenticated exposure and dynamic filtering.

### Responsibilities

- API token authentication
- viewer identification
- application of visibility rules
- user-specific contextual filtering
- optional self-viewer exclusion
- proximity filtering
- multi-device merging
- generation of final client-consumable GeoJSON
- optional serving of auxiliary assets

### Inputs

Authenticated HTTP requests.

Base GeoJSON:

```text
data/public/nookmesh.geojson
```

Runtime:

```text
data/runtime/visibility.json
```

### Outputs

Resources such as:

```text
nookmesh.geojson
nookmesh_v1.mapcss
```

### Important

The API does not simply return the worker-generated GeoJSON.

It builds a final response specifically for the authenticated viewer.

---

## Auth Generator

Operational automation component.

Main script:

```text
auth/generate.sh
```

### Responsibilities

- generate MQTT password database
- generate MQTT ACLs
- generate API tokens
- preserve existing tokens
- selectively regenerate tokens
- remove deleted user tokens
- generate visibility runtime
- deploy generated files
- restart compatible services

### Inputs

Declarative configuration:

```text
config/users.json
```

### Outputs

Generated files:

```text
config/generated/mqtt-passwords.txt
config/generated/mqtt-acl.txt
config/generated/api-tokens.txt
data/runtime/visibility.json
```

---

## Configuration

Editable persistent configuration files.

### Main files

```text
config/users.json
config/filtros.env
config/recorder.env
```

### Responsibilities

- user definitions
- MQTT credentials
- groups
- hiding rules
- roles
- recorder configuration
- operational pipeline parameters

---

## Persistence and runtime

Structure:

```text
data/
├── owntracks/
├── public/
└── runtime/
```

### `data/owntracks/`

OwnTracks Recorder persistence.

---

### `data/public/`

Client-consumable artifacts.

Example:

```text
nookmesh.geojson
nookmesh_v1.mapcss
```

---

### `data/runtime/`

Dynamically generated runtime state.

Example:

```text
visibility.json
```

---

## Guru Maps

Current primary visualization client.

### Responsibilities

- consume authenticated GeoJSON
- apply MapCSS styles
- render icons and labels
- display enriched metadata

### Current integration

Based on:

- GeoJSON
- MapCSS
- importable overlay

Included template:

```text
docs/assets/gurumaps/nookmesh_gurumaps_overlay.ms
```

---

## Future extensions

The architecture facilitates future evolution such as:

- alternative location sources
- web dashboards
- additional GeoJSON clients
- hybrid multi-transport architecture

---

## Separation philosophy

NookMesh clearly separates responsibilities:

### Capture

OwnTracks

---

### Transport

MQTT / Mosquitto

---

### Persistence

OwnTracks Recorder

---

### Transformation

GeoJSON Worker

---

### Authentication and contextual filtering

Protected API

---

### Operational provisioning

Auth Generator

---

### Visualization

Guru Maps / compatible clients

---

## Design benefits

This separation improves:

- debugging
- troubleshooting
- independent evolution
- security hardening
- modularity
- future component replacement