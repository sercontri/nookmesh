# Filtros operativos

🇬🇧 [English version](filters.md)

NookMesh permite ajustar el comportamiento operativo del pipeline GeoJSON mediante parámetros definidos en:

```text
config/filtros.env
```

Estos parámetros controlan cómo se procesan, filtran y presentan las ubicaciones antes de ser entregadas a los clientes.

No forman parte del modelo de autenticación ni del modelo de visibilidad entre usuarios, sino del comportamiento interno del procesamiento y exportación.

---

## Objetivo

Los filtros permiten ajustar:

- frecuencia de regeneración del GeoJSON
- ventana horaria de exportación
- zona horaria para timestamps legibles
- gestión automática de suscripciones
- antigüedad máxima aceptada de ubicaciones
- exclusión de la propia posición del usuario autenticado
- filtrado por proximidad
- comportamiento multi-dispositivo
- limpieza visual del mapa

---

## Archivo de configuración

Ejemplo real (`config/filtros.example.env`):

```env
TIMEZONE=Europe/Madrid
EXPORT_INTERVAL_SECONDS=3
EXPORT_HOUR_START=6
EXPORT_HOUR_END=1

ENABLE_SUBSCRIPTIONS=true

MAX_EDAD_MIN=60
EXCLUDE_VIEWER_IN_OUTPUT=true

EXCLUDE_NEARBY_METROS=80
REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY=true

MERGE_CLOSEST_DEVICES=true
MERGE_MAX_METROS=100
```

---

## Aplicar cambios

Algunos parámetros se leen únicamente durante el arranque del contenedor correspondiente.

Después de modificar:

```text
config/filtros.env
```

puede ser necesario reiniciar determinados servicios.

### Reinicio requerido

| Parámetro | Reinicio requerido |
|------------|------------|
| TIMEZONE | worker + api |
| EXPORT_INTERVAL_SECONDS | worker |
| EXPORT_HOUR_START | worker |
| EXPORT_HOUR_END | worker |
| MAX_EDAD_MIN | worker + api |
| EXCLUDE_VIEWER_IN_OUTPUT | api |
| EXCLUDE_NEARBY_METROS | api |
| REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY | api |
| MERGE_CLOSEST_DEVICES | api |
| MERGE_MAX_METROS | api |
| ENABLE_SUBSCRIPTIONS | subscriptions |

Ejemplos:

```bash
docker restart nookmesh-worker
docker restart nookmesh-api
```

o:

```bash
docker restart nookmesh-subscriptions
```

---

# Parámetros disponibles

## TIMEZONE

Zona horaria utilizada para timestamps legibles incluidos en descripciones GeoJSON.

Ejemplo:

```env
TIMEZONE=Europe/Madrid
```

Importante:

esto **no afecta a los cálculos internos de antigüedad**, que se realizan siempre en UTC.

Solo afecta a:

- textos descriptivos
- hora mostrada al usuario

---

## EXPORT_INTERVAL_SECONDS

Frecuencia con la que el worker regenera:

```text
data/public/nookmesh.geojson
```

Ejemplo:

```env
EXPORT_INTERVAL_SECONDS=3
```

Interpretación:

el GeoJSON se reconstruirá aproximadamente cada:

```text
3 segundos
```

---

### Impacto

Valores bajos:

- actualizaciones más rápidas
- mayor consumo CPU / disco

Valores altos:

- menor carga
- menor sensación de tiempo real

---

## EXPORT_HOUR_START

Hora de inicio de exportación automática.

Ejemplo:

```env
EXPORT_HOUR_START=6
```

Interpretación:

inicio de exportación a las:

```text
06:00
```

---

## EXPORT_HOUR_END

Hora de finalización de exportación automática.

Ejemplo:

```env
EXPORT_HOUR_END=1
```

Interpretación:

detener exportación a la:

```text
01:00
```

---

### Ventanas nocturnas

NookMesh soporta ventanas que cruzan medianoche.

Ejemplo:

```env
EXPORT_HOUR_START=22
EXPORT_HOUR_END=6
```

Resultado:

exportación activa entre:

```text
22:00 → 06:00
```

---

### Fuera de horario

Si el sistema está fuera de la ventana configurada:

NookMesh vacía deliberadamente el GeoJSON.

Resultado:

```json
{
  "type": "FeatureCollection",
  "features": []
}
```

Esto permite desactivar completamente visualización fuera del horario definido.

---

## ENABLE_SUBSCRIPTIONS

Activa o desactiva el procesamiento automático de suscripciones.

Ejemplo:

```env
ENABLE_SUBSCRIPTIONS=true
```

---

### true

El contenedor:

```text
nookmesh-subscriptions
```

ejecutará periódicamente:

```text
auth/generate.sh
```

para:

- aplicar expiraciones automáticas
- actualizar estados de usuarios
- mantener credenciales
- regenerar runtime si procede

---

### false

El contenedor permanecerá activo pero no realizará ningún procesamiento.

No se aplicarán automáticamente:

- expiraciones
- cambios de estado
- actualizaciones de credenciales

Los cambios solo se reflejarán cuando se ejecute manualmente:

```bash
./auth/generate.sh
```

---

### Importante

Tras modificar este parámetro es necesario reiniciar:

```bash
docker restart nookmesh-subscriptions
```

---

## MAX_EDAD_MIN

Define la antigüedad máxima aceptada para considerar válida una ubicación.

Ejemplo:

```env
MAX_EDAD_MIN=60
```

Interpretación:

