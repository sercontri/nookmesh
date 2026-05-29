# Usuarios

🇬🇧 [English version](users.md)

NookMesh permite gestionar múltiples usuarios con configuración individualizada de autenticación, visibilidad, suscripciones y comportamiento operativo.

Toda la configuración principal de identidades se define en:

```text
config/users.json
```

Este archivo actúa como fuente principal de configuración para:

- autenticación MQTT
- generación de ACL
- emisión de tokens API
- modelo runtime de visibilidad
- ciclo de vida de usuarios
- gestión de suscripciones
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
      "system_user": true,
      "mqtt_admin": true,
      "mqtt_password": "PASSWORD_RECORDER"
    },
    "sergio": {
      "status": "active",
      "created_at": "2026-01-01",
      "expires_on": null,
      "retain_credentials": true,
      "mqtt_admin": true,
      "mqtt_password": "PASSWORD_SERGIO",
      "regen_token": false,
      "grupos": ["amigos", "familia", "viaje1", "viaje2"],
      "oculto_para": [],
      "rol": "staff"
    },
    "sandra": {
      "status": "active",
      "created_at": "2026-01-01",
      "expires_on": "2027-01-01",
      "retain_credentials": true,
      "mqtt_password": "PASSWORD_SANDRA",
      "regen_token": false,
      "grupos": ["amigos", "familia"],
      "oculto_para": ["viaje1"],
      "rol": "staff"
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
- disponer de una fecha de expiración opcional
- conservar o eliminar credenciales al expirar
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

# Ciclo de vida de usuarios

NookMesh utiliza un modelo basado en estados.

## `active`

Usuario operativo normal.

Ejemplo:

```json
"status": "active"
```

El usuario:

- puede autenticarse por MQTT
- dispone de ACL activas
- dispone de token API
- aparece en el runtime de visibilidad

---

## `disabled`

Usuario suspendido manualmente.

Ejemplo:

```json
"status": "disabled"
```

El usuario:

- no puede publicar posiciones
- desaparece del runtime de visibilidad
- conserva opcionalmente sus credenciales

Se utiliza normalmente para:

- suspensiones temporales
- mantenimiento
- incidencias operativas

---

## `expired`

Usuario expirado automáticamente.

Ejemplo:

```json
"status": "expired"
```

El usuario:

- deja de participar en el sistema
- desaparece del runtime de visibilidad
- puede conservar o eliminar credenciales según configuración

Normalmente este estado es gestionado automáticamente por el servicio de suscripciones.

---

# Campos de usuario

## `status`

Estado operativo del usuario.

Ejemplo:

```json
"status": "active"
```

Valores soportados:

```text
active
disabled
expired
```

---

## `created_at`

Fecha de creación del usuario.

Ejemplo:

```json
"created_at": "2026-01-01"
```

Actualmente se utiliza con fines:

- informativos
- administrativos
- de auditoría

No afecta al comportamiento operativo del sistema.

---

## `expires_on`

Fecha de expiración del usuario.

Ejemplo:

```json
"expires_on": "2027-01-01"
```

o

```json
"expires_on": null
```

Si contiene una fecha válida:

- el servicio de suscripciones podrá expirar automáticamente el usuario

Si contiene:

```json
null
```

el usuario no tiene fecha de expiración.

---

## `retain_credentials`

Controla la conservación de credenciales tras la expiración.

Ejemplo:

```json
"retain_credentials": true
```

Opciones:

```json
true
false
```

### `true`

Conserva:

- contraseña MQTT
- token API

Esto permite reactivar posteriormente el usuario sin necesidad de redistribuir credenciales.

### `false`

Elimina:

- credenciales MQTT
- token API

Al reactivar el usuario deberán generarse nuevas credenciales.

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

---

## `regen_token`

Controla la regeneración del token API del usuario.

Ejemplo:

```json
"regen_token": true
```

Comportamiento:

- si el usuario no tiene token previo → se genera automáticamente
- si `regen_token=true` → se fuerza la rotación del token
- si `regen_token=false` → se conserva el token existente

Tras una regeneración forzada, el sistema restablece automáticamente:

```json
"regen_token": false
```

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

---

## `oculto_para`

Define excepciones de visibilidad.

Ejemplo:

```json
"oculto_para": ["viaje1"]
```

Esto permite ocultar un usuario frente a determinados grupos aunque pertenezca a ellos.

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

# Suscripciones y expiración

NookMesh puede gestionar automáticamente la expiración de usuarios mediante el servicio:

```text
nookmesh-subscriptions
```

Este servicio:

- revisa diariamente los usuarios configurados
- compara la fecha actual con `expires_on`
- cambia automáticamente usuarios activos a expirados cuando corresponde

Ejemplo:

```json
{
  "status": "active",
  "expires_on": "2027-01-01"
}
```

Tras superar la fecha indicada:

```json
{
  "status": "expired"
}
```

Si posteriormente se desea reactivar el usuario:

```json
{
  "status": "active",
  "expires_on": null
}
```

La siguiente ejecución lo mantendrá nuevamente operativo.

La documentación detallada se encuentra en:

```text
subscriptions/INDEX.md
```

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

---

## Utilizar fechas de expiración para accesos temporales

Ideal para:

- viajes
- eventos
- usuarios invitados
- pruebas temporales
- grupos estacionales

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
- servicio de suscripciones
- automatización interna

---

# Siguiente paso

Continúa con:

- [Visibilidad](visibility.es.md)
- [Multi-dispositivo](multi-device.es.md)
- [MQTT](mqtt.es.md)
- [Generador de autenticación](auth-generator.es.md)