# Integración con Guru Maps

🇬🇧 [English version](gurumaps.md)

Actualmente, la integración principal de visualización de NookMesh está diseñada para **Guru Maps**.

Guru Maps permite consumir fuentes GeoJSON personalizadas y aplicar estilos visuales avanzados mediante MapCSS, lo que lo convierte en un cliente especialmente potente para visualización de ubicaciones en tiempo real.

---

## Qué aporta esta integración

Con Guru Maps, NookMesh permite visualizar:

- posiciones en tiempo real
- identificadores cortos (`tid`)
- indicadores visuales dinámicos por antigüedad
- dirección de movimiento (si disponible)
- batería
- velocidad
- precisión GPS
- altitud
- información contextual enriquecida

Dependiendo del rol del usuario autenticado, algunos metadatos sensibles pueden ocultarse automáticamente.

Por ejemplo, usuarios no `staff` no reciben:

- dispositivo origen
- tipo de conexión
- grupos internos

La lógica de privacidad se aplica en backend antes de entregar los datos.

---

## Flujo general

```text
OwnTracks
   ↓
MQTT
   ↓
Recorder
   ↓
Worker GeoJSON
   ↓
API protegida
   ↓
Guru Maps
```

Guru Maps consume el GeoJSON ya autenticado, filtrado y enriquecido.

Toda la lógica sensible ocurre en backend.

---

## Formato de integración

NookMesh expone datos mediante:

```text
GeoJSON
```

Endpoint típico:

```text
https://geojson.tudominio.com/nookmesh.geojson?token=TU_TOKEN
```

Guru Maps consume este endpoint como fuente GeoJSON personalizada.

---

## Autenticación

El acceso está protegido mediante token API individual.

Formato:

```text
?token=TU_TOKEN
```

Esto permite:

- control individual
- revocación selectiva
- visibilidad personalizada
- aislamiento entre usuarios

Guru Maps no participa en autenticación interna.

Solo consume el resultado autorizado.

---

## Plantilla de importación rápida

NookMesh incluye una plantilla de overlay lista para importar en Guru Maps:

```text
docs/assets/gurumaps/nookmesh_gurumaps_overlay.ms
```

Contenido:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<customMapSource overlay="true">
    <name>🛰️ NookMesh</name>
    <minZoom>0</minZoom>
    <maxZoom>22</maxZoom>
    <geojson url="https://your_host/nookmesh.geojson?token=your_token" updateInterval="0.05"/>
    <style url="https://your_host/nookmesh_v1.mapcss?token=your_token"/>
