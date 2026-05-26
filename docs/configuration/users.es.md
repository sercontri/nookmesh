# Usuarios

🇬🇧 [English version](users.md)

NookMesh permite gestionar múltiples usuarios con configuración individualizada de autenticación, visibilidad y comportamiento operativo.

Toda la configuración principal de identidades se define en:

```text
config/users.json
```

Este archivo actúa como fuente principal de configuración para:

- autenticación MQTT
- generación de ACL
- emisión de tokens API
- modelo runtime de visibilidad
- cuentas internas del sistema

---

## Estructura general

Ejemplo oficial:

```json
{
  "_meta": {
    "description": "NookMesh user configuration",
    "managed_by": "nookmesh-auth"
  },
  "users": {
    "recorder": {
      "enabled": true,
      "mqtt_admin": true,
      "mqtt_password": "PASSWORD_RECORDER",
      "system_user": true
    },
    "sergio": {
      "enabled": true,
      "mqtt_admin": true,
      "mqtt_password": "PASSWORD_SERGIO",
      "regen_token": false,
      "grupos": ["amigos", "familia", "viaje1", "viaje2", "trabajo"],
      "oculto_para": [],
      "rol": "staff"
    },
    "sandra": {
      "enabled": true,
      "mqtt_password": "PASSWORD_SANDRA",
      "regen_token": false,
      "grupos": ["amigos", "familia", "viaje1", "viaje2"],
      "oculto_para": ["viaje1", "viaje2"],
      "rol": "staff"
    },
    "raul": {
      "enabled": true,
      "mqtt_password": "PASSWORD_RAUL",
      "regen_token": false,
      "grupos": ["amigos", "viaje1"],
      "oculto_para": []
    }
  }
}
```

---

## Filosofía del modelo

Cada usuario puede:

- autenticarse individualmente por MQTT
- recibir su propio token API
- pertenecer a múltiples grupos
- ocultarse selectivamente frente a determinados grupos
- disponer de permisos MQTT ampliados si es necesario
- operar desde múltiples dispositivos físicos
- incluir metadatos lógicos opcionales

Esto permite construir modelos de visibilidad mucho más flexibles que un simple esquema de compartición global.

---

# Estructura del archivo

## `_meta`

Información descriptiva del archivo.

Ejemplo:

```json
"_meta": {
  "description": "NookMesh user configuration",
  "managed_by": "nookmesh-auth"
}
```

Se utiliza únicamente con fines informativos y de trazabilidad.

No afecta al comportamiento operativo del sistema.

---

## `users`

Contenedor principal de identidades configuradas.

Ejemplo:

```json
"users": {
  ...
}
```

Cada clave representa una identidad lógica única.

Ejemplos:

```text
sergio
sandra
raul
recorder
```

---

# Campos de usuario

## `enabled`

Activa o desactiva el usuario.

Ejemplo:

```json
"enabled": true
```

Si un usuario está desactivado:

- no se generan credenciales MQTT
- no recibe token API
- no se incluye en el runtime de visibilidad
- no participa en procesos automáticos asociados

---

## `mqtt_admin`

Concede privilegios administrativos ampliados sobre MQTT.

Ejemplo:

```json
"mqtt_admin": true
```

Esto permite acceso amplio al árbol MQTT:

```text
owntracks/#
```

Incluye capacidad de lectura y escritura sobre tópicos MQTT del sistema.

Uso típico:

- cuentas administrativas
- depuración avanzada
- automatización interna
- servicios técnicos

No se recomienda para usuarios normales salvo necesidad real.

---

## `mqtt_password`

Contraseña MQTT del usuario.

Ejemplo:

```json
"mqtt_password": "PASSWORD_SERGIO"
```

Durante:

```bash
./auth/generate.sh
```

esta contraseña se transforma en credenciales operativas para el broker MQTT:

```text
config/generated/mqtt-passwords.txt
```

Cada usuario dispone de autenticación independiente.

Esto permite:

- aislamiento
- revocación selectiva
- control granular de acceso

---

## `regen_token`

