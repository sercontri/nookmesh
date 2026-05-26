# Componentes

🇬🇧 [English version](components.md)

Este documento describe los componentes principales que forman la arquitectura actual de NookMesh y su responsabilidad dentro del sistema.

---

## Visión general

Arquitectura actual:

```text
OwnTracks
   ↓
Broker MQTT (Mosquitto)
   ↓
OwnTracks Recorder
   ↓
Worker GeoJSON
   ↓
API protegida
   ↓
Guru Maps / clientes compatibles
```

Cada componente mantiene una responsabilidad claramente desacoplada.

---

## OwnTracks

Cliente principal de captura y publicación de ubicaciones.

### Responsabilidades

- capturar posición GPS
- detectar movimiento
- gestionar precisión
- recopilar metadatos del dispositivo
- publicar mensajes MQTT

### Datos típicos enviados

Ejemplo:

```json
{
  "_type": "location",
  "lat": 38.561445,
  "lon": -0.212222,
  "tid": "SA",
  "batt": 80,
  "vel": 10,
  "cog": 221,
  "acc": 13,
  "conn": "m"
}
```

### Dependencias

- broker MQTT accesible
- credenciales MQTT válidas
- configuración correcta del cliente

### Estado actual

Actualmente es la única fuente de ubicación oficialmente soportada.

---

## Broker MQTT

Implementación actual:

```text
Mosquitto
```

Actúa como backbone de mensajería interna.

### Responsabilidades

- recepción de publicaciones OwnTracks
- autenticación de clientes MQTT
- aplicación de ACL
- distribución de mensajes
- desacoplamiento entre productor y consumidor

### Entradas

Mensajes MQTT publicados por clientes.

Ejemplo:

```text
owntracks/sergio/iphone
```

### Salidas

Eventos MQTT consumidos por OwnTracks Recorder.

---

## OwnTracks Recorder

Servicio de persistencia primaria.

### Responsabilidades

- suscribirse al broker MQTT
- consumir mensajes OwnTracks
- persistir ubicaciones
- mantener últimas posiciones por dispositivo

### Entradas

Mensajes MQTT.

### Salidas

Persistencia en:

```text
data/owntracks/store/
```

incluyendo:

```text
data/owntracks/store/last/
```

Ejemplo real:

```text
data/owntracks/store/last/sergio/iphone/sergio-iphone.json
```

### Observaciones

Recorder no aplica:

- autenticación API
- reglas de visibilidad
- render visual

Su responsabilidad es persistencia.

---

## Worker GeoJSON

Servicio de transformación y enriquecimiento.

### Responsabilidades

- leer últimas ubicaciones persistidas
- cargar configuración runtime
- aplicar filtros operativos base
- descartar ubicaciones antiguas
- enriquecer propiedades GeoJSON
- generar GeoJSON público base

### Entradas

Datos del recorder:

```text
data/owntracks/store/last/
```

Configuración:

```text
data/runtime/visibility.json
config/filtros.env
```

### Salidas

GeoJSON generado en:

```text
data/public/nookmesh.geojson
```

### Procesamiento típico

Incluye:

- cálculo de antigüedad
- heading / rumbo
- velocidad
- batería
- precisión
- conectividad
- información de dispositivo
- descripciones enriquecidas
- propiedades auxiliares de render

### Importante

El worker NO aplica:

- visibilidad relacional por viewer
- autenticación
- merge multi-dispositivo contextual
- filtrado por proximidad entre usuarios

Ese trabajo ocurre en API.

---

## API protegida

Capa HTTP de exposición autenticada y filtrado dinámico.

### Responsabilidades

- autenticación mediante token API
- identificación del viewer
- aplicación de reglas de visibilidad
- filtrado contextual por usuario
- exclusión opcional del propio viewer
- filtrado por proximidad
- merge multi-dispositivo
- generación del GeoJSON final consumible
- servicio opcional de recursos auxiliares

### Entradas

Solicitudes HTTP autenticadas.

GeoJSON base:

```text
data/public/nookmesh.geojson
```

Runtime:

```text
data/runtime/visibility.json
```

### Salidas

Recursos como:

```text
nookmesh.geojson
nookmesh_v1.mapcss
```

### Importante

La API no entrega simplemente el GeoJSON generado por el worker.

Construye una salida final específica para el viewer autenticado.

---

## Auth Generator

Componente operativo de automatización.

Script principal:

```text
auth/generate.sh
```

### Responsabilidades

- generar password database MQTT
- generar ACL MQTT
- generar tokens API
- conservar tokens existentes
- regenerar tokens selectivamente
- eliminar tokens de usuarios borrados
- generar runtime de visibilidad
- desplegar archivos generados
- reiniciar servicios compatibles

### Entradas

Configuración declarativa:

```text
config/users.json
```

### Salidas

Archivos generados:

```text
config/generated/mqtt-passwords.txt
config/generated/mqtt-acl.txt
config/generated/api-tokens.txt
data/runtime/visibility.json
```

---

## Configuración

Conjunto de archivos persistentes editables.

### Archivos principales

```text
config/users.json
config/filtros.env
config/recorder.env
```

### Responsabilidades

- definición de usuarios
- credenciales MQTT
- grupos
- reglas de ocultación
- roles
- configuración recorder
- parámetros operativos del pipeline

---

## Persistencia y runtime

Estructura:

```text
data/
├── owntracks/
├── public/
└── runtime/
```

### `data/owntracks/`

Persistencia de OwnTracks Recorder.

---

### `data/public/`

Artefactos consumibles por clientes.

Ejemplo:

```text
nookmesh.geojson
nookmesh_v1.mapcss
```

---

### `data/runtime/`

Estado generado dinámicamente.

Ejemplo:

```text
visibility.json
```

---

## Guru Maps

Cliente principal de visualización actual.

### Responsabilidades

- consumir GeoJSON autenticado
- aplicar estilos MapCSS
- renderizar iconos y etiquetas
- mostrar metadatos enriquecidos

### Integración actual

Basada en:

- GeoJSON
- MapCSS
- overlay importable

Plantilla incluida:

```text
docs/assets/gurumaps/nookmesh_gurumaps_overlay.ms
```

---

## Futuras extensiones

La arquitectura facilita futuras evoluciones como:

- fuentes alternativas de ubicación
- dashboards web
- clientes GeoJSON adicionales
- arquitectura híbrida multi-transporte

---

## Filosofía de separación

NookMesh separa claramente responsabilidades:

### Captura

OwnTracks

---

### Transporte

MQTT / Mosquitto

---

### Persistencia

OwnTracks Recorder

---

### Transformación

Worker GeoJSON

---

### Autenticación y filtrado contextual

API protegida

---

### Provisionado operativo

Auth Generator

---

### Visualización

Guru Maps / clientes compatibles

---

## Beneficios del diseño

Esta separación facilita:

- debugging
- troubleshooting
- evolución independiente
- endurecimiento de seguridad
- modularidad
- sustitución futura de componentes
