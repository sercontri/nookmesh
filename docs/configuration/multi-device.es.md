# Multi-dispositivo

🇬🇧 [English version](multi-device.md)

NookMesh permite que una misma identidad lógica utilice varios dispositivos físicos simultáneamente.

Esto permite escenarios donde un usuario:

- cambia de terminal
- usa varios dispositivos a la vez
- mantiene dispositivos secundarios
- publica ubicación desde distintas fuentes físicas

La arquitectura separa claramente:

```text
identidad lógica ≠ dispositivo físico
```

---

# Concepto base

En NookMesh:

## Usuario

Representa una identidad lógica.

Ejemplos:

```text
sergio
sandra
raul
```

El usuario es la unidad principal de control para:

- autenticación MQTT
- autenticación API
- grupos
- visibilidad
- roles
- permisos

Definido en:

```text
config/users.json
```

---

## Dispositivo

Representa un origen físico de ubicación.

Ejemplos:

```text
iphone
pixel
ipad
tracker
tablet
backup
```

Un dispositivo no tiene identidad propia dentro de NookMesh.

Forma parte de un usuario existente.

---

# Relación con OwnTracks

OwnTracks publica usando estructura MQTT:

```text
owntracks/<usuario>/<dispositivo>
```

Ejemplo:

```text
owntracks/sergio/iphone
owntracks/sergio/ipad
owntracks/sergio/tracker
```

Aquí:

- `sergio` = identidad lógica
- `iphone` = dispositivo físico

---

# Persistencia interna

OwnTracks Recorder almacena cada dispositivo de forma independiente.

Ejemplo real:

```text
data/owntracks/store/last/sergio/iphone/sergio-iphone.json
```

Estructura conceptual:

```text
data/owntracks/store/last/
└── sergio/
    ├── iphone/
    │   └── sergio-iphone.json
    ├── ipad/
    │   └── sergio-ipad.json
    └── tracker/
        └── sergio-tracker.json
```

Cada dispositivo mantiene su propia última posición persistida.

---

# Cómo procesa NookMesh los dispositivos

El exporter recorre todos los dispositivos encontrados.

Conceptualmente:

```text
usuario
  → dispositivos
      → JSON individuales
```

Cada JSON válido genera inicialmente una feature independiente.

Esto significa que múltiples dispositivos del mismo usuario se procesan individualmente.

---

# Requisito importante

Para que varios dispositivos pertenezcan a la misma identidad lógica:

deben compartir el mismo usuario MQTT.

Correcto:

```text
owntracks/sergio/iphone
owntracks/sergio/ipad
```

Incorrecto como misma identidad:

```text
owntracks/sergio/iphone
owntracks/sergio2/ipad
```

En ese caso NookMesh los tratará como usuarios distintos.

---

# Usuario debe existir en NookMesh

Si un dispositivo publica con un usuario no definido en:

```text
config/users.json
```

no aparecerá en NookMesh.

Motivo:

solo usuarios presentes en:

```text
data/runtime/visibility.json
```

son exportados.

Esto evita exposición accidental de usuarios desconocidos.

---

# Merge de dispositivos

NookMesh puede consolidar dispositivos cercanos del mismo usuario.

Configuración:

```env
MERGE_CLOSEST_DEVICES=true
MERGE_MAX_METROS=100
```

---

## Qué hace el merge

Si varios dispositivos del mismo usuario están dentro del radio configurado:

```text
MERGE_MAX_METROS
```

se consolidan en una única representación lógica.

Importante:

esto solo ocurre entre dispositivos del mismo usuario.

Nunca entre usuarios distintos.

---

## Criterio de selección

Si varios dispositivos compiten dentro del radio:

NookMesh conserva:

### 1. el más reciente

comparando:

```text
tst
```

---

### 2. si empatan, el más preciso

comparando:

```text
acc
```

(menor valor = mejor precisión)

---

## Ejemplo

Dispositivos:

```text
sergio/iphone
sergio/ipad
```

Situación:

- separados 35 metros
- `MERGE_MAX_METROS=100`

Resultado:

una única representación.

Si:

- iphone tiene timestamp más reciente

se conserva iphone.

Si:

- ambos tienen mismo timestamp
- ipad tiene mejor precisión GPS

se conserva ipad.

---

# Si merge está desactivado

Con:

```env
MERGE_CLOSEST_DEVICES=false
```

cada dispositivo se procesará independientemente.

Esto puede producir múltiples representaciones del mismo usuario.

Ejemplo:

```text
sergio/iphone
sergio/ipad
sergio/tracker
```

---

# Representación visual

La API genera representación visual a partir de cada feature final.

Cada ubicación visible produce:

- un icono
- una etiqueta

Conceptualmente:

```text
feature visible
   → icon
   → label
```

Por eso un único usuario visible puede traducirse internamente en varias entidades GeoJSON renderizadas.

---

# Casos de uso

## Cambio de móvil

Antes:

```text
owntracks/sergio/iphone13
```

Después:

```text
owntracks/sergio/iphone16
```

No es necesario cambiar:

- permisos
- grupos
- tokens
- visibilidad

Solo cambia el device id.

---

## Varios dispositivos simultáneos

Ejemplo:

```text
owntracks/sergio/iphone
owntracks/sergio/ipad
owntracks/sergio/tracker
```

Útil para:

- móvil principal
- tablet
- tracker dedicado
- backup

---

## Pruebas

Ejemplo:

```text
owntracks/sergio/test-device
```

Permite validar comportamiento sin crear nuevos usuarios.

---

# Buenas prácticas

## Mantener identidad estable

Mejor:

```text
sergio
```

aunque cambie el hardware.

No:

```text
sergio
sergio2
sergio-test
```

si representan a la misma persona.

---

## Nombrar bien dispositivos

Mejor:

```text
iphone
ipad
tracker
backup
```

que:

```text
dev1
tmp
abc
```

---

## Usar merge según escenario

Activado:

mejor experiencia visual para múltiples dispositivos cercanos.

Desactivado:

útil para debugging o tracking multi-dispositivo explícito.

---

# Seguridad

La autenticación MQTT se aplica al usuario lógico.

No existe autenticación independiente por dispositivo.

Esto significa que todos los dispositivos que publiquen como:

```text
sergio
```

comparten:

- mismo usuario MQTT
- misma contraseña MQTT

---

# Futuro

Este diseño facilita integraciones futuras con múltiples fuentes físicas.

Ejemplo conceptual:

```text
sergio = identidad lógica
iphone = fuente A
tracker = fuente B
mesh node = fuente C
```

La arquitectura ya separa correctamente identidad y origen físico.
