# Generador de autenticación y runtime

🇬🇧 [English version](auth-generator.md)

NookMesh utiliza un generador automático para construir credenciales, permisos MQTT y estado operativo interno a partir de la configuración declarativa de usuarios.

Script principal:

```text
auth/generate.sh
```

Este script es una pieza central de la arquitectura.

Permite que:

```text
config/users.json
```

sea la fuente única de verdad para:

- autenticación MQTT
- permisos MQTT
- tokens API
- visibilidad runtime
- ciclo de vida de usuarios
- gestión de suscripciones
- cuentas internas del sistema

---

## Objetivo

El generador automatiza:

- creación del archivo de contraseñas MQTT compatible con Mosquitto
- generación automática de ACL MQTT
- creación y mantenimiento de tokens API
- regeneración selectiva de tokens
- procesamiento automático de expiraciones
- mantenimiento del ciclo de vida de usuarios
- conservación opcional de credenciales
- generación del runtime de visibilidad
- despliegue automático de archivos generados
- reinicio automático de servicios activos

Esto evita editar manualmente archivos sensibles y reduce errores operativos.

---

## Fuente de verdad

Toda la configuración declarativa parte de:

```text
config/users.json
```

El modelo completo de usuarios se documenta en:

- [Usuarios](users.es.md)

A partir de esa definición, NookMesh genera automáticamente el estado operativo real.

---

# Archivos generados

## MQTT password database

Generado en:

```text
config/generated/mqtt-passwords.txt
```

Contiene el formato requerido por Mosquitto.

Las contraseñas declaradas en:

```text
config/users.json
```

se transforman mediante:

```text
mosquitto_passwd
```

No se almacenan en texto plano dentro del archivo generado.

Además, el archivo se organiza visualmente por categorías:

```text
SYSTEM USERS
ACTIVE USERS
DISABLED USERS
EXPIRED USERS
```

para facilitar tareas de administración y auditoría.

---

## MQTT ACL

Generado en:

```text
config/generated/mqtt-acl.txt
```

Define permisos MQTT automáticos por usuario.

Ejemplo de usuario estándar:

```text
user sergio
topic read owntracks/sergio/#
topic write owntracks/sergio/#
```

Ejemplo con:

```json
"mqtt_admin": true
```

resultado:

```text
user sergio
topic read owntracks/#
topic write owntracks/sergio/#
```

Esto concede:

- lectura global del árbol MQTT de OwnTracks
- escritura únicamente dentro del namespace del propio usuario

Las ACL también se agrupan visualmente por categorías:

```text
SYSTEM USERS
ACTIVE USERS
DISABLED USERS
EXPIRED USERS
```

---

## API tokens

Generado en:

```text
config/generated/api-tokens.txt
```

Formato:

```text
usuario:token
```

Ejemplo:

```text
sergio:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
sandra:yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy
```

Cada usuario humano activo recibe su propio token.

Usuarios marcados como:

```json
"system_user": true
```

no reciben token.

El archivo también se organiza visualmente por grupos operativos:

```text
ACTIVE USERS
DISABLED USERS
EXPIRED USERS
```

---

## Runtime visibility

Generado en:

```text
data/runtime/visibility.json
```

Contiene una representación procesada del modelo de visibilidad.

Solo incluye:

- usuarios con `status="active"`
- usuarios no marcados como `system_user`

Campos posibles:

- `grupos`
- `oculto_para`
- `rol`

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

Este archivo se utiliza internamente por la API para resolver permisos de visualización.

---

# Flujo general

```text
config/users.json
        ↓
auth/generate.sh
        ↓
mqtt-passwords.txt
mqtt-acl.txt
api-tokens.txt
visibility.json
        ↓
deployment
        ↓
runtime reload
```

---

# Procesamiento automático de expiraciones

Antes de generar credenciales y permisos, el script evalúa automáticamente las fechas de expiración configuradas.

Ejemplo:

```json
{
  "status": "active",
  "expires_on": "2027-01-01"
}
```

Si la fecha actual supera:

```text
2027-01-01
```

el sistema actualizará automáticamente:

```json
{
  "status": "expired"
}
```

durante la siguiente ejecución.

Esto garantiza que los usuarios caducados dejen de participar automáticamente en el sistema sin intervención manual.

---

# Generación MQTT

## Contraseñas

Campo fuente:

```json
"mqtt_password"
```

Ejemplo:

```json
"mqtt_password": "PASSWORD_SERGIO"
```

Durante generación:

- se procesa con `mosquitto_passwd`
- se añade a la base de contraseñas MQTT

Resultado:

```text
config/generated/mqtt-passwords.txt
```

---

## ACL automáticas

Permisos generados automáticamente según el tipo de usuario.

### Usuario estándar

Ejemplo:

```text
user sergio
topic read owntracks/sergio/#
topic write owntracks/sergio/#
```

Solo puede operar dentro de su propio namespace MQTT.

---

### Usuario con privilegios ampliados

Si:

```json
"mqtt_admin": true
```

resultado:

```text
topic read owntracks/#
topic write owntracks/<usuario>/#
```

Permite inspección global de actividad MQTT, manteniendo escritura limitada al propio usuario.

---

### Usuario interno del sistema

Ejemplo:

```json
"system_user": true
```

caso típico:

```text
recorder
```

Resultado:

```text
user recorder
topic read owntracks/#
```

Características:

- sin token API
- sin participación en visibilidad
- sin permisos de escritura MQTT
- uso interno entre componentes

---

# Conservación de credenciales

