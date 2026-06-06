# Changelog

🇬🇧 [English version](CHANGELOG.md)

Todos los cambios relevantes de NookMesh se documentarán en este archivo.

El proyecto sigue el esquema de versionado Semántico (SemVer).

---

## [0.2.1] - 2026-06-06

### Modificado

- Mejorado el entorno de ejecución del contenedor `nookmesh-subscriptions`.
- Añadido soporte de zona horaria `Europe/Madrid` para tareas programadas.
- Mejorado el registro del servicio de suscripciones para facilitar diagnóstico y observabilidad.
- Mejorado el registro de reinicio de servicios en `auth/generate.sh`.
- Mejorado el registro de ejecución de tareas programadas.

### Corregido

- Corregida la ejecución automática de `auth/generate.sh` desde el servicio de suscripciones.
- Añadidas las dependencias runtime requeridas (`docker-cli`, `jq` y `openssl`) al contenedor de suscripciones.
- Añadido acceso al socket Docker del host para permitir la gestión de servicios desde el contenedor.
- Corregida la configuración horaria del contenedor de suscripciones.
- Corregida la regeneración automática de archivos runtime asociados a expiraciones de usuarios.
- Corregida la actualización automática de `visibility.json`, ACL MQTT y credenciales derivadas durante las ejecuciones programadas.

---

## [0.2.0] - 2026-05-29

### Añadido

- Gestión del ciclo de vida de usuarios.
- Estados de usuario: `active`, `disabled` y `expired`.
- Fechas de expiración mediante `expires_on`.
- Políticas de conservación de credenciales mediante `retain_credentials`.
- Procesamiento automático de expiraciones.
- Servicio programador de suscripciones (`nookmesh-subscriptions`).
- Opción de configuración runtime `ENABLE_SUBSCRIPTIONS`.
- Documentación completa del sistema de suscripciones.

### Modificado

- Refactorización de `auth/generate.sh`.
- La generación del runtime de visibilidad ahora respeta el estado de los usuarios.
- La generación de contraseñas MQTT ahora soporta políticas de ciclo de vida.
- La generación de ACL MQTT ahora soporta políticas de ciclo de vida.
- La generación de tokens API ahora soporta políticas de ciclo de vida.
- Actualización de los ejemplos de usuarios para reflejar el nuevo modelo de gestión.

### Documentación

- Actualización del README.
- Actualización del índice de documentación técnica.
- Actualización de la documentación de Usuarios.
- Actualización de la documentación del Generador de autenticación.
- Actualización de la documentación de Filtros operativos.
- Incorporación de la documentación de Suscripciones.

---

## [0.1.0] - Primera versión pública

### Añadido

- Integración con OwnTracks.
- Capa de transporte MQTT mediante Mosquitto.
- Integración con OwnTracks Recorder.
- API GeoJSON.
- Integración con Guru Maps.
- Soporte multiusuario.
- Soporte multi-dispositivo.
- Modelo de visibilidad basado en grupos.
- Autenticación MQTT y generación automática de ACL.
- Autenticación mediante tokens API.
- Arquitectura de despliegue basada en Docker.
- Soporte para despliegues seguros mediante TLS.
- Documentación técnica inicial.