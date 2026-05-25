# NookMesh Technical Documentation

🇪🇸 [Versión en español](INDEX.es.md)

Welcome to the NookMesh technical documentation.

This documentation describes the current architecture, installation, configuration, integrations, and operational behavior of the project.

If you're looking for a general overview, use cases, or introductory information, refer to the main project README.

---

## Scope of this documentation

Here you'll find information about:

- installation and deployment
- internal architecture
- operational configuration
- authentication and security
- supported integrations
- GeoJSON API
- troubleshooting
- technical roadmap

This documentation is intended for real-world deployments and reflects the current implementation of the project.

---

# Getting Started

## Requirements

What you need before deploying NookMesh:

- [Requirements](getting-started/requirements.md)

## Installation

Initial environment setup, configuration files, and base stack deployment:

- [Installation](getting-started/installation.md)

## Quick Start

Fast end-to-end validation of a working installation:

- [Quick Start](getting-started/quickstart.md)

---

# Architecture

## Overview

Conceptual system architecture:

- [Overview](architecture/overview.md)

## Components

Detailed description of system services:

- [Components](architecture/components.md)

## Data Flow

Full path of a location update from device to map client:

- [Data Flow](architecture/data-flow.md)

## Persistence

Storage model and operational data layout:

- [Persistence](architecture/persistence.md)

---

# Configuration

## Users

Identities, permissions, and user configuration:

- [Users](configuration/users.md)

## MQTT

Broker, authentication, and transport:

- [MQTT](configuration/mqtt.md)

## Authentication Generator

Generation of MQTT credentials, ACLs, API tokens, and runtime configuration:

- [Authentication Generator](configuration/auth-generator.md)

## Operational Filters

GeoJSON processing behavior:

- [Filters](configuration/filters.md)

## Visibility

Exposure and hiding rules between users:

- [Visibility](configuration/visibility.md)

## Multi-device

Managing multiple devices associated with the same user:

- [Multi-device](configuration/multi-device.md)

## TLS and Transport Security

Secure communications and production deployment protection:

- [TLS](configuration/tls.md)

---

# Integrations

## OwnTracks

Primary location publishing client:

- [OwnTracks](integrations/owntracks.md)

## Guru Maps

Primary visualization client:

- [Guru Maps](integrations/gurumaps.md)

## MapCSS

Visual customization for supported clients:

- [MapCSS](integrations/mapcss.md)

---

# API

## Authentication

Protected endpoint access model:

- [Authentication](api/authentication.md)

## GeoJSON Endpoints

GeoJSON-based location consumption:

- [GeoJSON Endpoints](api/geojson-endpoints.md)

---

# Roadmap

## Hybrid Location Roadmap

Future evolution toward multiple location sources and hybrid transport models:

- [Hybrid Location Roadmap](roadmap/hybrid-location-roadmap.md)

---

# Troubleshooting

## Common Issues

Diagnosis and resolution of common problems:

- [Common Issues](troubleshooting/common-issues.md)

---

# Recommended Path for New Users

If this is your first NookMesh installation, this is the recommended reading path:

1. [Overview](architecture/overview.md)
2. [Requirements](getting-started/requirements.md)
3. [Installation](getting-started/installation.md)
4. [Quick Start](getting-started/quickstart.md)
5. [Users](configuration/users.md)
6. [MQTT](configuration/mqtt.md)
7. [Authentication Generator](configuration/auth-generator.md)
8. [Visibility](configuration/visibility.md)
9. [OwnTracks](integrations/owntracks.md)
10. [Guru Maps](integrations/gurumaps.md)
11. [Common Issues](troubleshooting/common-issues.md)