# TLS y seguridad de transporte

🇬🇧 [English version](tls.md)

NookMesh puede desplegarse de forma segura en entornos reales mediante cifrado de transporte y exposición controlada de servicios.

Aunque es posible realizar pruebas en entornos controlados sin cifrado, para despliegues reales se recomienda proteger todas las comunicaciones sensibles mediante TLS.

---

# Objetivo

🇬🇧 [English version](tls.md)

TLS protege:

- credenciales MQTT
- autenticación API
- tokens de acceso
- tráfico GeoJSON
- tráfico MapCSS protegido
- comunicación entre clientes y servicios expuestos

Esto reduce riesgos como:

- sniffing
- robo de credenciales
- ataques man-in-the-middle
- exposición accidental de ubicaciones

---

# Servicios que deberían protegerse

🇬🇧 [English version](tls.md)

En una instalación típica de NookMesh:

## Broker MQTT

Protección recomendada:

```text
MQTT sobre TLS
```

Protege:

- usuario MQTT
- contraseña MQTT
- tráfico OwnTracks
- mensajes MQTT

---

## API GeoJSON

Protección recomendada:

```text
HTTPS
```

Protege:

- tokens API
- tráfico GeoJSON
- datos de ubicación
- acceso autenticado

Ejemplo:

```text
https://geojson.tudominio.com/nookmesh.geojson?token=TOKEN
```

---

## Endpoint MapCSS

Si sirves estilos protegidos mediante token:

también debe protegerse con HTTPS.

Ejemplo:

```text
https://style.tudominio.com/nookmesh_v1.mapcss?token=TOKEN
```

Aunque el contenido sea solo un estilo visual, el token sigue siendo una credencial válida.

---

## Servicios futuros

Cualquier futura interfaz web o servicio adicional también debería exponerse mediante HTTPS.

---

# MQTT seguro

🇬🇧 [English version](tls.md)

Sin cifrado:

```text
MQTT en puerto 1883
```

Recomendado:

```text
MQTT sobre TLS en puerto 8883
```

Ejemplo:

```text
mqtt.tudominio.com:8883
```

Ventajas:

- cifrado del tráfico
- protección de credenciales
- mitigación de interceptación
- protección frente a redes inseguras

---

# API segura

🇬🇧 [English version](tls.md)

Sin cifrado:

```text
http://geojson.example.com
```

Recomendado:

```text
https://geojson.example.com
```

Muy importante:

NookMesh utiliza actualmente autenticación mediante token en query string:

```text
?token=TOKEN
```

Por tanto HTTPS no es opcional en despliegues reales.

Sin cifrado:

el token puede interceptarse fácilmente.

---

# Importante sobre tokens en URL

🇬🇧 [English version](tls.md)

HTTPS protege el transporte.

Pero no elimina otros riesgos operativos.

Ejemplos:

- logs de reverse proxy
- capturas de pantalla
- compartir URLs accidentalmente
- historial del navegador
- registros de debugging

Buenas prácticas:

- no compartir enlaces con tokens reales
- regenerar tokens si sospechas exposición
- usar tokens individuales por usuario

---

# Certificados

🇬🇧 [English version](tls.md)

## Let's Encrypt

Recomendado para despliegues públicos.

Ventajas:

- gratuito
- ampliamente soportado
- automatizable
- compatible con clientes móviles

---

## Reverse proxy

Opciones habituales:

- nginx
- Traefik
- Caddy

Permiten:

- terminación TLS
- renovación centralizada de certificados
- routing por dominio o subdominio
- simplificación operativa

Modelo habitual:

```text
Internet
   ↓
Reverse proxy HTTPS
   ↓
NookMesh API
```

---

## Certificados internos / self-signed

Útiles para:

- laboratorios
- redes privadas
- entornos aislados

Pero pueden complicar clientes móviles.

Especialmente:

- validación TLS en OwnTracks
- confianza del certificado
- instalación manual de CA

En despliegues públicos suele ser preferible usar CA pública.

---

# Topología recomendada

🇬🇧 [English version](tls.md)

Arquitectura típica:

```text
OwnTracks
   ↓
MQTT TLS
   ↓
Mosquitto
```

y:

```text
Guru Maps
   ↓
HTTPS
   ↓
GeoJSON API
```

y opcionalmente:

```text
Guru Maps
   ↓
HTTPS
   ↓
MapCSS endpoint
```

---

# Puertos habituales

🇬🇧 [English version](tls.md)

## MQTT sin TLS

```text
1883
```

---

## MQTT con TLS

```text
8883
```

---

## HTTPS

```text
443
```

---

# OwnTracks y TLS

🇬🇧 [English version](tls.md)

OwnTracks soporta MQTT seguro mediante TLS.

Configuración típica:

- host
- puerto seguro
- usuario MQTT
- contraseña MQTT
- TLS activado
- validación de certificado

Con certificados públicos:

normalmente funciona sin configuración compleja.

Con certificados self-signed:

puede requerir configuración manual adicional según plataforma.

---

# Seguridad API

🇬🇧 [English version](tls.md)

Además de HTTPS:

se recomienda:

- tokens API individuales
- endpoints mínimos expuestos
- no reutilizar tokens entre usuarios
- regenerar tokens ante sospecha
- evitar compartir URLs autenticadas

---

# Entornos de laboratorio

🇬🇧 [English version](tls.md)

Puede aceptarse temporalmente:

- HTTP
- MQTT sin TLS

solo para:

- pruebas locales
- debugging
- redes totalmente aisladas

No recomendado para uso real.

---

# Buenas prácticas

🇬🇧 [English version](tls.md)

## Nunca exponer servicios sensibles sin cifrado

Especialmente si son accesibles desde Internet.

---

## Usar HTTPS siempre

Para:

- GeoJSON
- MapCSS protegido
- cualquier endpoint autenticado

---

## Proteger MQTT

Nunca dejar el broker:

- abierto
- sin autenticación
- expuesto sin TLS

---

## Aplicar mínimo privilegio

TLS protege transporte.

No sustituye:

- ACL MQTT
- autenticación
- aislamiento de servicios
- tokens individuales

---

# Riesgos de no usar TLS

🇬🇧 [English version](tls.md)

Sin cifrado pueden exponerse:

- usuario MQTT
- contraseña MQTT
- tokens API
- tokens MapCSS
- ubicaciones
- metadatos del dispositivo
- tráfico autenticado