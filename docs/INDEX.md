# NookMesh Technical Documentation

🇪🇸 [Versión en español](INDEX.es.md)

Welcome to the NookMesh technical documentation.

This documentation describes the current architecture, installation, configuration, integrations, and operational behavior of the project.

If you are looking for a high-level overview, use cases, or introductory information, please refer to the main repository README.

## Documentation Scope

Here you will find information about:

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

Initial environment preparation, configuration files, and base stack deployment:

- [Installation](getting-started/installation.md)

## Quick Start

Fast validation of a complete end-to-end working installation:

- [Quick Start](getting-started/quickstart.md)

---

# Architecture

## Overview

Conceptual system architecture:

- [Overview](architecture/overview.md)

## Components

Detailed description of services and responsibilities:

- [Components](architecture/components.md)

## Data Flow

Complete journey of a location from device to visualization client:

- [Data Flow](architecture/data-flow.md)

## Persistence

Storage model and operational data architecture:

- [Persistence](architecture/persistence.md)

---

# Configuration

## Users

Complete user model, permissions, states, expirations, and subscription configuration:

- [Users](configuration/users.md)

## MQTT

Broker, authentication, and transport configuration:

- [MQTT](configuration/mqtt.md)

## Authentication Generator

Generation and maintenance of MQTT credentials, ACLs, API tokens, user states, and runtime configuration:

- [Authentication Generator](configuration/auth-generator.md)

## Subscriptions

Autonomous service for automatic expiration processing, renewals, and periodic user maintenance:

- [Subscriptions](configuration/subscriptions.md)

## Operational Filters

GeoJSON processing behavior and global runtime parameters:

- [Filters](configuration/filters.md)

## Visibility

Rules controlling user visibility and exposure:

- [Visibility](configuration/visibility.md)

## Multi-Device

Management of multiple devices associated with the same user:

- [Multi-Device](configuration/multi-device.md)

## TLS and Transport Security

Secure communications and production deployment practices:

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

Visual customization for compatible clients:

- [MapCSS](integrations/mapcss.md)

---

# API

## Authentication

Access model for protected endpoints:

- [Authentication](api/authentication.md)

## GeoJSON Endpoints

Location consumption through GeoJSON:

- [GeoJSON Endpoints](api/geojson-endpoints.md)

---

# Roadmap

## Hybrid Location Roadmap

Future evolution towards multiple location sources and hybrid transport systems:

- [Hybrid Location Roadmap](roadmap/hybrid-location-roadmap.md)

---

# Troubleshooting

## Common Issues

Diagnosis and resolution of common operational problems:

- [Common Issues](troubleshooting/common-issues.md)

---

# Recommended Path for New Users

If this is your first NookMesh installation, the recommended reading order is:

1. [Overview](architecture/overview.md)
2. [Requirements](getting-started/requirements.md)
3. [Installation](getting-started/installation.md)
4. [Quick Start](getting-started/quickstart.md)
5. [Users](configuration/users.md)
6. [MQTT](configuration/mqtt.md)
7. [Authentication Generator](configuration/auth-generator.md)
8. [Subscriptions](configuration/subscriptions.md)
9. [Filters](configuration/filters.md)
10. [Visibility](configuration/visibility.md)
11. [OwnTracks](integrations/owntracks.md)
12. [Guru Maps](integrations/gurumaps.md)
13. [Common Issues](troubleshooting/common-issues.md)