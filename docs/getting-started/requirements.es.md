# Requisitos

🇬🇧 [English version](requirements.md)

Antes de desplegar NookMesh, asegúrate de disponer de un entorno compatible y de los componentes necesarios.

---

## Infraestructura compatible

NookMesh está diseñado para ejecutarse en entornos Linux capaces de ejecutar contenedores Docker.

Entornos habituales compatibles:

- Synology NAS
- Ubuntu Server
- Debian
- mini PCs Linux
- VPS Linux
- otros hosts compatibles con Docker

NookMesh ha sido desarrollado y probado principalmente en entornos Linux autoalojados.

---

## Software requerido

### Docker

NookMesh utiliza una arquitectura modular basada en contenedores.

Necesitarás:

- Docker Engine
- soporte para `docker compose`

Comprobación:

```bash
docker --version
docker compose version
```

Referencia oficial:

https://www.docker.com/

---

### Utilidades del sistema

El generador de autenticación requiere:

- `jq`
- `openssl`

Comprobación:

```bash
jq --version
openssl version
```

Instalación habitual en Debian / Ubuntu:

```bash
sudo apt update
sudo apt install jq openssl
```

---

## Conectividad de red

### Acceso saliente a Internet

Recomendado durante instalación inicial.

Necesario para:

- descargar imágenes Docker
- ejecutar el contenedor auxiliar de generación si MQTT aún no está desplegado

Si todas las imágenes ya existen localmente y el broker MQTT está operativo, el acceso a Internet puede no ser necesario.

---

### DNS (recomendado)

Si vas a exponer servicios públicamente, se recomienda disponer de DNS funcional.

Ejemplos:

```text
mqtt.tudominio.com
geojson.tudominio.com
```

Los servicios pueden compartir host según tu reverse proxy o despliegue.

No es obligatorio para pruebas locales o entornos internos.

---

## Seguridad de transporte

Para despliegues reales se recomienda encarecidamente:

- MQTT sobre TLS
- HTTPS para la API

Opciones habituales:

- Let's Encrypt
- reverse proxy propio
- certificados internos

Para laboratorios locales o pruebas rápidas puede funcionar sin cifrado, aunque no es recomendable para uso real.

Consulta:

- [TLS](../configuration/tls.es.md)

---

## Clientes compatibles

### Publicación de ubicaciones

Actualmente NookMesh utiliza:

- [OwnTracks](https://owntracks.org/)

Compatible con:

- iPhone
- Android

---

### Visualización

NookMesh expone ubicaciones mediante GeoJSON.

La integración principal documentada actualmente es:

- [Guru Maps](https://gurumaps.app/)

Otros clientes compatibles con GeoJSON podrían integrarse en el futuro.

---

## Conocimientos recomendados

No es imprescindible experiencia avanzada, pero ayuda tener conocimientos básicos de:

- Docker
- redes
- DNS
- TLS / certificados
- terminal Linux
- edición de JSON
- variables de entorno

---

## Recursos hardware

Los requisitos exactos dependen del número de usuarios y frecuencia de publicación.

Para pequeños y medianos despliegues suele ser suficiente:

- NAS doméstico moderno
- mini PC Linux
- VPS básico
- servidor doméstico autoalojado

Carga típica del stack:

- Mosquitto (muy ligera)
- OwnTracks Recorder (ligera)
- worker GeoJSON con procesamiento periódico
- API FastAPI ligera

NookMesh no requiere hardware especialmente potente para grupos pequeños o medianos.