Los usuarios pueden conservar o eliminar sus credenciales cuando dejan de estar activos.

Campo:

```json
"retain_credentials": true
```

---

## Conservación habilitada

Si:

```json
"retain_credentials": true
```

el usuario conservará:

- contraseña MQTT
- token API

aunque pase a:

```json
"status": "expired"
```

o:

```json
"status": "disabled"
```

Esto permite reactivar posteriormente al usuario sin redistribuir credenciales.

---

## Conservación deshabilitada

Si:

```json
"retain_credentials": false
```

el sistema eliminará automáticamente:

- credenciales MQTT
- token API

cuando el usuario deje de estar activo.

Al reactivarlo será necesario generar nuevas credenciales.

---

# Generación de tokens API

## Primera creación

Si el usuario no existe en:

```text
config/generated/api-tokens.txt
```

se genera automáticamente un nuevo token usando:

```bash
openssl rand -hex 24
```

Resultado:

token hexadecimal de 48 caracteres.

---

## Persistencia

Si el usuario ya existe:

su token se conserva.

Esto evita romper clientes ya configurados.

Ejemplo:

Guru Maps seguirá funcionando tras cambios no relacionados.

---

## Regeneración selectiva

Si:

```json
"regen_token": true
```

el token se reemplaza automáticamente.

Ejemplo:

```json
"sergio": {
  "regen_token": true
}
```

Tras ejecutar:

```bash
./auth/generate.sh
```

el usuario recibirá un nuevo token.

---

## Reset automático

Después de regenerar:

```json
"regen_token"
```

se restablece automáticamente a:

```json
false
```

Esto evita rotaciones accidentales repetidas.

---

## Usuarios eliminados

Si un usuario desaparece completamente de:

```text
config/users.json
```

sus credenciales desaparecen automáticamente del sistema.

---

## Usuarios expirados

Si el usuario expira:

```json
"status": "expired"
```

el comportamiento dependerá de:

```json
"retain_credentials"
```

permitiendo conservar o eliminar credenciales según la configuración elegida.

---

# Runtime de visibilidad

El script genera:

```text
data/runtime/visibility.json
```

a partir de:

- grupos
- ocultaciones
- roles

Solo incluye usuarios:

- activos
- no marcados como `system_user`

Esto desacopla configuración declarativa del runtime operativo.

---

# Modos de ejecución

## MQTT ya arrancado

Si detecta:

```text
nookmesh-mqtt
```

usa modo rápido.

Proceso:

- copia datos temporales al contenedor
- ejecuta `mosquitto_passwd` dentro del contenedor
- recupera el resultado generado

Ventajas:

- más rápido
- reutiliza el entorno existente
- evita contenedores auxiliares

---

## Bootstrap helper

Si MQTT aún no está arrancado:

el script crea temporalmente:

```text
nookmesh-auth-helper
```

usando:

```text
eclipse-mosquitto:latest
```

para ejecutar:

```text
mosquitto_passwd
```

Esto permite generar credenciales incluso antes del primer despliegue.

Muy útil durante instalación inicial.

---

# Reinicio automático

Tras desplegar archivos generados, el script detecta servicios activos y reinicia automáticamente los que estén en ejecución.

Servicios compatibles:

```text
nookmesh-mqtt
nookmesh-recorder
nookmesh-worker
nookmesh-api
```

Esto garantiza aplicación inmediata de cambios.

---

# Integración con suscripciones

El servicio:

```text
nookmesh-subscriptions
```

ejecuta periódicamente:

```bash
./auth/generate.sh
```

para aplicar:

- expiraciones automáticas
- reactivaciones manuales
- cambios de estado
- actualización de credenciales

La activación del servicio se controla mediante:

```env
ENABLE_SUBSCRIPTIONS=true
```

---

# Dependencias

Requeridas:

```text
docker
jq
openssl
```

Si falta alguna dependencia:

el script aborta.

---

# Cuándo ejecutarlo

Ejecuta:

```bash
./auth/generate.sh
```

cuando cambies:

### Usuarios

```text
config/users.json
```

---

### Estado del usuario

```json
status
expires_on
retain_credentials
```

---

### Contraseñas MQTT

```json
mqtt_password
```

---

### Privilegios MQTT

```json
mqtt_admin
```

---

### Modelo de visibilidad

```json
grupos
oculto_para
rol
```

---

### Rotación de tokens

```json
regen_token
```

---

# Archivos que NO debes editar manualmente

No editar:

```text
config/generated/mqtt-passwords.txt
config/generated/mqtt-acl.txt
config/generated/api-tokens.txt
data/runtime/visibility.json
```

Se regeneran automáticamente.

Editar siempre:

```text
config/users.json
```

---

# Seguridad

Buenas prácticas:

- no versionar archivos generados sensibles
- proteger `users.json`
- no compartir tokens API
- regenerar tokens ante sospecha
- usar TLS en producción

---

# Troubleshooting

## Cambié users.json y no ocurre nada

Ejecuta:

```bash
./auth/generate.sh
```

---

## Token no cambia

Verifica:

```json
"regen_token": true
```

---

## MQTT rechaza autenticación

Revisar:

- `mqtt_password`
- ejecución correcta de `generate.sh`
- reinicio del broker

---

## Usuario eliminado sigue funcionando

Ejecuta:

```bash
./auth/generate.sh
```

---

## Usuario no vuelve a activarse

Verifica:

```json
{
  "status": "active",
  "expires_on": null
}
```

y vuelve a ejecutar:

```bash
./auth/generate.sh
```