solo se aceptan ubicaciones con antigüedad:

```text
<= 60 minutos
```

---

### Estados visuales actuales

La lógica actual usa:

```text
< 5 min      → verde
5–29 min     → naranja
30–60 min    → rojo
> MAX_EDAD   → oculto
```

---

### Importante

Este valor afecta tanto a:

- exportación del GeoJSON
- API de entrega
- lógica de proximidad del viewer

No es solo un filtro visual.

---

## EXCLUDE_VIEWER_IN_OUTPUT

Controla si el usuario autenticado debe ver su propia posición.

Ejemplo:

```env
EXCLUDE_VIEWER_IN_OUTPUT=true
```

---

### true

La posición del propio usuario se excluye.

Muy útil cuando el cliente ya muestra la posición local.

Caso típico:

Guru Maps.

Evita duplicar tu propia ubicación en pantalla.

---

### false

El usuario verá también su propia posición dentro del GeoJSON filtrado.

---

## EXCLUDE_NEARBY_METROS

Oculta usuarios demasiado próximos al viewer autenticado.

Ejemplo:

```env
EXCLUDE_NEARBY_METROS=80
```

Interpretación:

usuarios a menos de:

```text
80 metros
```

pueden excluirse del resultado.

---

### Objetivo

Reducir ruido visual.

Escenarios típicos:

- viajes en grupo
- paradas
- reuniones
- convoy

---

## REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY

Controla si el filtrado por proximidad exige una posición reciente del viewer.

Ejemplo:

```env
REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY=true
```

---

### true

Si el viewer no tiene posición reciente:

```text
edad > MAX_EDAD_MIN
```

NookMesh devuelve:

```text
resultado vacío completo
```

No solo desactiva proximidad.

No mostrará ningún usuario.

Esto evita aplicar lógica espacial usando una referencia obsoleta.

---

### false

El sistema intentará aplicar proximidad incluso usando posiciones antiguas.

Normalmente no recomendable.

---

## MERGE_CLOSEST_DEVICES

Controla consolidación multi-dispositivo.

Ejemplo:

```env
MERGE_CLOSEST_DEVICES=true
```

---

### true

Si varios dispositivos del mismo usuario están suficientemente próximos:

pueden fusionarse visualmente.

---

### false

Cada dispositivo publicado podrá aparecer por separado.

Ejemplo:

```text
owntracks/sergio/iphone
owntracks/sergio/ipad
owntracks/sergio/tracker
```

---

## MERGE_MAX_METROS

Distancia máxima para considerar fusionables dispositivos del mismo usuario.

Ejemplo:

```env
MERGE_MAX_METROS=100
```

Interpretación:

si varios dispositivos están dentro de:

```text
100 metros
```

pueden consolidarse.

---

### Selección de dispositivo

Si varios dispositivos son fusionables:

NookMesh prioriza:

1. ubicación más reciente
2. si empatan en timestamp, mejor precisión GPS

---

# Relación con otros componentes

## Visibilidad

Estos filtros NO deciden:

```text
quién puede ver a quién
```

Eso pertenece a:

- autenticación
- tokens
- grupos
- ocultaciones

---

## Worker

Afectan directamente al:

```text
nookmesh-worker
```

Responsable de generar:

```text
nookmesh.geojson
```

---

## API

La API también aplica lógica adicional:

- autenticación
- filtrado por visibilidad
- exclusión del viewer
- filtrado por antigüedad
- proximidad
- merge multi-dispositivo
- render final GeoJSON

---

## Subscription Service

También afecta al servicio:

```text
nookmesh-subscriptions
```

responsable de:

- procesar expiraciones automáticas
- mantener el ciclo de vida de usuarios
- ejecutar periódicamente el generador de autenticación

---

# Ejemplo práctico

Supongamos:

- viewer autenticado con posición reciente
- dos compañeros a menos de 50 metros
- varios dispositivos del mismo usuario

Con:

```env
EXCLUDE_NEARBY_METROS=80
MERGE_CLOSEST_DEVICES=true
```

Resultado:

- usuarios muy cercanos pueden ocultarse
- dispositivos redundantes pueden fusionarse
- el mapa queda visualmente más limpio

---

# Buenas prácticas

## Viajes en grupo

Configuración recomendada:

```env
EXCLUDE_NEARBY_METROS=80
MERGE_CLOSEST_DEVICES=true
```

---

## Monitorización detallada

Si quieres ver absolutamente todo:

```env
EXCLUDE_NEARBY_METROS=0
MERGE_CLOSEST_DEVICES=false
```

---

## Evitar valores extremos

Filtros demasiado agresivos pueden ocultar información útil.

---

# Troubleshooting

## No aparece un usuario

Revisar:

```env
MAX_EDAD_MIN
EXCLUDE_NEARBY_METROS
REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY
```

---

## Desaparecen dispositivos

Revisar:

```env
MERGE_CLOSEST_DEVICES
MERGE_MAX_METROS
```

---

## El GeoJSON aparece vacío por la noche

Revisar:

```env
EXPORT_HOUR_START
EXPORT_HOUR_END
```

---

## El mapa no actualiza rápido

Revisar:

```env
EXPORT_INTERVAL_SECONDS
```

---

## Las suscripciones no se actualizan

Verificar:

```env
ENABLE_SUBSCRIPTIONS=true
```

y reiniciar:

```bash
docker restart nookmesh-subscriptions
```

---

## Cambié filtros y no ocurre nada

Reiniciar el contenedor correspondiente según el parámetro modificado.