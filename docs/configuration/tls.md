# TLS and transport security

🇪🇸 [Versión en español](tls.es.md)

NookMesh can be deployed securely in real-world environments using encrypted transport and controlled service exposure.

While testing in controlled environments without encryption is possible, all sensitive communications should be protected with TLS in real deployments.

---

# Purpose

🇪🇸 [Versión en español](tls.es.md)

TLS protects:

- MQTT credentials
- API authentication
- access tokens
- GeoJSON traffic
- protected MapCSS traffic
- communication between clients and exposed services

This reduces risks such as:

- sniffing
- credential theft
- man-in-the-middle attacks
- accidental location exposure

---

# Services that should be protected

🇪🇸 [Versión en español](tls.es.md)

In a typical NookMesh deployment:

## MQTT broker

Recommended protection:

```text
MQTT over TLS
```

Protects:

- MQTT username
- MQTT password
- OwnTracks traffic
- MQTT messages

---

## GeoJSON API

Recommended protection:

```text
HTTPS
```

Protects:

- API tokens
- GeoJSON traffic
- location data
- authenticated access

Example:

```text
https://geojson.yourdomain.com/nookmesh.geojson?token=TOKEN
```

---

## MapCSS endpoint

If you serve protected styles using token authentication:

it should also be protected with HTTPS.

Example:

```text
https://style.yourdomain.com/nookmesh_v1.mapcss?token=TOKEN
```

Even if the content is only a visual style, the token remains a valid credential.

---

## Future services

Any future web interface or additional service should also be exposed via HTTPS.

---

# Secure MQTT

🇪🇸 [Versión en español](tls.es.md)

Without encryption:

```text
MQTT on port 1883
```

Recommended:

```text
MQTT over TLS on port 8883
```

Example:

```text
mqtt.yourdomain.com:8883
```

Benefits:

- encrypted traffic
- credential protection
- interception mitigation
- protection on untrusted networks

---

# Secure API

🇪🇸 [Versión en español](tls.es.md)

Without encryption:

```text
http://geojson.example.com
```

Recommended:

```text
https://geojson.example.com
```

Very important:

NookMesh currently uses token authentication via query string:

```text
?token=TOKEN
```

Therefore HTTPS is not optional in real deployments.

Without encryption:

the token can be intercepted easily.

---

# Important note about tokens in URLs

🇪🇸 [Versión en español](tls.es.md)

HTTPS protects transport.

But it does not eliminate other operational risks.

Examples:

- reverse proxy logs
- screenshots
- accidental URL sharing
- browser history
- debugging logs

Best practices:

- never share links containing real tokens
- regenerate tokens if exposure is suspected
- use individual tokens per user

---

# Certificates

🇪🇸 [Versión en español](tls.es.md)

## Let's Encrypt

Recommended for public deployments.

Benefits:

- free
- widely supported
- automatable
- compatible with mobile clients

---

## Reverse proxy

Common options:

- nginx
- Traefik
- Caddy

They provide:

- TLS termination
- centralized certificate renewal
- domain or subdomain routing
- operational simplification

Typical model:

```text
Internet
   ↓
HTTPS reverse proxy
   ↓
NookMesh API
```

---

## Internal / self-signed certificates

Useful for:

- lab environments
- private networks
- isolated deployments

But they may complicate mobile clients.

Especially:

- TLS validation in OwnTracks
- certificate trust
- manual CA installation

For public deployments, a public CA is usually preferable.

---

# Recommended topology

🇪🇸 [Versión en español](tls.es.md)

Typical architecture:

```text
OwnTracks
   ↓
MQTT TLS
   ↓
Mosquitto
```

and:

```text
Guru Maps
   ↓
HTTPS
   ↓
GeoJSON API
```

and optionally:

```text
Guru Maps
   ↓
HTTPS
   ↓
MapCSS endpoint
```

---

# Common ports

🇪🇸 [Versión en español](tls.es.md)

## MQTT without TLS

```text
1883
```

---

## MQTT with TLS

```text
8883
```

---

## HTTPS

```text
443
```

---

# OwnTracks and TLS

🇪🇸 [Versión en español](tls.es.md)

OwnTracks supports secure MQTT via TLS.

Typical configuration:

- host
- secure port
- MQTT username
- MQTT password
- TLS enabled
- certificate validation

With public certificates:

it usually works without complex configuration.

With self-signed certificates:

additional manual configuration may be required depending on platform.

---

# API security

🇪🇸 [Versión en español](tls.es.md)

In addition to HTTPS:

recommended practices include:

- individual API tokens
- minimal exposed endpoints
- never reusing tokens between users
- regenerating tokens when compromise is suspected
- avoiding sharing authenticated URLs

---

# Lab environments

🇪🇸 [Versión en español](tls.es.md)

Temporarily acceptable:

- HTTP
- MQTT without TLS

Only for:

- local testing
- debugging
- fully isolated networks

Not recommended for real usage.

---

# Best practices

🇪🇸 [Versión en español](tls.es.md)

## Never expose sensitive services without encryption

Especially if accessible from the Internet.

---

## Always use HTTPS

For:

- GeoJSON
- protected MapCSS
- any authenticated endpoint

---

## Protect MQTT

Never leave the broker:

- open
- unauthenticated
- exposed without TLS

---

## Apply least privilege

TLS protects transport.

It does not replace:

- MQTT ACLs
- authentication
- service isolation
- individual tokens

---

# Risks of not using TLS

🇪🇸 [Versión en español](tls.es.md)

Without encryption, the following may be exposed:

- MQTT username
- MQTT password
- API tokens
- MapCSS tokens
- locations
- device metadata
- authenticated traffic