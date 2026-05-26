# Quick Start

🇪🇸 [Versión en español](quickstart.es.md)

This guide shows the fastest path to validate a functional end-to-end NookMesh installation.

Goal: verify that a location sent from OwnTracks appears correctly in Guru Maps using your own infrastructure.

If you have not prepared the base environment yet, read first:

- [Requirements](requirements.md)
- [Installation](installation.md)

---

## What you will validate

By the end of this guide, you should have:

- a working NookMesh infrastructure
- a configured user
- OwnTracks publishing locations
- recorder persisting data
- worker generating GeoJSON
- protected API working
- Guru Maps displaying real locations

---

## 1. Prepare minimal configuration

Make sure you have created:

```text
config/users.json
config/recorder.env
config/filtros.env
```

and executed:

```bash
./auth/generate.sh
```

If not, go back to:

- [Installation](installation.md)

---

## 2. Start services

Launch the full stack:

```bash
docker compose -f mqtt/docker-compose.yml up -d
docker compose -f recorder/docker-compose.yml up -d
docker compose -f worker/docker-compose.yml up -d
docker compose -f api/docker-compose.yml up -d
```

Verify:

```bash
docker ps
```

You should see containers such as:

- `nookmesh-mqtt`
- `nookmesh-recorder`
- `nookmesh-worker`
- `nookmesh-api`

---

## 3. Configure OwnTracks

Install OwnTracks.

Official project:

https://owntracks.org/

Configure an existing user defined in:

```text
config/users.json
```

Recommended minimum configuration:

### Mode

```text
Private MQTT
```

### Host

Your MQTT broker:

```text
mqtt.yourdomain.com
```

### Port

Depending on your deployment:

Typical without TLS:

```text
1883
```

With TLS:

```text
8883
```

### Username

Example:

```text
sergio
```

### Password

The MQTT password configured for that user.

### Device ID

Examples:

```text
iphone
pixel
android
```

### Tracker ID

Examples:

```text
SE
RA
SA
```

---

## 4. Publish a test location

From OwnTracks, manually force a location update.

Expected flow:

```text
OwnTracks
→ MQTT
→ Recorder
→ Worker
→ API
```

---

## 5. Verify reception

### MQTT

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

### Persisted data

Check:

```text
data/owntracks/store/
```

---

### Generated GeoJSON

Check:

```text
data/public/nookmesh.geojson
```

---

## 6. Obtain API token

Check:

```text
config/generated/api-tokens.txt
```

Example:

```text
sergio:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Save the configured user’s token.

---

## 7. Verify the API directly

Before using Guru Maps:

```text
https://geojson.yourdomain.com/nookmesh.geojson?token=YOUR_TOKEN
```

You should receive valid GeoJSON.

---

## 8. Configure Guru Maps

Recommended option:

import the included overlay:

```text
docs/assets/gurumaps/nookmesh_gurumaps_overlay.ms
```

and adapt:

- GeoJSON endpoint
- token
- host

Detailed configuration:

- [Guru Maps](../integrations/gurumaps.md)

---

## 9. Final validation

If everything works:

✅ OwnTracks publishes  
✅ MQTT receives messages  
✅ Recorder persists data  
✅ Worker generates GeoJSON  
✅ API responds  
✅ Guru Maps displays locations  

---

## Next steps

Go deeper into:

- [Users](../configuration/users.md)
- [Visibility](../configuration/visibility.md)
- [TLS](../configuration/tls.md)
- [OwnTracks](../integrations/owntracks.md)
- [Guru Maps](../integrations/gurumaps.md)
- [API Authentication](../api/authentication.md)
