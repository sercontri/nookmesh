# NookMesh

🇪🇸 [Versión en español](README.es.md)

![License](https://img.shields.io/github/license/sercontri/nookmesh)
![Last Commit](https://img.shields.io/github/last-commit/sercontri/nookmesh)
![Stars](https://img.shields.io/github/stars/sercontri/nookmesh)
[![Ko-fi](https://img.shields.io/badge/Support-Ko--fi-ff5f5f?logo=ko-fi&logoColor=white)](https://ko-fi.com/nooktrail)

**Self-hosted real-time location sharing with full privacy and complete control over your data.**

NookMesh is an open source real-time location sharing platform built around **OwnTracks**, **MQTT**, **Docker**, and a protected **GeoJSON API**, designed for people who want full control over their infrastructure, authentication, and location data.

It originally started as a motorcycle group travel project, but its modular architecture makes it adaptable to families, outdoor groups, technical teams, and future hybrid location architectures with multiple location sources.

> ⚠️ Active project under ongoing development. The core architecture is functional and usable, though some capabilities are still being refined.

---

## NookMesh in action

![NookMesh running in Guru Maps](docs/assets/images/nookmesh-gurumaps-main.png)

---

## Features

- Real-time location tracking using **OwnTracks + MQTT**
- **100% self-hosted** infrastructure
- Protected GeoJSON API with per-user authentication
- Direct visualization in **Guru Maps**
- Multi-user and multi-device support
- Advanced per-user visibility control
- Modular Docker-based architecture
- Secure deployment with TLS (recommended)
- Foundation for future hybrid integrations

---

## Current stack

NookMesh currently uses:

- OwnTracks
- Mosquitto
- OwnTracks Recorder
- FastAPI
- Docker
- GeoJSON
- Guru Maps

---

## How it works

NookMesh receives location updates from mobile devices via **OwnTracks**, processes them inside your own infrastructure, and exposes only authorized data to compatible clients.

All authentication, visibility filtering, and access control happen entirely in your own backend.

![NookMesh architecture](docs/assets/images/architecture-overview.en.png)

📘 Full architecture documentation is available in the technical docs.

---

## Use cases

### 🏍 Motorcycle trips and group rides

Track your riding companions in real time directly inside Guru Maps.

### 👨‍👩‍👧‍👦 Family and friends

Share live location with trusted people using customizable visibility rules.

### 🥾 Outdoor activities

Hiking, cycling, 4x4, or any activity where real-time coordination is useful.

### 🛠 Technical users and self-hosters

Ideal for users who prefer full control over infrastructure, storage, authentication, and deployment.

### 📡 Hybrid transport (roadmap)

Future integrations with mesh networks, gateways, and alternative location sources for scenarios without conventional mobile coverage.

---

## Quick installation

### Requirements

You will need:

- Linux or Docker-compatible NAS
- Docker Engine
- Docker Compose v2
- `jq`
- `openssl`
- Domain or subdomains (recommended)
- Valid TLS certificates (recommended for production)
- **OwnTracks** app
- GeoJSON-compatible client (**Guru Maps recommended**)

Common compatible environments:

- Synology NAS
- Ubuntu Server
- Debian
- Linux mini PCs
- Linux VPS
- other Docker-compatible Linux hosts

---

### Quick start

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

Edit the configuration to match your environment.

Generate credentials and runtime files:

```bash
./auth/generate.sh
```

Start the services:

```bash
docker compose -f mqtt/docker-compose.yml up -d
docker compose -f recorder/docker-compose.yml up -d
docker compose -f worker/docker-compose.yml up -d
docker compose -f api/docker-compose.yml up -d
```

Configure:

- OwnTracks
- Guru Maps (or another GeoJSON-compatible client)
- TLS (recommended)

NookMesh also includes a ready-to-import example overlay for Guru Maps:

```text
docs/assets/gurumaps/nookmesh_gurumaps_overlay.ms
```

📘 Full setup instructions are available in the technical documentation.

---

## Privacy and security

NookMesh is built around a privacy-first and data-sovereignty mindset.

With NookMesh:

- Your location data stays on your infrastructure
- Each user gets independent MQTT credentials
- Each user gets an individual API token
- Visibility between users is controlled through internal rules
- Services can be protected with **MQTT over TLS** and **HTTPS**
- No mandatory dependency on third-party cloud platforms

Especially suitable for users who value:

- privacy
- control
- transparency
- auditability
- self-hosting

---

## Documentation

Technical documentation includes:

- detailed installation
- user configuration
- visibility model
- OwnTracks integration
- Guru Maps integration
- visual customization with MapCSS
- MQTT and TLS
- security and authentication
- GeoJSON endpoints
- internal architecture
- troubleshooting
- technical roadmap

📘 **[Full technical documentation](docs/INDEX.md)**

---

## Roadmap

NookMesh is an active evolving project.

Planned areas of development:

- hybrid mesh integrations
- LTE + mesh deployments
- support for more GeoJSON clients
- administration tools
- improved observability
- more modular configuration
- easier deployment experience
- web documentation portal (Docusaurus)

---

## Contributing

Contributions are welcome.

You can help by:

- reporting bugs
- proposing improvements
- improving documentation
- suggesting integrations
- submitting pull requests
- sharing real-world use cases

If contributing code:

- do not include secrets or real credentials
- use example configuration files
- keep consistency with the current architecture
- document relevant changes

---

## Support the project

NookMesh is an independent project developed in personal time.

If you find it useful, you can support it by:

- ⭐ starring the repository
- 🐞 reporting bugs or improvements
- 📖 improving documentation
- 🔀 contributing code
- 📣 sharing the project
- ☕ supporting development on [Ko-fi](https://ko-fi.com/nooktrail)

Your support helps maintain test infrastructure, improve documentation, and continue developing privacy-focused open tools.

---

## License

NookMesh is distributed under the **GNU Affero General Public License v3.0 (AGPLv3)**.

In short:

- you can use it freely
- you can modify it
- you can deploy it on your own infrastructure
- you can redistribute it
- you can offer services based on NookMesh, respecting AGPLv3 obligations

If you modify the project and make it available as a network-accessible service, those modifications must remain under the same license.

See [LICENSE](LICENSE) for the full legal text.