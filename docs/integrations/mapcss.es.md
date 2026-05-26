# Personalización visual con MapCSS

🇬🇧 [English version](mapcss.md)

NookMesh permite personalizar la representación visual de ubicaciones en clientes compatibles mediante **MapCSS**.

Actualmente, el cliente principal que aprovecha esta capacidad es:

```text
Guru Maps
```

Esto permite transformar un GeoJSON funcional en una visualización rica, clara y adaptada a distintos escenarios.

---

## Objetivo

MapCSS permite personalizar:

- iconos
- etiquetas
- tamaños
- offsets
- prioridades visuales
- comportamiento condicional
- solapamiento
- presentación contextual

Esto separa claramente:

```text
datos
```

de

```text
presentación visual
```

---

## Flujo visual

Pipeline actual:

```text
OwnTracks
   ↓
MQTT
   ↓
Recorder
   ↓
Worker
   ↓
GeoJSON enriquecido
   ↓
API
   ↓
Guru Maps + MapCSS
```

---

## Modelo visual actual de NookMesh

La implementación actual genera **dos features GeoJSON por cada entidad visible**.

Esto permite desacoplar iconografía y texto.

---

### Feature icon

Representa el icono visual principal.

Ejemplo:

```json
"render": "icon"
```

Responsable de:

- iconografía principal
- SVG dinámico
- descripción contextual

---

### Feature label

Representa la etiqueta textual independiente.

Ejemplo:

```json
"render": "label"
```

Responsable de:

- texto visible
- identificador corto (`tid`)
- descripción contextual

---

Esto permite desacoplar:

- icono
- texto
- comportamiento visual

y facilita mayor flexibilidad de render.

---

## Ejemplo real simplificado

Feature icon:

```json
{
  "type": "Feature",
  "properties": {
    "render": "icon",
    "icon_svg": "<svg ...>",
    "name": "SANDRA",
    "desc": "Posición reciente..."
  }
}
```

Feature label:

```json
{
  "type": "Feature",
  "properties": {
    "render": "label",
    "tid": "SA",
    "name": "SANDRA",
    "desc": "Posición reciente..."
  }
}
```

---

## Propiedades relevantes

### `render`

Define el tipo de representación.

Valores actuales:

```text
icon
label
```

---

### `icon_svg`

SVG dinámico generado por backend.

Ejemplo:

```json
"icon_svg": "<svg ...>"
```

MapCSS no construye el icono.

Simplemente decide cómo representarlo.

---

### `tid`

Identificador corto.

Ejemplo:

```json
"tid": "SA"
```

Usado normalmente en labels.

---

### `name`

Nombre lógico del usuario.

Ejemplo:

```json
"name": "SANDRA"
```

---

### `desc`

Descripción contextual enriquecida.

Puede incluir:

- antigüedad
- precisión
- velocidad
- batería
- altitud
- rumbo

Dependiendo del rol del usuario autenticado, ciertos campos sensibles pueden ocultarse automáticamente.

Usuarios no `staff` no reciben:

- dispositivo
- conexión
- grupos internos

---

## Qué controla realmente el backend

Buena parte de la lógica visual actual ocurre en backend.

Ejemplo:

- generación SVG
- colores por antigüedad
- marcador de rumbo
- enriquecimiento contextual
- sanitización según permisos

Esto significa que no toda la lógica visual depende del MapCSS.

---

## Estados visuales actuales

Actualmente:

```text
< 5 min      → verde
5–29 min     → naranja
30–60 min    → rojo
> MAX_EDAD   → oculto
```

Estos colores se generan dentro del SVG dinámico.

---

## Rumbo / heading

Si existe rumbo válido:

el backend genera una marca negra orientada dentro del SVG.

Esto permite mostrar dirección de movimiento incluso con un estilo MapCSS muy simple.

---

## Archivo MapCSS principal

Estilo operativo actual:

```text
data/public/nookmesh_v1.mapcss
```

Servido típicamente como:

```text
https://style.tudominio.com/nookmesh_v1.mapcss?token=TU_TOKEN
```

---

## Overlay demo para Guru Maps

Plantilla incluida:

```text
docs/assets/gurumaps/nookmesh_gurumaps_overlay.ms
```

Permite importar rápidamente una configuración funcional.

---

## Qué controla realmente el MapCSS

El estilo puede controlar:

- mostrar u ocultar labels
- tamaño de iconos
- offsets
- texto mostrado
- prioridades visuales
- colisiones
- comportamiento condicional
- render por selector

Mientras backend proporciona:

- datos
- SVG
- propiedades enriquecidas
- lógica contextual

---

## Ejemplos conceptuales

Mostrar labels:

```css
node[render="label"] {
    text: eval(tag("tid"));
}
```

Mostrar iconos SVG:

```css
node[render="icon"] {
    icon-image: eval(tag("icon_svg"));
}
```

Estos ejemplos son conceptuales.

Guru Maps implementa soporte MapCSS con particularidades propias.

---

## Personalización habitual

Escenarios frecuentes:

### Cambiar tamaño de iconos

Útil para:

- navegación
- conducción
- mapas densos

---

### Mostrar u ocultar labels

Ejemplo:

solo iconos.

o:

iconos + `tid`.

---

### Cambiar contenido textual

Mostrar:

```text
tid
```

o:

```text
name
```

---

### Ajustar offsets

Separar mejor texto e iconos.

---

### Ajustar colisiones

Reducir ruido visual cuando muchos usuarios están cerca.

---

## Limitaciones prácticas

### Solapamiento

Guru Maps puede ocultar elementos cuando se solapan.

Esto puede afectar:

- labels
- iconos
- combinaciones complejas

---

### Zoom-dependent behavior

Algunos elementos pueden comportarse distinto según nivel de zoom.

---

### Cache

Cambios en estilos pueden tardar en reflejarse por caché del cliente.

---

### Compatibilidad parcial

Guru Maps no implementa exactamente todo el ecosistema MapCSS estándar.

Algunas reglas pueden comportarse de forma distinta.

---

## Troubleshooting

### Veo iconos pero no labels

Revisar:

- selector `render="label"`
- propiedad `text`
- colisiones visuales
- zoom actual

---

### Labels desaparecen

Posibles causas:

- solapamiento
- prioridad visual
- reglas condicionales
- comportamiento del cliente

---

### No aparecen iconos

Revisar:

- propiedad `icon_svg`
- selector `render="icon"`
- accesibilidad del estilo

---

### Cambios no aparecen

Posibles causas:

- caché Guru Maps
- recarga incompleta
- URL antigua del estilo

---

### Colores inesperados

Recordar:

los colores actuales vienen del backend SVG, no del estilo.

---

## Buenas prácticas

### Mantener separación de responsabilidades

Backend:

```text
datos + lógica
```

Cliente:

```text
presentación
```

---

### Cambios incrementales

Modificar poco a poco facilita debugging.

---

### Conservar una versión funcional

Mantener siempre una configuración conocida antes de experimentar.

---

## Futuro

Posibles mejoras:

- estilos alternativos
- perfiles visuales
- overlays especializados
- visualización mesh futura
