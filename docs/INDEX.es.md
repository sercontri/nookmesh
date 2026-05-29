# Documentación técnica de NookMesh

🇬🇧 [English version](INDEX.md)

Bienvenido a la documentación técnica de NookMesh.

Esta documentación describe la arquitectura, instalación, configuración, integraciones y operación actual del proyecto.

Si buscas una visión general, casos de uso o información introductoria, consulta el README principal del repositorio.

## Alcance de esta documentación

Aquí encontrarás información sobre:

- instalación y despliegue
- arquitectura interna
- configuración operativa
- autenticación y seguridad
- integraciones compatibles
- API GeoJSON
- resolución de problemas
- roadmap técnico

La documentación está orientada a despliegues reales y describe el funcionamiento actual del proyecto.

---

# Primeros pasos

## Requisitos

Qué necesitas antes de desplegar NookMesh:

- [Requisitos](getting-started/requirements.es.md)

## Instalación

Preparación inicial del entorno, archivos de configuración y despliegue base del stack:

- [Instalación](getting-started/installation.es.md)

## Inicio rápido

Validación rápida de una instalación funcional extremo a extremo:

- [Inicio rápido](getting-started/quickstart.es.md)

---

# Arquitectura

## Visión general

Arquitectura conceptual del sistema:

- [Visión general](architecture/overview.es.md)

## Componentes

Descripción detallada de servicios:

- [Componentes](architecture/components.es.md)

## Flujo de datos

Recorrido completo de una ubicación desde el dispositivo hasta el cliente de visualización:

- [Flujo de datos](architecture/data-flow.es.md)

## Persistencia

Modelo de almacenamiento y datos operativos:

- [Persistencia](architecture/persistence.es.md)

---

# Configuración

## Usuarios

Modelo completo de usuarios, permisos, estados, expiraciones y configuración de suscripciones:

- [Usuarios](configuration/users.es.md)

## MQTT

Broker, autenticación y transporte:

- [MQTT](configuration/mqtt.es.md)

## Generador de autenticación

Generación y mantenimiento de credenciales MQTT, ACL, tokens API, estados de usuario y configuración runtime:

- [Generador de autenticación](configuration/auth-generator.es.md)

## Suscripciones

Servicio autónomo para gestión automática de expiraciones, renovaciones y mantenimiento periódico de usuarios:

- [Suscripciones](configuration/subscriptions.es.md)

## Filtros operativos

Comportamiento del procesamiento GeoJSON y parámetros globales de ejecución:

- [Filtros](configuration/filters.es.md)

## Visibilidad

Reglas de exposición y ocultación entre usuarios:

- [Visibilidad](configuration/visibility.es.md)

## Multi-dispositivo

Gestión de múltiples dispositivos asociados a un mismo usuario:

- [Multi-dispositivo](configuration/multi-device.es.md)

## TLS y seguridad de transporte

Protección de comunicaciones y despliegues seguros:

- [TLS](configuration/tls.es.md)

---

# Integraciones

## OwnTracks

Cliente principal de publicación de ubicaciones:

- [OwnTracks](integrations/owntracks.es.md)

## Guru Maps

Cliente principal de visualización:

- [Guru Maps](integrations/gurumaps.es.md)

## MapCSS

Personalización visual de la representación en clientes compatibles:

- [MapCSS](integrations/mapcss.es.md)

---

# API

## Autenticación

Modelo de acceso a endpoints protegidos:

- [Autenticación](api/authentication.es.md)

## Endpoints GeoJSON

Consumo de ubicaciones mediante GeoJSON:

- [Endpoints GeoJSON](api/geojson-endpoints.es.md)

---

# Roadmap

## Hoja de ruta híbrida de localización

Evolución futura hacia múltiples fuentes de ubicación y transporte híbrido:

- [Hoja de ruta híbrida](roadmap/hybrid-location-roadmap.es.md)

---

# Resolución de problemas

## Problemas comunes

Diagnóstico y resolución de incidencias habituales:

- [Problemas comunes](troubleshooting/common-issues.es.md)

---

# Ruta recomendada para nuevos usuarios

Si es tu primera instalación de NookMesh, este es el recorrido recomendado:

1. [Visión general](architecture/overview.es.md)
2. [Requisitos](getting-started/requirements.es.md)
3. [Instalación](getting-started/installation.es.md)
4. [Inicio rápido](getting-started/quickstart.es.md)
5. [Usuarios](configuration/users.es.md)
6. [MQTT](configuration/mqtt.es.md)
7. [Generador de autenticación](configuration/auth-generator.es.md)
8. [Suscripciones](configuration/subscriptions.es.md)
9. [Filtros](configuration/filters.es.md)
10. [Visibilidad](configuration/visibility.es.md)
11. [OwnTracks](integrations/owntracks.es.md)
12. [Guru Maps](integrations/gurumaps.es.md)
13. [Problemas comunes](troubleshooting/common-issues.es.md)
