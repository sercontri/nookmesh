# Requirements

🇪🇸 [Versión en español](requirements.es.md)

Before deploying NookMesh, make sure you have a compatible environment and the required components.

---

## Compatible infrastructure

NookMesh is designed to run on Linux environments capable of running Docker containers.

Common compatible environments:

- Synology NAS
- Ubuntu Server
- Debian
- Linux mini PCs
- Linux VPS
- other Docker-compatible hosts

NookMesh has been primarily developed and tested in self-hosted Linux environments.

---

## Required software

### Docker

NookMesh uses a modular container-based architecture.

You will need:

- Docker Engine
- `docker compose` support

Verification:

```bash
docker --version
docker compose version
```

Official reference:

https://www.docker.com/

---

### System utilities

The authentication generator requires:

- `jq`
- `openssl`

Verification:

```bash
jq --version
openssl version
```

Typical installation on Debian / Ubuntu:

```bash
sudo apt update
sudo apt install jq openssl
```

---

## Network connectivity

### Outbound Internet access

Recommended during initial installation.

Required for:

- downloading Docker images
- running the helper generation container if MQTT is not yet deployed

If all required images already exist locally and the MQTT broker is already operational, Internet access may not be necessary.

---

### DNS (recommended)

If you plan to expose services publicly, functional DNS is recommended.

Examples:

```text
mqtt.yourdomain.com
geojson.yourdomain.com
```

Services may share the same host depending on your reverse proxy or deployment design.

Not required for local testing or internal environments.

---

## Transport security

For real deployments, the following is strongly recommended:

- MQTT over TLS
- HTTPS for the API

Common options:

- Let's Encrypt
- your own reverse proxy
- internal certificates

For local labs or quick testing, unencrypted operation may work, although it is not recommended for real-world use.

See:

- [TLS](../configuration/tls.md)

---

## Compatible clients

### Location publishing

NookMesh currently uses:

- [OwnTracks](https://owntracks.org/)

Compatible with:

- iPhone
- Android

---

### Visualization

NookMesh exposes locations through GeoJSON.

The primary documented integration is currently:

- [Guru Maps](https://gurumaps.app/)

Other GeoJSON-compatible clients may be integrated in the future.

---

## Recommended knowledge

Advanced experience is not required, but basic familiarity helps with:

- Docker
- networking
- DNS
- TLS / certificates
- Linux terminal
- JSON editing
- environment variables

---

## Hardware resources

Exact requirements depend on the number of users and publishing frequency.

For small to medium deployments, the following is usually sufficient:

- modern home NAS
- Linux mini PC
- basic VPS
- self-hosted home server

Typical stack load:

- Mosquitto (very lightweight)
- OwnTracks Recorder (lightweight)
- GeoJSON worker with periodic processing
- lightweight FastAPI service

NookMesh does not require especially powerful hardware for small or medium groups.
