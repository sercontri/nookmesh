# Endpoints GeoJSON

🇬🇧 [English version](geojson-endpoints.md)

NookMesh expone datos de ubicación mediante endpoints GeoJSON protegidos para consumo por clientes compatibles.

Actualmente el cliente principal es:

```text
Guru Maps
```

aunque cualquier consumidor compatible con GeoJSON podría integrarse.

---

## Objetivo

Los endpoints GeoJSON permiten:

- exponer ubicaciones filtradas
- aplicar autenticación individual
- respetar reglas de visibilidad
- entregar datos enriquecidos
- desacoplar backend y cliente

---

## Formato

Formato principal:

```text
GeoJSON
```

Estructura base:

```json
{
  "type": "FeatureCollection",
  "features": [...]
}
```

Cada respuesta contiene únicamente datos autorizados para el usuario autenticado.

---

## Endpoint principal

Endpoint actual:

```text
/nookmesh.geojson
```

Ejemplo:

```text
https://geojson.tudominio.com/nookmesh.geojson?token=TOKEN
```

La URL exacta depende del despliegue.

---

## Autenticación

El acceso requiere token API individual.

Ejemplo:

```text
?token=TOKEN
```

La API:

- valida autenticación
- identifica al usuario asociado
- carga configuración runtime
- aplica reglas de visibilidad
- devuelve únicamente datos autorizados

---

## Qué devuelve realmente

La API no expone directamente el GeoJSON bruto generado por el worker.

Primero aplica:

- autenticación
- reglas de visibilidad
- filtrado contextual
- filtros operativos adicionales

Después construye una respuesta GeoJSON final para el cliente.

---

## Modelo de respuesta actual

La implementación actual genera dos features por cada entidad visible:

### Feature icon

Representación visual principal.

Ejemplo:

```json
{
  "type": "Feature",
  "geometry": {
    "type": "Point",
    "coordinates": [-1.842799, 38.988115]
  },
  "properties": {
    "render": "icon",
    "icon_svg": "<svg>...</svg>",
    "name": "SANDRA",
    "desc": "Posición reciente..."
  }
}
```

---

### Feature label

Etiqueta visual independiente.

Ejemplo:

```json
{
  "type": "Feature",
  "geometry": {
    "type": "Point",
    "coordinates": [-1.842799, 38.988115]
  },
  "properties": {
    "render": "label",
    "tid": "SA",
    "name": "SANDRA",
    "desc": "Posición reciente..."
  }
}
```

Esto permite:

- iconografía SVG dinámica
- etiquetas desacopladas
- control visual avanzado mediante MapCSS

---

## Propiedades actuales

La respuesta final puede incluir:

### En features tipo icon

- `render`
- `icon_svg`
- `name`
- `desc`

---

### En features tipo label

- `render`
- `tid`
- `name`
- `desc`

---

## Filtrado aplicado

Antes de devolver datos, la API evalúa:

- token válido
- usuario autenticado
- grupos compartidos
- reglas `oculto_para`
- antigüedad máxima
- exclusión del propio viewer (si configurado)
- filtrado por proximidad
- reglas multi-dispositivo

---

## Filtrado de visibilidad

La lógica principal funciona mediante:

```text
grupos compartidos - ocultaciones
```

Solo se muestran usuarios con grupos compartidos válidos.

---

## Casos que devuelven resultado vacío

La API puede devolver un GeoJSON vacío si:

### Usuario sin grupos

El usuario autenticado no tiene grupos definidos en:

```text
visibility.json
```

---

### Sin posición reciente del viewer

Si:

```env
REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY=true
```

y el viewer no tiene posición reciente:

```text
<= MAX_EDAD_MIN
```

la respuesta será vacía.

---

### Sin usuarios visibles

Puede ocurrir por:

- reglas de visibilidad
- usuarios ocultos
- datos demasiado antiguos
- filtrado por proximidad

---

## Sanitización de datos para usuarios no staff

Actualmente los usuarios sin rol:

```text
staff
```

reciben una versión reducida de ciertos metadatos.

La API elimina líneas como:

- dispositivo
- tipo de conexión
- grupos visibles

Esto reduce exposición de información interna.

---

## SVG dinámico

Los iconos no dependen únicamente del cliente.

La API genera dinámicamente SVG según:

- rol
- freshness
- rumbo

Esto permite representación consistente incluso en clientes con soporte visual limitado.

---

## Compatibilidad

GeoJSON permite integración con múltiples consumidores.

Ejemplos:

- Guru Maps
- dashboards web
- clientes GIS
- herramientas personalizadas

---

## Integración con Guru Maps

Uso típico:

```text
https://geojson.tudominio.com/nookmesh.geojson?token=TOKEN
```

Opcionalmente puede usarse junto con overlay importable:

```text
docs/assets/gurumaps/nookmesh_gurumaps_overlay.ms
```

---

## Caching cliente

Algunos clientes, especialmente aplicaciones de mapas, pueden cachear respuestas.

Esto puede afectar:

- frecuencia de refresco
- percepción de tiempo real
- actualización visual

No depende directamente del endpoint.

---

## Troubleshooting

### Endpoint no responde

Revisar:

- API activa
- contenedor API
- reverse proxy
- DNS
- HTTPS
- conectividad

---

### Acceso denegado

Revisar:

- token correcto
- token vigente
- configuración regenerada

Si has modificado usuarios:

```bash
./auth/generate.sh
```

---

### GeoJSON vacío

Revisar:

- datos recientes disponibles
- grupos del viewer
- `visibility.json`
- filtros operativos
- posición reciente del viewer
- reglas de proximidad

---

### Guru Maps no muestra nada

Revisar:

- URL exacta
- token correcto
- formato GeoJSON
- overlay
- estilo MapCSS
- caché cliente

---

## Futuro

Posibles extensiones:

- endpoints especializados
- vistas administrativas
- formatos alternativos
- APIs complementarias

Actualmente:

```text
/nookmesh.geojson
```

es el endpoint principal de consumo.