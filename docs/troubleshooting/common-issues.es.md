# Problemas comunes

🇬🇧 [English version](common-issues.md)

Esta guía recopila incidencias habituales y cómo diagnosticarlas.

Dado que NookMesh utiliza una arquitectura modular, los fallos suelen localizarse en una capa concreta del flujo.

Flujo general:

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

La forma más eficaz de diagnosticar problemas es identificar en qué punto se rompe el flujo.

---

# No veo ubicaciones en Guru Maps

🇬🇧 [English version](common-issues.md)

Síntoma:

```text
la capa carga pero no aparecen ubicaciones
```

Posibles causas:

- endpoint incorrecto
- token inválido
- GeoJSON vacío
- filtrado de visibilidad
- caché del cliente
- worker sin generar salida
- API no accesible

Revisar:

- URL exacta
- token API
- API activa
- respuesta GeoJSON
- logs del worker

---

## Comprobar endpoint manualmente

Abrir en navegador:

```text
https://geojson.tudominio.com/nookmesh.geojson?token=TU_TOKEN
```

Si devuelve:

```json
FeatureCollection
```

la API responde correctamente.

Si no:

el problema está en backend, autenticación o conectividad.

---

# OwnTracks conecta pero no aparecen datos

🇬🇧 [English version](common-issues.md)

Síntoma:

```text
OwnTracks parece conectado
pero no hay ubicaciones visibles
```

Posibles causas:

- recorder no consume
- worker no procesa
- timestamps inválidos
- filtros operativos
- token válido pero sin visibilidad

Revisar:

- logs recorder
- logs worker
- publicación MQTT
- timestamps
- filtros configurados

---

# OwnTracks no conecta al broker MQTT

🇬🇧 [English version](common-issues.md)

Síntomas:

- auth failed
- disconnected
- timeout
- reconnect loop

Revisar:

- host MQTT
- puerto
- DNS
- TLS
- usuario
- contraseña
- ACL MQTT

Logs:

```bash
docker logs nookmesh-mqtt
```

---

# Auth failed en MQTT

🇬🇧 [English version](common-issues.md)

Causas típicas:

- contraseña incorrecta
- usuario inexistente
- `mqtt-passwords.txt` desactualizado
- ACL incompatibles
- `generate.sh` no ejecutado tras cambios

Revisar:

```text
config/users.json
config/generated/mqtt-passwords.txt
config/generated/mqtt-acl.txt
```

Si has cambiado usuarios:

```bash
./auth/generate.sh
```

---

# Recorder no recibe mensajes

🇬🇧 [English version](common-issues.md)

Síntoma:

MQTT funciona pero recorder no procesa.

Revisar:

- conexión al broker
- credenciales recorder
- permisos MQTT
- topics correctos

Logs:

```bash
docker logs nookmesh-recorder
```

---

# Worker no genera GeoJSON

🇬🇧 [English version](common-issues.md)

Síntoma:

API responde pero datos vacíos o antiguos.

Posibles causas:

- recorder sin datos
- acceso incorrecto al store
- parsing fallido
- error interno del worker

Revisar:

```bash
docker logs nookmesh-worker
```

y comprobar:

```text
data/owntracks/store/last/
```

---

# API devuelve acceso denegado

🇬🇧 [English version](common-issues.md)

Síntoma:

```text
401
403
Unauthorized
Forbidden
```

Revisar:

- token correcto
- usuario existente
- usuario habilitado
- `api-tokens.txt` actualizado

Archivo:

```text
config/generated/api-tokens.txt
```

Si has cambiado usuarios:

```bash
./auth/generate.sh
```

---

# GeoJSON vacío

🇬🇧 [English version](common-issues.md)

Síntoma:

endpoint responde pero:

```json
"features": []
```

Posibles causas:

- sin ubicaciones recientes
- filtrado total por antigüedad
- usuario sin visibilidad
- exclusión por proximidad
- worker sin datos

Revisar:

```text
config/filtros.env
data/runtime/visibility.json
```

Parámetros especialmente relevantes:

```env
MAX_EDAD_MIN
EXCLUDE_NEARBY_METROS
EXCLUDE_VIEWER_IN_OUTPUT
```

---

# Un usuario no ve a otro

🇬🇧 [English version](common-issues.md)

Síntoma:

usuario autenticado correctamente
pero faltan ubicaciones esperadas

Causas frecuentes:

modelo de visibilidad.

Revisar:

```json
grupos
oculto_para
```

Ejemplo:

```json
"grupos": ["viaje1"]
"oculto_para": ["viaje1"]
```

Resultado:

pertenece al grupo pero no será visible a través de ese contexto.

---

# Datos desactualizados

🇬🇧 [English version](common-issues.md)

Síntoma:

ubicaciones antiguas o congeladas.

Posibles causas:

- OwnTracks no publica
- restricciones iOS
- restricciones Android
- ahorro de batería
- pérdida de conectividad

Revisar:

- timestamps
- permisos de localización
- ejecución en segundo plano
- optimización de batería

---

# Guru Maps no refresca

🇬🇧 [English version](common-issues.md)

Síntoma:

datos válidos pero visualización congelada.

Posibles causas:

- caché del cliente
- refresco limitado
- comportamiento de la app

Revisar:

- recargar capa
- cerrar y abrir Guru Maps
- verificar endpoint manualmente

---

# TLS no funciona

🇬🇧 [English version](common-issues.md)

Síntomas:

- conexión rechazada
- certificado inválido
- handshake error

Revisar:

- certificados
- hostname
- CA
- puertos
- configuración cliente

Relacionados:

```text
config/cert/
config/recorder.env
mqtt configuration
reverse proxy
```

---

# Docker containers caídos

🇬🇧 [English version](common-issues.md)

Comprobar:

```bash
docker ps
```

Servicios esperados:

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

# Problemas de DNS

🇬🇧 [English version](common-issues.md)

Síntomas:

- no conecta MQTT
- API inaccesible
- errores intermitentes

Comprobar:

```bash
nslookup geojson.tudominio.com
nslookup mqtt.tudominio.com
```

o:

```bash
dig geojson.tudominio.com
```

---

# generate.sh no refleja cambios

🇬🇧 [English version](common-issues.md)

Síntoma:

se modifica `users.json` pero el sistema sigue usando configuración antigua.

Revisar:

```bash
./auth/generate.sh
```

Este script actualiza:

- MQTT passwords
- MQTT ACL
- API tokens
- runtime visibility

También reinicia automáticamente servicios compatibles si están activos.

---

# Método de diagnóstico recomendado

🇬🇧 [English version](common-issues.md)

Orden:

## 1

¿OwnTracks publica?

---

## 2

¿MQTT recibe?

---

## 3

¿Recorder almacena?

---

## 4

¿Worker genera GeoJSON?

---

## 5

¿API responde con token válido?

---

## 6

¿Guru Maps consume correctamente?

---

# Si todo falla

🇬🇧 [English version](common-issues.md)

Recorre el pipeline completo:

```text
OwnTracks
→ MQTT
→ Recorder
→ Worker
→ API
→ Guru Maps
```

Diagnostica siempre por capas.

No asumas que el problema está en el cliente visual.