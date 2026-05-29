# Servicio de suscripciones

🇬🇧 [English version](subscriptions.md)

NookMesh incluye un servicio opcional encargado de procesar automáticamente el ciclo de vida de las suscripciones y la expiración de usuarios.

Este servicio permite automatizar la transición de estados de usuario sin depender de tareas programadas específicas del sistema operativo o de la plataforma donde se despliegue NookMesh.

---

## Objetivo

El servicio de suscripciones se encarga de:

- detectar usuarios expirados
- actualizar automáticamente estados de usuario
- regenerar credenciales cuando sea necesario
- actualizar ACL MQTT
- actualizar tokens API
- actualizar el runtime de visibilidad
- mantener sincronizados todos los componentes dependientes

La lógica se basa en la información definida en:

```text
config/users.json
```

---

# Arquitectura

El servicio se ejecuta como un contenedor independiente:

```text
nookmesh-subscriptions
```

Esto permite:

- independencia respecto al sistema operativo
- compatibilidad con Synology
- compatibilidad con Docker estándar
- despliegue homogéneo en cualquier entorno

No requiere:

```text
cron
systemd
scheduled tasks
```

ni ningún mecanismo específico de la plataforma.

---

# Configuración

La configuración se realiza mediante:

```text
config/filtros.env
```

Parámetro asociado:

```env
ENABLE_SUBSCRIPTIONS=true
```

---

## ENABLE_SUBSCRIPTIONS=true

Cuando está habilitado:

```env
ENABLE_SUBSCRIPTIONS=true
```

el servicio ejecuta periódicamente:

```bash
./auth/generate.sh
```

para aplicar automáticamente los cambios necesarios.

Procesa:

- expiraciones
- cambios de estado
- regeneración de archivos runtime
- sincronización de credenciales

---

## ENABLE_SUBSCRIPTIONS=false

Cuando está deshabilitado:

```env
ENABLE_SUBSCRIPTIONS=false
```

el contenedor permanece ejecutándose pero no realiza ninguna acción.

No se aplicarán automáticamente:

- expiraciones
- cambios de estado
- actualizaciones de credenciales

Los cambios solo se aplicarán mediante ejecución manual de:

```bash
./auth/generate.sh
```

---

## Reinicio requerido

Tras modificar:

```env
ENABLE_SUBSCRIPTIONS
```

es necesario reiniciar el contenedor:

```bash
docker restart nookmesh-subscriptions
```

El valor se carga durante el arranque.

---

# Estados de usuario

El servicio trabaja sobre el campo:

```json
"status"
```

definido en:

```text
config/users.json
```

---

## active

Usuario operativo.

Ejemplo:

```json
"status": "active"
```

Características:

- credenciales MQTT activas
- token API activo
- incluido en visibility runtime
- visible para otros usuarios según reglas configuradas

---

## disabled

Usuario deshabilitado manualmente.

Ejemplo:

```json
"status": "disabled"
```

Características:

- no participa operativamente
- no recupera actividad automáticamente
- requiere intervención explícita del administrador

Este estado tiene prioridad sobre la fecha de expiración.

---

## expired

Usuario expirado automáticamente.

Ejemplo:

```json
"status": "expired"
```

Se aplica cuando:

```json
"expires_on"
```

contiene una fecha anterior a la fecha actual.

---

# Expiraciones automáticas

Campo utilizado:

```json
"expires_on"
```

Ejemplo:

```json
"expires_on": "2026-12-31"
```

Cuando la fecha es superada:

```text
expires_on < fecha_actual
```

el usuario pasa automáticamente a:

```json
"status": "expired"
```

durante la siguiente ejecución del servicio.

---

# Renovaciones

Una suscripción puede renovarse simplemente modificando:

```json
"expires_on"
```

a una fecha futura o eliminando la fecha de expiración:

```json
"expires_on": null
```

En la siguiente ejecución:

```bash
./auth/generate.sh
```

el usuario volverá automáticamente a:

```json
"status": "active"
```

siempre que no esté marcado como:

```json
"status": "disabled"
```

---

# Retención de credenciales

Campo utilizado:

```json
"retain_credentials"
```

Ejemplo:

```json
"retain_credentials": true
```

---

## true

Las credenciales se conservan aunque el usuario expire.

Se mantienen:

- MQTT
- token API

Útil para:

- renovaciones temporales
- periodos de gracia
- recuperación rápida de acceso

---

## false

Las credenciales se eliminan cuando el usuario deja de estar activo.

Esto implica:

- eliminación de acceso MQTT
- eliminación de token API
- retirada completa del entorno operativo

---

# Relación con generate.sh

El servicio no modifica directamente los archivos generados.

Toda la lógica operativa sigue centralizada en:

```text
auth/generate.sh
```

El contenedor simplemente ejecuta periódicamente dicho proceso.

Esto garantiza que exista una única fuente de generación y mantenimiento.

---

# Relación con otros componentes

## Usuarios

Fuente principal:

```text
config/users.json
```

---

## Generador de autenticación

Proceso ejecutado:

```text
auth/generate.sh
```

---

## MQTT

Actualización automática de:

```text
mqtt-passwords.txt
mqtt-acl.txt
```

---

## API

Actualización automática de:

```text
api-tokens.txt
```

---

## Runtime

Actualización automática de:

```text
visibility.json
```

---

# Buenas prácticas

## Utilizar expiraciones

Preferible a eliminar usuarios temporalmente.

Ejemplo:

```json
"expires_on": "2026-12-31"
```

---

## Reservar disabled para bloqueos manuales

Usar:

```json
"status": "disabled"
```

solo cuando se desee impedir reactivación automática.

---

## Mantener retain_credentials según la política deseada

Para renovaciones rápidas:

```json
"retain_credentials": true
```

Para revocación completa:

```json
"retain_credentials": false
```

---

# Troubleshooting

## El usuario no expira

Verificar:

```json
"expires_on"
```

y que:

```env
ENABLE_SUBSCRIPTIONS=true
```

---

## El usuario no vuelve a activarse

Verificar que:

```json
"status"
```

no esté configurado como:

```json
"disabled"
```

---

## Los cambios no se aplican

Ejecutar:

```bash
docker restart nookmesh-subscriptions
```

si se ha modificado:

```env
ENABLE_SUBSCRIPTIONS
```

o lanzar manualmente:

```bash
./auth/generate.sh
```

para forzar una actualización inmediata.
