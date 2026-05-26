# Visión general de arquitectura

🇬🇧 [English version](overview.md)

NookMesh es una plataforma self-hosted de compartición de ubicación en tiempo real basada en componentes desacoplados que cooperan entre sí.

La arquitectura está diseñada con foco en:

- privacidad
- modularidad
- autoalojamiento
- seguridad
- interoperabilidad
- extensibilidad

---

## Flujo general

El flujo operativo actual es:

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
Clientes de visualización
```

En la práctica:

1. OwnTracks publica ubicaciones mediante MQTT
2. Mosquitto autentica y distribuye mensajes
3. OwnTracks Recorder persiste ubicaciones
4. El worker genera un GeoJSON enriquecido
5. La API autentica al consumidor mediante token
6. La API aplica reglas de visibilidad y filtros operativos
7. El cliente recibe únicamente datos autorizados

---

## Diagrama

![Arquitectura NookMesh](../assets/images/architecture-overview.png)

---

## Componentes principales

### OwnTracks

Cliente principal de captura de ubicación.

Responsabilidades:

- captura GPS
- detección de movimiento
- publicación MQTT
- envío de metadatos del dispositivo

Plataformas soportadas actualmente:

- iPhone / iPad
- Android

OwnTracks es actualmente la única fuente de ubicación oficialmente soportada.

---

### Broker MQTT

Backbone de mensajería interna.

Implementación actual:

```text
Mosquitto
```

Responsabilidades:

- autenticación MQTT
- validación de credenciales
- aplicación de ACL
- distribución de mensajes MQTT
- desacoplamiento entre productor y consumidor

Topics utilizados:

```text
owntracks/<usuario>/<device>
```

Ejemplo:

```text
owntracks/sergio/iphone
```

---

### OwnTracks Recorder

Servicio de persistencia primaria.

Responsabilidades:

- suscripción al broker MQTT
- recepción de eventos OwnTracks
- almacenamiento persistente
- mantenimiento del estado latest
- conservación del modelo nativo de recorder

Ubicación típica:

```text
data/owntracks/store/
```

Especialmente:

```text
data/owntracks/store/last/
```

Este componente no aplica:

- autenticación API
- reglas de visibilidad
- render visual

---

### Worker GeoJSON

Servicio de transformación.

Responsabilidades:

- lectura de ubicaciones persistidas
- carga del runtime de visibilidad
- cálculo de antigüedad
- enriquecimiento de metadatos
- generación de GeoJSON público
- preparación de propiedades visuales

Salida actual:

```text
data/public/nookmesh.geojson
```

El worker:

- filtra ubicaciones antiguas
- añade información contextual
- construye propiedades auxiliares para render

No aplica filtrado por viewer/token.

Ese trabajo ocurre en API.

---

### API protegida

Capa de acceso autenticado y filtrado dinámico.

Responsabilidades:

- autenticación por token API
- identificación del viewer
- aplicación de reglas de visibilidad
- filtrado contextual
- exclusión opcional de self
- filtrado por proximidad
- merge multi-dispositivo
- generación final del GeoJSON consumible

La API no entrega simplemente el GeoJSON bruto.

Entrega una versión:

```text
viewer-aware
```

filtrada según permisos del usuario autenticado.

---

### Generador de autenticación y runtime

Componente operativo central:

```text
auth/generate.sh
```

Responsabilidades:

- generación de password database MQTT
- generación de ACL MQTT
- generación y mantenimiento de tokens API
- regeneración selectiva
- limpieza de usuarios eliminados
- construcción de visibility runtime
- despliegue automático de archivos
- reinicio de servicios compatibles

Fuente única de verdad:

```text
config/users.json
```

Artefactos generados:

```text
config/generated/mqtt-passwords.txt
config/generated/mqtt-acl.txt
config/generated/api-tokens.txt
data/runtime/visibility.json
```

---

### Clientes de visualización

Consumidores finales.

Integración principal actual:

```text
Guru Maps
```

Consumido mediante:

```text
GeoJSON + MapCSS
```

La arquitectura permite potencialmente otros clientes compatibles con GeoJSON.

Ejemplos:

- clientes GIS
- dashboards web
- futuras integraciones

---

## Separación de responsabilidades

La arquitectura separa claramente capas funcionales.

### Captura

OwnTracks

---

### Transporte

Mosquitto / MQTT

---

### Persistencia

OwnTracks Recorder

---

### Transformación

Worker GeoJSON

---

### Autenticación y autorización

API protegida

---

### Provisionado operativo

auth/generate.sh

---

### Visualización

Guru Maps / clientes compatibles

---

## Filosofía arquitectónica

NookMesh evita un diseño monolítico.

Cada servicio mantiene una responsabilidad bien definida.

Ventajas:

- mantenimiento más simple
- debugging más claro
- despliegues modulares
- mejor aislamiento
- evolución independiente
- sustitución futura de componentes

---

## Principios de diseño

### Privacy-first

Los datos permanecen bajo control del propietario del despliegue.

---

### Self-hosted

Toda la infraestructura puede ejecutarse localmente o en infraestructura propia.

---

### Declarative configuration

La configuración operativa parte de:

```text
config/users.json
```

y se transforma automáticamente al runtime real.

---

### Least privilege

ACL MQTT, tokens API y visibilidad contextual reducen exposición innecesaria.

---

### Interoperabilidad

GeoJSON permite desacoplar backend y cliente final.

---

### Extensibilidad

La arquitectura facilita futuras evoluciones como:

- múltiples fuentes de ubicación
- dashboards web
- clientes alternativos
- arquitectura híbrida LTE + mesh

---

## Estado actual

Actualmente:

✅ arquitectura modular funcional  
✅ pipeline OwnTracks → MQTT → Recorder → Worker → API  
✅ autenticación MQTT  
✅ tokens API individuales  
✅ visibilidad contextual por usuario  
✅ render GeoJSON enriquecido  
✅ integración Guru Maps  

Roadmap:

- multi-source ingestion
- arquitectura híbrida
- nuevas fuentes de ubicación