</customMapSource>
```

Solo necesitas reemplazar:

- `your_host`
- `your_token`

según tu despliegue.

---

## Métodos de configuración

### Método 1 — Importar overlay

La forma más rápida.

Importa:

```text
nookmesh_gurumaps_overlay.ms
```

Después edita:

- URL GeoJSON
- URL MapCSS
- token

---

### Método 2 — Crear fuente manualmente

Añadir manualmente una fuente GeoJSON personalizada.

GeoJSON:

```text
https://geojson.tudominio.com/nookmesh.geojson?token=TU_TOKEN
```

Estilo opcional:

```text
https://style.tudominio.com/nookmesh_v1.mapcss?token=TU_TOKEN
```

---

## Modelo visual actual

La integración actual utiliza render enriquecido generado por la API.

Por cada entidad visible, NookMesh genera **dos features GeoJSON coordinadas**:

### Feature icon

Representa el icono principal.

Ejemplo:

```json
"render": "icon"
```

Incluye:

- SVG dinámico
- color por antigüedad
- marcador de rumbo (si existe)
- descripción contextual

---

### Feature label

Representa la etiqueta textual.

Ejemplo:

```json
"render": "label"
```

Incluye:

- `tid`
- nombre
- descripción contextual

---

Esto permite separar:

- iconografía
- texto
- comportamiento visual

mediante MapCSS.

---

## Indicadores visuales actuales

Actualmente el sistema utiliza:

```text
< 5 min      → verde
5–29 min     → naranja
30–60 min    → rojo
> MAX_EDAD   → oculto
```

Además:

- usuarios `staff` usan color interno diferenciado
- otros usuarios usan estilo alternativo
- el rumbo genera marca negra orientada

---

## Autoexclusión del usuario

NookMesh soporta:

```env
EXCLUDE_VIEWER_IN_OUTPUT=true
```

Cuando está activado:

el usuario autenticado **no recibe su propia ubicación** dentro del GeoJSON.

Esto evita duplicar marcadores cuando Guru Maps ya muestra la posición GPS local del dispositivo.

Muy recomendable.

---

## Información mostrada

Dependiendo del rol y configuración:

pueden mostrarse:

- `tid`
- batería
- velocidad
- precisión GPS
- altitud
- rumbo
- antigüedad
- descripción contextual

Solo usuarios autorizados reciben ciertos metadatos avanzados.

---

## Estilos visuales

Guru Maps permite personalización mediante:

```text
MapCSS
```

NookMesh incluye:

```text
data/public/nookmesh_v1.mapcss
```

El estilo permite:

- iconos SVG dinámicos
- labels independientes
- control visual avanzado
- render condicional
- overlays personalizados

---

## Compatibilidad

Actualmente optimizado para:

```text
Guru Maps
```

Plataformas:

- iPhone
- iPad
- Android

---

## Dependencia del estilo

La API entrega datos estructurados.

El aspecto visual final depende del MapCSS aplicado.

Sin estilo:

Guru Maps mostrará datos básicos.

Con estilo:

obtendrás la experiencia visual completa de NookMesh.

---

## Frecuencia de actualización

El refresco depende de:

- publicación OwnTracks
- worker export interval
- disponibilidad API
- comportamiento de caché del cliente
- conectividad del dispositivo

---

## Caché de Guru Maps

Guru Maps puede cachear resultados.

Esto puede provocar síntomas como:

- cambios que tardan en reflejarse
- posiciones aparentemente congeladas
- estilos que parecen no actualizar

En muchos casos no es un problema del backend.

---

## Seguridad

Guru Maps **no decide visibilidad**.

Toda la lógica ocurre en backend:

- autenticación por token
- filtrado de usuarios
- reglas de grupos
- ocultaciones
- control de acceso

El cliente solo consume el resultado final autorizado.

---

## Caso de uso típico

Ejemplo:

viaje en moto entre amigos.

Visualización:

- posición de compañeros
- dirección de movimiento
- estado reciente
- contexto espacial real

sin depender de plataformas cloud comerciales.

---

## Troubleshooting

### No aparece nada

Revisar:

- token correcto
- endpoint correcto
- API accesible
- HTTPS válido
- logs del contenedor API

---

### OwnTracks publica pero Guru no muestra nada

Revisar:

- recorder
- worker
- generación de `nookmesh.geojson`
- permisos de visibilidad
- antigüedad de datos (`MAX_EDAD_MIN`)

---

### Solo veo algunos usuarios

Revisar:

- grupos compartidos
- `oculto_para`
- token del usuario autenticado
- filtros operativos

---

### Veo datos pero sin estilo

Revisar:

- URL del MapCSS
- accesibilidad HTTP/HTTPS
- token del endpoint style
- compatibilidad del estilo

---

### Mi posición aparece duplicada

Revisar:

```env
EXCLUDE_VIEWER_IN_OUTPUT=true
```

---

### Los cambios tardan en aparecer

Posibles causas:

- caché de Guru Maps
- refresco del cliente
- worker export interval

---

## Futuro

Posibles mejoras:

- overlays más avanzados
- dashboards visuales
- clientes GeoJSON adicionales
- integración híbrida mesh
- frontend web dedicado

---

## Relación con otras integraciones

Guru Maps es actualmente el cliente principal de visualización.

Sin embargo, NookMesh no depende exclusivamente de él.

Al exponer:

```text
GeoJSON autenticado
```

la arquitectura permite futuras integraciones con otros consumidores compatibles.