Controla la regeneración del token API del usuario.

Ejemplo:

```json
"regen_token": true
```

Comportamiento:

- si el usuario no tiene token previo → se genera automáticamente
- si `regen_token=true` → se fuerza rotación del token
- si `regen_token=false` → se conserva el token existente
- si se elimina un usuario → su token se elimina
- si se crea un usuario nuevo → recibe token automáticamente

Tras una regeneración forzada, el sistema restablece automáticamente:

```json
"regen_token": false
```

Esto permite rotación controlada de credenciales API sin afectar al resto de usuarios.

---

## `grupos`

Define pertenencia del usuario a uno o varios grupos.

Ejemplo:

```json
"grupos": ["amigos", "familia", "viaje1"]
```

Los grupos representan ámbitos de compartición y visibilidad.

Ejemplos:

- familia
- amigos
- trabajo
- viaje1
- viaje2
- senderismo
- evento-temporal

Un usuario puede pertenecer simultáneamente a múltiples grupos.

---

## `oculto_para`

Define excepciones de visibilidad.

Ejemplo:

```json
"oculto_para": ["viaje1"]
```

Esto permite ocultar un usuario frente a determinados grupos aunque pertenezca a ellos.

Ejemplo conceptual:

- Sandra pertenece a `amigos`, `familia`, `viaje1`
- pero se oculta para `viaje1`

Resultado:

la visibilidad efectiva dependerá del resto de grupos compartidos y de las reglas activas del modelo de visibilidad.

La lógica detallada se documenta en:

- [Visibilidad](visibility.es.md)

---

## `rol`

Clasificación lógica opcional.

Ejemplo:

```json
"rol": "staff"
```

Posibles usos:

- diferenciación visual en mapas
- reglas adicionales
- automatización futura
- lógica de negocio personalizada

No es obligatorio.

---

## `system_user`

Marca usuarios internos del sistema.

Ejemplo:

```json
"system_user": true
```

Caso habitual:

```json
"recorder"
```

Estas cuentas:

- no representan personas reales
- no reciben token API
- no participan en visibilidad entre usuarios
- pueden operar con privilegios especiales

Se utilizan para comunicación interna entre componentes.

---

# Multi-dispositivo

Una misma identidad lógica puede operar desde varios dispositivos físicos.

Ejemplo:

usuario:

```text
sergio
```

dispositivos:

```text
iphone
pixel
xiaomi
iphone2
```

Siempre que cada dispositivo use un identificador único en OwnTracks.

Esto permite reutilizar:

- mismas credenciales MQTT
- mismo token API
- misma identidad lógica

El comportamiento detallado se documenta en:

- [Multi-dispositivo](multi-device.es.md)

---

# Buenas prácticas

## Separar usuarios reales y cuentas internas

Mantén separadas:

- personas reales
- servicios técnicos internos

Ejemplo:

```text
recorder
```

debe seguir siendo una cuenta técnica.

---

## Limitar `mqtt_admin`

No concedas:

```json
"mqtt_admin": true
```

sin necesidad real.

Otorga acceso amplio al sistema MQTT.

---

## Mantener nombres consistentes

Usa identidades claras y estables.

Mejor:

```text
sergio
sandra
raul
```

que:

```text
test
user1
abc
```

---

## Usar grupos con significado real

Mejor:

```text
familia
amigos
trabajo
viaje-alpes
```

que:

```text
grupo1
misc
tmp
```

---

# Seguridad

Este archivo contiene información sensible.

Debe:

- mantenerse privado
- no subirse al repositorio
- generarse siempre desde plantillas seguras

El repositorio público solo debe incluir:

```text
users.example.json
```

---

# Relación con otros componentes

Este archivo influye directamente en:

- autenticación MQTT
- ACL MQTT
- tokens API
- runtime de visibilidad
- automatización interna

---

# Siguiente paso

Continúa con:

- [Visibilidad](visibility.es.md)
- [Multi-dispositivo](multi-device.es.md)
- [MQTT](mqtt.es.md)
- [Generador de autenticación](auth-generator.es.md)
