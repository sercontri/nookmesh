# Persistencia y almacenamiento

🇬🇧 [English version](persistence.md)

NookMesh separa código, configuración y datos operativos persistentes para mantener una arquitectura modular, mantenible y adecuada para despliegues reales.

---

## Objetivo

Separar almacenamiento persistente permite:

- conservar estado entre reinicios
- desacoplar datos del ciclo de vida de contenedores
- simplificar backups
- facilitar troubleshooting
- mantener una arquitectura modular

---

## Estructura general

```text
nookmesh/
├── api/
├── auth/
├── config/
│   └── generated/
├── data/
│   ├── owntracks/
│   ├── public/
│   └── runtime/
├── docs/
├── mqtt/
├── recorder/
└── worker/
```

---

## Separación conceptual

### Código

Implementación del sistema:

```text
api/
auth/
mqtt/
recorder/
worker/
```

---

### Configuración fuente

Configuración editable gestionada manualmente:

```text
config/
```

Ejemplo:

- usuarios
- filtros operativos
- configuración recorder
- certificados TLS

Archivos típicos:

```text
config/users.json
config/filtros.env
config/recorder.env
```

---

### Configuración generada

Artefactos operativos derivados automáticamente:

```text
config/generated/
```

Ejemplo:

```text
mqtt-passwords.txt
mqtt-acl.txt
api-tokens.txt
```

Estos archivos no deberían editarse manualmente.

---

### Datos operativos

Persistencia y artefactos runtime:

```text
data/
```

---

## data/owntracks

Persistencia de OwnTracks Recorder.

Corresponde al almacenamiento operativo del recorder.

Ruta relevante:

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

Puede contener:

- últimas ubicaciones por dispositivo
- estructuras internas del recorder
- histórico mantenido por OwnTracks Recorder

Es la fuente primaria del pipeline de transformación.

---

## data/public

Artefactos consumibles por clientes.

Ejemplo actual:

```text
data/public/
├── nookmesh.geojson
└── nookmesh_v1.mapcss
```

---

### nookmesh.geojson

Generado automáticamente por el worker:

```text
data/public/nookmesh.geojson
```

Contiene el GeoJSON base enriquecido usado por la API.

No representa necesariamente el resultado final entregado al cliente autenticado.

---

### nookmesh_v1.mapcss

Asset visual editable servido para clientes compatibles.

Ejemplo:

```text
data/public/nookmesh_v1.mapcss
```

Actualmente utilizado por Guru Maps.

No se genera automáticamente.

---

## data/runtime

Runtime derivado automáticamente.

Ejemplo:

```text
data/runtime/
└── visibility.json
```

Generado desde:

```text
config/users.json
```

mediante:

```bash
./auth/generate.sh
```

Uso:

- grupos
- exclusiones
- roles
- estructura optimizada para filtrado API

No es configuración manual.

---

## config/generated

Archivos operativos generados automáticamente por:

```bash
./auth/generate.sh
```

Ejemplo:

```text
config/generated/
├── mqtt-passwords.txt
├── mqtt-acl.txt
└── api-tokens.txt
```

---

### mqtt-passwords.txt

Base de contraseñas compatible con Mosquitto.

Usada por autenticación MQTT.

---

### mqtt-acl.txt

ACL MQTT generadas automáticamente.

Controlan permisos de lectura/escritura MQTT por usuario.

---

### api-tokens.txt

Tokens persistentes de autenticación API.

Formato:

```text
usuario:token
```

Usados para autenticación HTTP.

---

## Flujo de persistencia

Pipeline principal:

```text
OwnTracks
   ↓
MQTT
   ↓
Recorder
   ↓
data/owntracks/store
   ↓
Worker
   ↓
data/public/nookmesh.geojson
   ↓
API
   ↓
Cliente
```

Pipeline de configuración:

```text
config/users.json
   ↓
auth/generate.sh
   ↓
config/generated
   ↓
data/runtime
```

---

## Persistencia Docker

Estas rutas deben persistirse mediante bind mounts o volumes.

Objetivo:

- evitar pérdida de datos
- permitir upgrades seguros
- desacoplar contenedores y datos

Conceptualmente:

```text
host filesystem ↔ containers
```

---

## Backups

Recomendado incluir:

### Crítico

Configuración fuente:

```text
config/
```

Persistencia de ubicaciones:

```text
data/owntracks/store/
```

Especialmente:

```text
config/users.json
config/filtros.env
config/recorder.env
```

---

### Importante según despliegue

Tokens API:

```text
config/generated/api-tokens.txt
```

Si se pierde:

los clientes deberán reconfigurarse.

---

### Regenerable

Puede regenerarse:

```text
config/generated/mqtt-passwords.txt
config/generated/mqtt-acl.txt
data/runtime/visibility.json
```

---

### Código versionado

Recuperable desde Git:

```text
api/
auth/
mqtt/
recorder/
worker/
docs/
```

---

## Git

No deberían versionarse datos reales ni secretos.

Ejemplos:

```text
config/users.json
config/generated/*
data/owntracks/*
data/runtime/*
```

El repositorio sí puede incluir placeholders o ejemplos seguros.

Ejemplos:

```text
.gitkeep
example configs
public demo assets
```

---

## Troubleshooting

### No aparecen ubicaciones

Revisar:

```text
data/owntracks/store/last/
```

---

### GeoJSON base vacío

Revisar:

```text
data/public/nookmesh.geojson
```

---

### Problemas visuales

Revisar:

```text
data/public/nookmesh_v1.mapcss
```

---

### Problemas de visibilidad

Revisar:

```text
data/runtime/visibility.json
```

---

### Problemas de autenticación API

Revisar:

```text
config/generated/api-tokens.txt
```

---

## Buenas prácticas

### No commitear datos reales

Nunca subir:

```text
config/users.json
config/generated/
data/owntracks/
data/runtime/
```

---

### No editar runtime manualmente

Evitar modificar:

```text
config/generated/
data/runtime/
```

---

### Personalizar visuales conscientemente

Puede modificarse:

```text
data/public/nookmesh_v1.mapcss
```

si se desea alterar representación visual.

---

## Resumen

NookMesh separa claramente:

- código
- configuración fuente
- configuración generada
- persistencia operativa
- runtime derivado
- artefactos consumibles

Esto forma parte del diseño modular del proyecto.