# Hybrid Architecture Roadmap

🇪🇸 [Versión en español](hybrid-location-roadmap.es.md)

> Roadmap — future vision, not currently implemented

NookMesh was initially created as a self-hosted real-time location sharing platform based on **OwnTracks + MQTT + Docker + GeoJSON API**.

However, its modular architecture opens the door to a more ambitious evolution:

becoming a location platform **independent of transport medium or data source**.

---

## Vision

Currently, NookMesh operates primarily with a single location source:

```text
OwnTracks
```

using traditional IP connectivity:

- LTE / 4G / 5G
- Wi-Fi
- equivalent IP networks

The planned evolution aims to expand this model toward a hybrid, multi-source architecture.

Conceptual goal:

```text
multiple sources
        ↓
   NookMesh backend
        ↓
GeoJSON / clients
```

This would allow the backend to avoid depending exclusively on a single app or conventional mobile connectivity.

---

## What NookMesh is today

Current architecture:

```text
OwnTracks
   ↓
MQTT
   ↓
Recorder
   ↓
Worker
   ↓
Protected API
   ↓
Guru Maps
```

Current characteristics:

- primary source: OwnTracks
- transport: MQTT
- individual authentication
- visibility filtering
- GeoJSON processing
- GeoJSON-compatible clients

This model already works in real-world environments.

---

## Where it evolves

The long-term vision is to decouple:

```text
location capture
```

from:

```text
processing and visualization
```

allowing multiple input sources.

Future conceptual model:

```text
Location Sources
      ↓
Ingestion Layer
      ↓
Normalization Layer
      ↓
Visibility / Filtering
      ↓
GeoJSON API
      ↓
Clients
```

This would turn NookMesh into a **transport-agnostic** location platform.

---

## Potential target sources

Conceptual examples:

- OwnTracks
- Meshtastic
- dedicated GPS trackers
- IoT devices
- hybrid gateways
- MQTT bridges
- future compatible sources

Not all of these are currently planned or prioritized.

They are presented as possible architectural directions.

---

## Priority scenario: Meshtastic

One of the most interesting scenarios is integration with **Meshtastic**.

Official project:

https://meshtastic.org/

Meshtastic would allow NookMesh to expand into environments where traditional mobile connectivity does not exist.

---

## Target use cases

Examples:

- motorcycle routes without coverage
- hiking
- expeditions
- outdoor activities
- remote group coordination
- events in rural areas
- resilient deployments
- hybrid LTE + mesh scenarios

---

## Meshtastic conceptual model

Example:

```text
Meshtastic nodes
      ↓
mesh network
      ↓
gateway / bridge
      ↓
NookMesh ingestion
      ↓
GeoJSON API
      ↓
clients
```

---

## Ideal hybrid model

Conceptual scenario:

when IP connectivity exists:

```text
OwnTracks → MQTT
```

when it does not:

```text
Meshtastic → bridge
```

both converging into:

```text
NookMesh backend
```

Example:

```text
OwnTracks (LTE)
            \
             NookMesh
            /
Meshtastic (mesh)
```

---

## What this evolution would bring

A hybrid architecture would allow:

- operation without mobile coverage
- transport redundancy
- operational resilience
- independence from a single provider or protocol
- tracking continuity
- distributed scenarios
- integration of new sources

---

## Philosophy

This evolution aligns with NookMesh’s foundational principles:

- privacy
- infrastructure ownership
- self-hosting
- interoperability
- cloud independence
- modularity

The idea is not to depend on a single app, but to build a flexible, sovereign backend layer.

---

## Why the current architecture enables this

Although NookMesh is currently centered around OwnTracks, its modular design already clearly separates:

- authentication
- transport
- persistence
- transformation
- filtering
- visualization

This reduces coupling between source and client.

In other words:

the backend is not completely tied to a single capture application.

---

## Technical challenges

A real evolution would require solving multiple aspects.

---

### Identity

Mapping:

```text
node IDs
device IDs
tracker IDs
```

into:

```text
logical NookMesh users
```

Example:

```text
Meshtastic node → sergio
```

---

### Data normalization

Different sources publish different structures.

Examples:

- OwnTracks
- Meshtastic
- GPS trackers
- IoT devices

NookMesh would need to translate everything into a coherent internal model.

---

### Transport

Defining how new events enter the backend.

Possible models:

- MQTT bridge
- API ingestion endpoint
- dedicated converter
- intermediary service
- specialized parser

---

### Deduplication

Hybrid scenario:

the same user could appear simultaneously from:

- OwnTracks
- Meshtastic
- dedicated tracker

This would require resolving:

- which source is preferred
- how to merge locations
- how to avoid duplicates

---

### Timestamps and stale data

Mesh networks introduce additional complexity:

- retransmissions
- forwarding
- latency
- delayed packets
- stale information

The backend would need to distinguish valid data from stale data.

---

### Security

Designing:

- authentication between bridge and backend
- source validation
- gateway isolation
- trust model
- ingestion control

---

### Observability

With multiple sources, debugging becomes more complex.

Examples:

- did OwnTracks fail?
- did the mesh bridge fail?
- did normalization fail?
- did the API fail?

---

## Ideal client experience

From the end user's perspective, ideally there would be no difference.

Guru Maps would continue consuming:

```text
GeoJSON
```

without needing to know whether the actual source is:

- LTE mobile device
- mesh network
- external tracker

Complexity would remain encapsulated in the backend.

---

## Possible future components

Conceptual examples:

```text
mesh-bridge
hybrid-router
ingestion-service
source-normalizer
tracker-adapter
```

These are not part of the current project.

---

## Current status

Currently:

✅ conceptually modular architecture  
✅ partially decoupled backend  
✅ functional GeoJSON pipeline  
❌ multi-source ingestion not implemented  
❌ Meshtastic not implemented  
❌ multi-source deduplication not implemented  

---

## Strategic goal

The long-term vision is for NookMesh to evolve from:

```text
OwnTracks + MQTT platform
```

into:

```text
self-hosted multi-source location platform
```

capable of abstracting:

- transport
- data origin
- capture protocol

while maintaining a consistent experience for visualization clients.

---

## Important

As of today, the only officially supported and documented location source is:

```text
OwnTracks
```

Everything described in this document represents strategic vision and future architectural roadmap.