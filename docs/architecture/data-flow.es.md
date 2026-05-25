# Flujo de datos

Este documento describe el recorrido completo de una ubicación desde el dispositivo del usuario hasta su visualización final en el cliente.

---

## Resumen visual

```text
OwnTracks
   ↓
MQTT publish
   ↓
Broker MQTT (Mosquitto)
   ↓
OwnTracks Recorder
   ↓
Persistencia
   ↓
Worker GeoJSON
   ↓
API protegida
   ↓
Guru Maps / cliente compatible
```

---

## Flujo completo

## 1. Captura de ubicación

El dispositivo obtiene una posición mediante GPS y sensores del sistema operativo.

Información típica:

- latitud
- longitud
- precisión
- altitud
- velocidad
- rumbo
- batería
- estado de conexión
- timestamp
- tracker ID (`tid`)

Ejemplo:

```json
{
  "_type": "location",
  "lat": 38.561445,
  "lon": -0.212222,
  "acc": 13,
  "alt": 683,
  "vel": 10,
  "cog": 221,
  "batt": 80,
  "conn": "m",
  "tst": 1779701034,
  "tid": "SA"
}
```

---

## 2. Publicación MQTT

OwnTracks publica el evento al broker MQTT.

Ejemplo:

```text
owntracks/sandra/iphone
```

En este punto:

- el cliente debe autenticarse correctamente
- la ACL debe permitir publicación
- la conectividad debe estar operativa

---

## 3. Recepción en broker MQTT

Mosquitto recibe el mensaje y valida:

- usuario MQTT
- contraseña
- ACL
- topic permitido

Si la validación es correcta:

el mensaje se distribuye a suscriptores autorizados.

---

## 4. Consumo por Recorder

OwnTracks Recorder consume el mensaje MQTT.

Responsabilidades:

- interpretar payload OwnTracks
- persistir evento
- mantener últimas posiciones por dispositivo

Aquí no existe:

- filtrado de visibilidad
- autenticación API
- lógica visual

---

## 5. Persistencia

Los datos quedan almacenados en:

```text
data/owntracks/store/
```

Incluyendo:

```text
data/owntracks/store/last/
```

Ejemplo real:

```text
data/owntracks/store/last/sergio/iphone/sergio-iphone.json
```

Esta persistencia actúa como fuente operativa del pipeline posterior.

---

## 6. Configuración runtime

NookMesh mantiene artefactos runtime generados automáticamente.

Archivos relevantes:

```text
config/generated/api-tokens.txt
data/runtime/visibility.json
```

Generados mediante:

```bash
./auth/generate.sh
```

Estos determinan:

- autenticación API
- usuarios válidos
- grupos
- ocultaciones
- roles

---

## 7. Procesamiento por worker

El worker consulta últimas posiciones persistidas y construye el GeoJSON base.

Entradas:

```text
data/owntracks/store/last/
config/filtros.env
data/runtime/visibility.json
```

Procesamiento típico:

- lectura de última posición
- cálculo de antigüedad
- interpretación de conectividad
- interpretación de movimiento
- enriquecimiento de propiedades
- construcción de descripciones contextuales
- descarte de ubicaciones antiguas

---

## 8. Generación GeoJSON base

El worker genera:

```text
data/public/nookmesh.geojson
```

Formato:

```json
{
  "type": "FeatureCollection",
  "features": [...]
}
```

Este GeoJSON contiene información enriquecida pero todavía no está filtrado por usuario consumidor.

Puede incluir:

- nombre
- tid
- timestamps
- edad
- rumbo
- grupos
- rol
- precisión
- stroke visual
- descripción enriquecida

---

## 9. Solicitud cliente

Un cliente realiza una petición autenticada.

Ejemplo:

```text
https://geojson.tudominio.com/nookmesh.geojson?token=TOKEN
```

---

## 10. Autenticación API

La API valida:

- token API
- usuario asociado al token
- existencia en runtime

Si la autenticación falla:

acceso denegado.

---

## 11. Resolución de visibilidad

La API determina:

- grupos del viewer
- grupos del usuario evaluado
- exclusiones `oculto_para`

Modelo conceptual:

```text
shared_groups - hidden_for
```

Si no existen grupos visibles:

la ubicación se excluye.

---

## 12. Aplicación de filtros operativos contextuales

La API puede aplicar además:

- exclusión del propio usuario (`EXCLUDE_VIEWER_IN_OUTPUT`)
- filtrado por proximidad (`EXCLUDE_NEARBY_METROS`)
- validación de posición reciente del viewer
- merge multi-dispositivo (`MERGE_CLOSEST_DEVICES`)

Caso importante:

si:

```env
REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY=true
```

y el viewer no tiene posición reciente:

la API devuelve resultado vacío.

---

## 13. Construcción del GeoJSON final

La API genera el GeoJSON final consumible.

Transforma cada entidad visible en múltiples features visuales.

Ejemplo conceptual:

### Icono

```json
"render": "icon"
```

Incluye:

- SVG dinámico
- tooltip descriptivo

---

### Label

```json
"render": "label"
```

Incluye:

- `tid`
- texto visual

---

Resultado:

GeoJSON específico para ese viewer autenticado.

---

## 14. Renderizado cliente

Guru Maps consume el resultado y aplica representación visual.

Dependiendo del estilo:

- iconos
- etiquetas
- SVG
- tooltips
- render condicional

El cliente nunca decide permisos de acceso.

Solo representa el resultado autorizado.

---

## Flujo resumido por responsabilidades

### Captura

OwnTracks

---

### Transporte

MQTT

---

### Validación transporte

Mosquitto

---

### Persistencia

OwnTracks Recorder

---

### Transformación base

Worker

---

### Autenticación y filtrado contextual

API protegida

---

### Visualización

Guru Maps / clientes compatibles

---

## Posibles puntos de fallo

### No llegan datos

Revisar:

- OwnTracks
- credenciales MQTT
- conectividad
- ACL broker

---

### Recorder no almacena

Revisar:

- suscripción MQTT
- logs recorder
- configuración recorder
- mounts

---

### No se genera GeoJSON base

Revisar:

- worker
- rutas montadas
- permisos
- timestamps
- `MAX_EDAD_MIN`

---

### API devuelve vacío

Revisar:

- token
- visibilidad
- filtros operativos
- proximidad
- viewer sin posición reciente

Regenerar si aplica:

```bash
./auth/generate.sh
```

---

### Guru Maps no muestra ubicaciones

Revisar:

- endpoint
- token válido
- conectividad
- formato GeoJSON
- estilo MapCSS
- caché cliente