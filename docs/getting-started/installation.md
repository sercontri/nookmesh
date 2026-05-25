# Installation

This document describes the base installation process for NookMesh on a Linux environment or Docker-compatible NAS.

Advanced configuration for users, visibility, security, and integrations is documented in dedicated sections.

---

## General installation flow

The recommended process is:

1. Clone the repository
2. Prepare configuration files
3. Configure users and core services
4. Generate credentials and operational files
5. Deploy services
6. Validate the stack
7. Configure clients (OwnTracks and Guru Maps)

---

## Clone the repository

Download the source code:

```bash
git clone https://github.com/sercontri/nookmesh.git
cd nookmesh
```

---

## Project structure

NookMesh is organized as a modular architecture based on independent services.

```text
nookmesh/
├── mqtt/
├── recorder/
├── worker/
├── api/
├── auth/
├── config/
├── data/
└── docs/
```

Overview:

- **mqtt/** → MQTT broker (Mosquitto)
- **recorder/** → OwnTracks location persistence
- **worker/** → GeoJSON generation and enrichment
- **api/** → protected API for client consumption
- **auth/** → automatic credential, ACL, token, and runtime generation
- **config/** → editable configuration
- **data/** → persistent storage and operational data
- **docs/** → technical documentation

---

## Prepare initial configuration

Copy the example files:

```bash
cp config/users.example.json config/users.json
cp config/recorder.example.env config/recorder.env
cp config/filtros.example.env config/filtros.env
```

These files must be adapted to your environment before deployment.

---

## Configure users

Edit:

```text
config/users.json
```

This file defines:

- human users
- internal system users
- MQTT credentials
- administrative permissions
- visibility groups
- hiding rules
- API token behavior

Important:

- the internal `recorder` user must exist
- at least one enabled human user must exist

The full structure is documented in:

- [Users](../configuration/users.md)

---

## Configure recorder

Edit:

```text
config/recorder.env
```

This file defines OwnTracks Recorder service configuration.

It includes parameters such as:

- MQTT host
- MQTT port
- recorder credentials
- storage
- recorder operational settings

Important:

without correct recorder configuration, NookMesh will not be able to receive or persist locations.

---

## Configure filters (optional initially)

Edit:

```text
config/filtros.env
```

This file controls operational parameters for GeoJSON processing, such as time filters, aggregation behavior, or operational limits.

It can be adjusted later if you want a faster initial deployment.

After modifying this file, you must restart:

- `nookmesh-worker`
- `nookmesh-api`

---

## Generate credentials and runtime

Once the base files are configured:

```bash
./auth/generate.sh
```

This process automatically generates:

```text
config/generated/mqtt-passwords.txt
config/generated/mqtt-acl.txt
config/generated/api-tokens.txt
data/runtime/visibility.json
```

Additionally, it:

- processes declarative user configuration
- generates MQTT credentials
- builds ACL rules
- creates individual API access tokens
- generates runtime configuration used by the API

If the main MQTT broker is not yet deployed, the process will use a temporary helper container to complete generation.

---

## Deploy services

NookMesh uses a multi-compose architecture with independent services.

Recommended order:

### 1. MQTT broker

```bash
docker compose -f mqtt/docker-compose.yml up -d
```

---

### 2. OwnTracks Recorder

```bash
docker compose -f recorder/docker-compose.yml up -d
```

---

### 3. GeoJSON worker

```bash
docker compose -f worker/docker-compose.yml up -d
```

---

### 4. API

```bash
docker compose -f api/docker-compose.yml up -d
```

---

## Verify deployment

Check active containers:

```bash
docker ps
```

You should see containers such as:

- `nookmesh-mqtt`
- `nookmesh-recorder`
- `nookmesh-worker`
- `nookmesh-api`

---

## Verify generated files

Check:

```bash
ls config/generated
```

Expected output:

```text
api-tokens.txt
mqtt-acl.txt
mqtt-passwords.txt
```

And runtime:

```bash
ls data/runtime
```

Expected output:

```text
visibility.json
```

---

## Recommended security

For real deployments, the following is recommended:

- MQTT over TLS
- HTTPS for the API
- unique credentials per user
- do not reuse example passwords
- do not expose services without authentication

TLS configuration is documented in:

- [TLS](../configuration/tls.md)

---

## Next step

Once the base infrastructure is deployed:

1. Configure OwnTracks
2. Publish a test location
3. Verify recorder persistence
4. Verify GeoJSON generation
5. Configure Guru Maps
6. Validate the full end-to-end flow

Continue with:

- [Quick start](quickstart.md)
- [OwnTracks](../integrations/owntracks.md)
- [Guru Maps](../integrations/gurumaps.md)