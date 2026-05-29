# NookMesh

🇪🇸 [Versión en español](README.es.md)

![License](https://img.shields.io/github/license/sercontri/nookmesh)
![Last Commit](https://img.shields.io/github/last-commit/sercontri/nookmesh)
![Stars](https://img.shields.io/github/stars/sercontri/nookmesh)
[![Ko-fi](https://img.shields.io/badge/Support-Ko--fi-ff5f5f?logo=ko-fi&logoColor=white)](https://ko-fi.com/nooktrail)

**Self-hosted real-time location sharing platform with complete privacy and full control over your data.**

NookMesh is an open-source real-time location sharing platform built around **OwnTracks**, **MQTT**, **Docker**, and a protected **GeoJSON API**, designed for users who want complete control over their infrastructure, authentication, and location data.

It was originally created for motorcycle trips among friends, but its modular architecture allows it to be adapted to families, outdoor groups, technical teams, communities, and future hybrid architectures with multiple location sources.

> ⚠️ Project under active development. The core architecture is functional and usable, although some capabilities continue to evolve.

## NookMesh in Action

![NookMesh running in Guru Maps](docs/assets/images/nookmesh-gurumaps-main.png)

## Features

- Real-time location tracking through **OwnTracks + MQTT**
- **100% self-hosted** infrastructure
- Protected GeoJSON API with per-user authentication
- Direct visualization in **Guru Maps**
- Multi-user and multi-device support
- Advanced user visibility controls
- Automatic subscription and expiration management
- Modular Docker-based architecture
- Secure deployment through TLS (recommended)
- Foundation for future hybrid integrations

## Current Stack

NookMesh currently uses:

- OwnTracks
- Mosquitto
- OwnTracks Recorder
- FastAPI
- Docker
- GeoJSON
- Guru Maps
- Subscription Service

## How It Works

NookMesh receives locations from mobile devices through **OwnTracks**, processes them within your own infrastructure, and exposes only authorized data to compatible clients.

All authentication, user management, expiration processing, visibility filtering, and access control occur entirely within your own backend.

![NookMesh Architecture](docs/assets/images/architecture-overview.en.png)

📘 Detailed architecture documentation is available in the technical documentation.

---

## Use Cases

### 🏍 Motorcycle Trips and Group Rides

Track the position of fellow riders during routes and long-distance trips directly in Guru Maps.

### 👨‍👩‍👧‍👦 Family and Friends

Share locations with trusted people using personalized visibility rules.

### 🥾 Outdoor Activities

Hiking, cycling, off-roading, or any activity where coordinating positions is useful.

### 💼 Communities, Clubs, and Associations

Manage temporary member access through automatic expirations and renewals without relying on external services.

### 🛠 Technical Users and Self-Hosters

Ideal for users who prefer full control over infrastructure, storage, and authentication.

### 📡 Hybrid Transport and Connectivity (Roadmap)

Future integrations with mesh networks, gateways, and alternative location sources for scenarios without traditional mobile coverage.

---

## Quick Installation

### Requirements

You will need:

- Linux or a Docker-compatible NAS
- Docker Engine
- Docker Compose v2
- `jq`
- `openssl`
- A domain or subdomains (recommended)
- Valid TLS certificates (recommended for production)
- **OwnTracks** app
- A compatible GeoJSON client (**Guru Maps recommended**)

Common supported environments:

- Synology NAS
- Ubuntu Server
- Debian
- Linux mini PCs
- Linux VPS
- Other Docker-compatible hosts

---

### Quick Start

Clone the repository:

```bash
git clone https://github.com/sercontri/nookmesh.git
cd nookmesh
```

Copy the example configuration:

```bash
cp config/users.example.json config/users.json
cp config/filtros.example.env config/filtros.env
cp config/recorder.example.env config/recorder.env
```

Edit the configuration according to your environment.

Generate credentials and operational files:

```bash
./auth/generate.sh
```

The generator automatically creates:

- MQTT credentials
- MQTT ACLs
- API tokens
- visibility runtime configuration
- operational user states

Start the services:

```bash
docker compose -f mqtt/docker-compose.yml up -d
docker compose -f recorder/docker-compose.yml up -d
docker compose -f worker/docker-compose.yml up -d
docker compose -f api/docker-compose.yml up -d
docker compose -f subscriptions/docker-compose.yml up -d
```

Configure:

- OwnTracks
- Guru Maps (or another compatible GeoJSON client)
- TLS (recommended)

NookMesh also includes a sample overlay for quick import into Guru Maps:

```text
docs/assets/gurumaps/nookmesh_gurumaps_overlay.ms
```

📘 Full setup instructions are available in the technical documentation.

---

## Privacy and Security

NookMesh is designed around a philosophy of privacy and data sovereignty.

With NookMesh:

- Your locations remain within your infrastructure
- Every user has independent MQTT credentials
- Every user receives an individual API token
- User visibility is controlled through internal rules
- Subscriptions and expirations are managed locally within your infrastructure
- Services can be protected with **MQTT over TLS** and **HTTPS**
- No mandatory dependency on external cloud platforms exists

Especially suited for users who value:

- privacy
- control
- transparency
- auditability
- self-hosting

## Documentation

The technical documentation includes:

- detailed installation
- users, states, and subscriptions
- visibility model
- OwnTracks integration
- Guru Maps integration
- MapCSS customization
- MQTT and TLS
- security and authentication
- GeoJSON endpoints
- internal architecture
- troubleshooting
- technical roadmap

📘 **[Complete Technical Documentation](docs/INDEX.md)**

## Roadmap

NookMesh is an actively evolving project.

Planned development areas include:

- hybrid mesh network integration
- LTE + mesh deployments
- support for additional GeoJSON clients
- web-based administration panel
- improved observability
- more modular configuration
- improved deployment experience
- Docusaurus documentation portal

## Contributing

Contributions are welcome.

You can help by:

- reporting bugs
- proposing improvements
- improving documentation
- suggesting integrations
- submitting pull requests
- sharing real-world use cases

If you contribute code:

- do not include secrets or real credentials
- use example files
- maintain consistency with the current architecture
- document relevant changes

## Support the Project

NookMesh is an independent project developed in personal time.

If you find it useful, you can support it by:

- ⭐ starring the repository
- 🐞 reporting bugs or improvements
- 📖 improving documentation
- 🔀 contributing code
- 📣 sharing the project
- ☕ supporting development on [Ko-fi](https://ko-fi.com/nooktrail)

Your support helps maintain testing infrastructure, improve documentation, and continue developing privacy-focused open-source tools.

## License

NookMesh is distributed under the **GNU Affero General Public License v3.0 (AGPLv3)**.

In summary:

- you may use it freely
- you may modify it
- you may deploy it on your infrastructure
- you may redistribute it
- you may offer services based on NookMesh while complying with AGPLv3 obligations

If you modify the project and provide it as a network-accessible service, those modifications must remain available under the same license.

See [LICENSE](LICENSE) for the full legal text.