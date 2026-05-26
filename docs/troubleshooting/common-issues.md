# Common Issues

🇪🇸 [Versión en español](common-issues.es.md)

This guide collects common issues and how to diagnose them.

Since NookMesh uses a modular architecture, failures are usually isolated to a specific layer in the pipeline.

General flow:

```text
OwnTracks
   ↓
MQTT
   ↓
Recorder
   ↓
Worker
   ↓
API
   ↓
Guru Maps
```

The most effective way to diagnose issues is to identify where the flow breaks.

---

# I can't see locations in Guru Maps

Symptom:

```text
the layer loads but no locations appear
```

Possible causes:

- incorrect endpoint
- invalid token
- empty GeoJSON
- visibility filtering
- client cache
- worker not generating output
- API not accessible

Check:

- exact URL
- API token
- API availability
- GeoJSON response
- worker logs

---

## Check the endpoint manually

Open in a browser:

```text
https://geojson.yourdomain.com/nookmesh.geojson?token=YOUR_TOKEN
```

If it returns:

```json
FeatureCollection
```

the API is responding correctly.

If not:

the problem is in the backend, authentication, or connectivity.

---

# OwnTracks connects but no data appears

Symptom:

```text
OwnTracks appears connected
but no locations are visible
```

Possible causes:

- recorder is not consuming messages
- worker is not processing data
- invalid timestamps
- operational filters
- valid token but no visibility permissions

Check:

- recorder logs
- worker logs
- MQTT publishing
- timestamps
- configured filters

---

# OwnTracks cannot connect to the MQTT broker

Symptoms:

- auth failed
- disconnected
- timeout
- reconnect loop

Check:

- MQTT host
- port
- DNS
- TLS
- username
- password
- MQTT ACL

Logs:

```bash
docker logs nookmesh-mqtt
```

---

# MQTT auth failed

Typical causes:

- incorrect password
- nonexistent user
- outdated `mqtt-passwords.txt`
- incompatible ACL rules
- `generate.sh` not run after changes

Check:

```text
config/users.json
config/generated/mqtt-passwords.txt
config/generated/mqtt-acl.txt
```

If you changed users:

```bash
./auth/generate.sh
```

---

# Recorder is not receiving messages

Symptom:

MQTT works but recorder does not process data.

Check:

- broker connection
- recorder credentials
- MQTT permissions
- correct topics

Logs:

```bash
docker logs nookmesh-recorder
```

---

# Worker does not generate GeoJSON

Symptom:

API responds but data is empty or stale.

Possible causes:

- recorder has no data
- incorrect access to the store
- parsing failure
- internal worker error

Check:

```bash
docker logs nookmesh-worker
```

and verify:

```text
data/owntracks/store/last/
```

---

# API returns access denied

Symptom:

```text
401
403
Unauthorized
Forbidden
```

Check:

- correct token
- existing user
- enabled user
- updated `api-tokens.txt`

File:

```text
config/generated/api-tokens.txt
```

If users were modified:

```bash
./auth/generate.sh
```

---

# Empty GeoJSON

Symptom:

endpoint responds but:

```json
"features": []
```

Possible causes:

- no recent locations
- full age-based filtering
- user has no visibility permissions
- proximity exclusion
- worker has no data

Check:

```text
config/filtros.env
data/runtime/visibility.json
```

Especially relevant parameters:

```env
MAX_EDAD_MIN
EXCLUDE_NEARBY_METROS
EXCLUDE_VIEWER_IN_OUTPUT
```

---

# One user cannot see another

Symptom:

user authenticates correctly
but expected locations are missing

Common cause:

visibility model configuration.

Check:

```json
grupos
oculto_para
```

Example:

```json
"grupos": ["trip1"]
"oculto_para": ["trip1"]
```

Result:

the user belongs to the group but will not be visible through that context.

---

# Stale data

Symptom:

old or frozen locations.

Possible causes:

- OwnTracks is not publishing
- iOS restrictions
- Android restrictions
- battery saving
- connectivity loss

Check:

- timestamps
- location permissions
- background execution
- battery optimization

---

# Guru Maps does not refresh

Symptom:

valid data exists but the display appears frozen.

Possible causes:

- client cache
- limited refresh behavior
- app-specific behavior

Check:

- reload the layer
- close and reopen Guru Maps
- verify the endpoint manually

---

# TLS does not work

Symptoms:

- connection rejected
- invalid certificate
- handshake error

Check:

- certificates
- hostname
- CA
- ports
- client configuration

Related:

```text
config/cert/
config/recorder.env
mqtt configuration
reverse proxy
```

---

# Docker containers are down

Check:

```bash
docker ps
```

Expected services:

```text
nookmesh-mqtt
nookmesh-recorder
nookmesh-worker
nookmesh-api
```

Logs:

```bash
docker logs nookmesh-mqtt
docker logs nookmesh-recorder
docker logs nookmesh-worker
docker logs nookmesh-api
```

---

# DNS problems

Symptoms:

- MQTT cannot connect
- API inaccessible
- intermittent errors

Check:

```bash
nslookup geojson.yourdomain.com
nslookup mqtt.yourdomain.com
```

or:

```bash
dig geojson.yourdomain.com
```

---

# generate.sh changes are not applied

Symptom:

`users.json` is modified but the system still uses old configuration.

Run:

```bash
./auth/generate.sh
```

This script updates:

- MQTT passwords
- MQTT ACL
- API tokens
- runtime visibility

It also automatically restarts compatible services if they are running.

---

# Recommended diagnostic method

Order:

## 1

Is OwnTracks publishing?

---

## 2

Is MQTT receiving?

---

## 3

Is Recorder storing data?

---

## 4

Is Worker generating GeoJSON?

---

## 5

Is the API responding with a valid token?

---

## 6

Is Guru Maps consuming it correctly?

---

# If everything fails

Walk through the full pipeline:

```text
OwnTracks
→ MQTT
→ Recorder
→ Worker
→ API
→ Guru Maps
```

Always diagnose layer by layer.

Do not assume the issue is in the visualization client.
