# Modelo de visibilidad

🇬🇧 [English version](visibility.md)

NookMesh implementa un modelo de visibilidad relacional basado en grupos compartidos y exclusiones selectivas.

El objetivo es permitir compartir ubicación en tiempo real sin necesidad de exponer toda la información a todos los participantes.

La decisión de visibilidad se toma completamente dentro de tu propia infraestructura antes de entregar datos al cliente.

---

## Filosofía del modelo

A diferencia de sistemas rígidos donde:

```text
todos ven a todos
```

o:

```text
grupo A ve grupo B
```

NookMesh utiliza un modelo relacional entre:

- usuario autenticado (viewer)
- usuario evaluado (target)

La visibilidad depende de la relación entre ambos.

---

## Conceptos base

Cada usuario puede:

- pertenecer a uno o varios grupos
- ocultarse selectivamente frente a ciertos grupos
- participar en múltiples contextos simultáneamente

La lógica se construye a partir de:

```json
grupos
oculto_para
```

---

# Campos implicados

## `grupos`

Define los ámbitos de pertenencia del usuario.

Ejemplo:

```json
"grupos": ["familia", "amigos", "viaje1"]
```

Interpretación:

ese usuario pertenece simultáneamente a:

- familia
- amigos
- viaje1

---

## `oculto_para`

Define excepciones de visibilidad.

Ejemplo:

```json
"oculto_para": ["viaje1"]
```

Interpretación:

aunque el usuario pertenezca a:

```text
viaje1
```

ese grupo no podrá utilizarse para conceder visibilidad hacia ese usuario.

Importante:

esto **no oculta globalmente** al usuario.

Solo afecta a relaciones construidas mediante esos grupos.

---

# Lógica real de visibilidad

La implementación actual aplica conceptualmente:

```text
shared_groups = viewer_groups ∩ target_groups
visible_groups = shared_groups - target_hidden_groups
```

Si:

```text
visible_groups
```

queda vacío:

el usuario no será visible.

Si contiene al menos un grupo:

el usuario será visible.

---

## Ejemplo simple

Viewer:

```json
"grupos": ["familia", "amigos"]
```

Target:

```json
"grupos": ["amigos", "trabajo"]
"oculto_para": []
```

Resultado:

```text
shared_groups = amigos
visible_groups = amigos
```

El target es visible.

---

## Ejemplo con exclusión

Viewer:

```json
"grupos": ["viaje1"]
```

Target:

```json
"grupos": ["familia", "viaje1"]
"oculto_para": ["viaje1"]
```

Resultado:

```text
shared_groups = viaje1
visible_groups = vacío
```

El target NO será visible.

---

## Ejemplo mixto

Viewer:

```json
"grupos": ["familia", "viaje1"]
```

Target:

```json
"grupos": ["familia", "viaje1"]
"oculto_para": ["viaje1"]
```

Resultado:

```text
shared_groups = familia + viaje1
visible_groups = familia
```

El target sí será visible.

Porque sigue existiendo un grupo compartido válido.

---

# Casos prácticos

## Familia

Todos visibles entre sí:

```json
"grupos": ["familia"]
```

---

## Viaje temporal

Crear:

```text
viaje-alpes
```

Añadir participantes:

```json
"grupos": ["viaje-alpes"]
```

Todos se verán entre sí salvo exclusiones.

---

## Ocultación selectiva en viaje

Sandra:

```json
"grupos": ["familia", "viaje-alpes"]
"oculto_para": ["viaje-alpes"]
```

Resultado:

- visible para familia
- invisible para usuarios que solo compartan viaje-alpes

---

## Separación laboral

Ejemplo:

```json
"grupos": ["trabajo"]
```

permite aislar visibilidad profesional del resto de contextos.

---

# Usuarios sin grupos

Si un usuario no tiene grupos:

```json
"grupos": []
```

resultado:

- no verá a nadie
- nadie lo verá

La API devolverá:

```json
{
  "type": "FeatureCollection",
  "features": []
}
```

Los grupos son obligatorios para participar en el modelo de visibilidad.

---

# Usuarios internos del sistema

Usuarios marcados como:

```json
"system_user": true
```

quedan excluidos del modelo.

Ejemplo:

```text
recorder
```

No:

- reciben token API
- aparecen en `visibility.json`
- participan en comparaciones de visibilidad
- aparecen en GeoJSON público

---

# Runtime interno

Durante:

```bash
./auth/generate.sh
```

NookMesh construye:

```text
data/runtime/visibility.json
```

Este archivo contiene el modelo operativo utilizado por la API.

Ejemplo:

```json
{
  "sergio": {
    "grupos": ["familia", "amigos"],
    "rol": "staff"
  },
  "sandra": {
    "grupos": ["familia", "viaje1"],
    "oculto_para": ["viaje1"]
  }
}
```

---

# Qué NO afecta visibilidad

## `rol`

Ejemplo:

```json
"rol": "staff"
```

No participa en decisiones de visibilidad.

Su uso actual es:

- diferenciación visual
- lógica de presentación
- comportamiento de metadatos

Pero no modifica qué usuarios pueden verse entre sí.

---

## Cliente de visualización

Guru Maps no decide visibilidad.

Solo consume el resultado filtrado entregado por la API.

---

## Cliente de publicación

OwnTracks no participa en reglas de visibilidad.

Solo publica ubicaciones.

---

# Resolución del flujo

Proceso simplificado:

### 1. Autenticación

La API autentica el token del viewer.

---

### 2. Carga de configuración

Se carga:

```text
visibility.json
```

---

### 3. Identificación del viewer

Se obtienen sus grupos.

---

### 4. Comparación contra targets

Para cada usuario disponible:

- se leen sus grupos
- se leen sus exclusiones

---

### 5. Evaluación relacional

Se calcula:

```text
(shared groups) - (hidden groups)
```

---

### 6. Filtrado

Solo se entregan usuarios autorizados.

---

# Buenas prácticas

## Usar nombres de grupo claros

Mejor:

```text
familia
amigos
trabajo
viaje-alpes
```

que:

```text
g1
tmp
misc
```

---

## Evitar complejidad innecesaria

No crear grupos redundantes sin necesidad real.

---

## Diseñar según escenarios reales

Pensar en:

- familia
- viajes
- amigos
- eventos
- trabajo

---

# Seguridad y privacidad

Este modelo permite:

- compartición selectiva
- privacidad contextual
- separación entre ámbitos
- control granular

Toda la lógica de visibilidad se resuelve en servidor.

El cliente final nunca recibe usuarios no autorizados.
