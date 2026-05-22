# NookMesh

[English](../README.md)

**Plataforma privada, segura y autoalojada para compartir ubicaciones en tiempo real entre amigos, familia o equipos.**

NookMesh es una plataforma autoalojada de compartición de ubicación construida sobre **OwnTracks**, **MQTT**, **Docker** y una **API GeoJSON protegida**.

Permite recopilar ubicaciones de dispositivos móviles en tiempo real, aplicar reglas avanzadas de visibilidad y mostrar posiciones en clientes de mapas como **Guru Maps**, manteniendo el control total sobre la infraestructura y los datos.

A diferencia de las plataformas comerciales de seguimiento, NookMesh está diseñado con una arquitectura centrada en la privacidad:

- Tu servidor
- Tu broker MQTT
- Tu API
- Tus reglas de acceso
- Tus tokens
- Tus datos
- Tus grupos

NookMesh soporta despliegues multiusuario, visibilidad basada en grupos, roles con privilegios especiales, autenticación segura mediante tokens y seguimiento desde múltiples dispositivos por usuario.

---

## Características

- Seguimiento de ubicación en tiempo real usando OwnTracks
- Infraestructura MQTT autoalojada
- Despliegue completo mediante Docker
- API protegida mediante tokens
- Filtrado de visibilidad basado en grupos
- Reglas de ocultación entre grupos
- Acceso privilegiado para roles staff/admin
- Soporte multi-dispositivo por usuario
- Generación automática y regeneración de tokens
- Entrega protegida de estilos MapCSS
- Integración con Guru Maps
- Filtrado dinámico de GeoJSON por usuario
- Arquitectura preparada para TLS
- Diseño centrado en privacidad
- Sin dependencia de servicios cloud de terceros

---

## Arquitectura general

NookMesh sigue una arquitectura modular autoalojada:

```text
OwnTracks (iOS / Android)
            │
            │ MQTT sobre TLS
            ▼
      Broker Mosquitto
            │
            ▼
    OwnTracks Recorder
            │
            ▼
  Worker exportador GeoJSON
            │
            ▼
     API FastAPI filtrada
            │
            ├── Endpoint GeoJSON protegido
            └── Endpoint MapCSS protegido
                    │
                    ▼
                 Guru Maps
```

---

## Casos de uso

NookMesh es ideal para:

- Familias que quieren compartir ubicaciones de forma privada
- Grupos de amigos en viajes o eventos
- Equipos de senderismo o actividades al aire libre
- Coordinación de voluntarios
- Comunidades que usan redes mesh
- Usuarios self-hosted preocupados por la privacidad
- Usuarios técnicos que quieren control total sobre su infraestructura

---

## ¿Por qué NookMesh?

La mayoría de plataformas comerciales de compartición de ubicación requieren confiar en un proveedor externo que almacena o procesa tus datos.

NookMesh propone un enfoque diferente.

Toda la cadena de datos permanece bajo tu control:

- El dispositivo publica su ubicación
- Tu broker MQTT la recibe
- Tu recorder la almacena
- Tu worker la transforma
- Tu API decide quién puede verla
- Tu cliente de mapas la consume

Ningún servicio externo tiene acceso a tus ubicaciones salvo que tú lo expongas explícitamente.

Esto hace que NookMesh sea especialmente adecuado para usuarios que valoran:

- privacidad
- propiedad de sus datos
- transparencia
- auditabilidad
- extensibilidad

---

## Instalación rápida

### Requisitos

Antes de desplegar NookMesh necesitarás:

- Un servidor Linux o NAS compatible con Docker
- Docker
- Docker Compose
- `jq`
- `openssl`
- Un dominio o subdominios (recomendado para producción)
- Certificados TLS válidos (recomendado para MQTT y API)
- App OwnTracks (iOS / Android)
- Guru Maps (para visualización)

Ejemplo de entorno válido:

- Synology NAS
- Ubuntu Server
- Debian
- Cualquier host Linux con Docker

---

## Inicio rápido

Clona el repositorio:

```bash
git clone https://github.com/sercontri/nookmesh.git
cd nookmesh
```

Copia los archivos de ejemplo:

```bash
cp config/users.example.json config/users.json
cp config/filtros.example.env config/filtros.env
cp config/recorder.example.env config/recorder.env
```

Edita la configuración según tu entorno:

```bash
vi config/users.json
vi config/filtros.env
vi config/recorder.env
```

Genera archivos de autenticación y runtime:

```bash
./auth/generate.sh
```

Levanta los contenedores:

```bash
docker compose -f mqtt/docker-compose.yml up -d
docker compose -f recorder/docker-compose.yml up -d
docker compose -f worker/docker-compose.yml up -d
docker compose -f api/docker-compose.yml up -d
```

Verifica el estado:

```bash
docker ps
```

---

## Primer despliegue

El flujo recomendado para un primer despliegue es:

1. Configurar usuarios (users.json)
2. Generar autenticación (generate.sh)
3. Configurar recorder.env
4. Arrancar MQTT
5. Arrancar recorder
6. Arrancar worker
7. Arrancar API
8. Configurar OwnTracks
9. Configurar capa de mapa para Guru Maps

---

## Primer usuario

El archivo `config/users.json` define usuarios, grupos, permisos y tokens.

Ejemplo mínimo:

```json
{
  "users": {
    "recorder": {
      "enabled": true,
      "mqtt_admin": true,
      "mqtt_password": "CHANGE_ME",
      "system_user": true
    },
    "sergio": {
      "enabled": true,
      "mqtt_password": "CHANGE_ME",
      "regen_token": false,
      "grupos": ["familia"]
    }
  }
}
```

Después de ejecutar:

```bash
./auth/generate.sh
```

se generarán automáticamente:

```text
config/generated/mqtt-passwords.txt
config/generated/mqtt-acl.txt
config/generated/api-tokens.txt
data/runtime/visibility.json
```

---

## Qué hace generate.sh

El generador automatiza:

- creación de credenciales MQTT
- creación de ACL MQTT
- generación de tokens API
- construcción de reglas de visibilidad
- regeneración selectiva de tokens
- reinicio automático de servicios compatibles

Esto evita editar manualmente archivos sensibles.

---

## Acceso API

Tras el despliegue, los endpoints protegidos siguen este formato:

GeoJSON:

```text
https://geojson.tudominio.com/nookmesh.geojson?token=TU_TOKEN
```

MapCSS:

```text
https://style.tudominio.com/nookmesh_v1.mapcss?token=TU_TOKEN
```

Cada usuario recibe su propio token de acceso.

---

## Notas de producción

Para un despliegue real se recomienda:

- usar TLS en MQTT
- usar HTTPS en la API
- no exponer puertos innecesarios
- proteger el acceso al NAS/servidor
- usar contraseñas MQTT robustas
- usar tokens API individuales
- mantener copias de seguridad del proyecto

---

## Configuración

NookMesh se configura mediante archivos independientes para separar responsabilidades:

```text
config/users.json
config/filtros.env
config/recorder.env
```

---

## users.json

Este archivo define usuarios, permisos, grupos y comportamiento de autenticación.

Ejemplo:

```json
{
  "_meta": {
    "description": "NookMesh user configuration"
  },
  "users": {
    "recorder": {
      "enabled": true,
      "mqtt_admin": true,
      "mqtt_password": "CHANGE_ME",
      "system_user": true
    },
    "sergio": {
      "enabled": true,
      "mqtt_password": "CHANGE_ME",
      "regen_token": false,
      "grupos": ["familia", "staff"],
      "oculto_para": ["staff"],
      "rol": "staff"
    }
  }
}
```

---

## Campos disponibles

### enabled

Activa o desactiva un usuario.

```json
"enabled": true
```

Si está en `false`, el usuario no se procesa.

---

### mqtt_password

Contraseña MQTT del usuario.

```json
"mqtt_password": "CHANGE_ME"
```

Usada por OwnTracks para publicar ubicaciones.

---

### mqtt_admin

Permite lectura completa del broker MQTT.

```json
"mqtt_admin": true
```

Pensado para usuarios privilegiados o servicios internos.

---

### system_user

Marca usuarios internos del sistema.

```json
"system_user": true
```

Ejemplo típico:

- recorder

Los usuarios del sistema:

- no reciben token API
- no generan acceso visual
- pueden tener permisos especiales

---

### regen_token

Fuerza regeneración del token API del usuario.

```json
"regen_token": true
```

Uso recomendado:

- compromiso de token
- revocación manual
- rotación puntual

Después de regenerar, vuelve automaticamente a:

```json
"regen_token": false
```

para evitar regeneraciones futuras no deseadas.

---

### grupos

Define pertenencia a grupos.

```json
"grupos": ["familia", "staff"]
```

Los grupos controlan visibilidad entre usuarios.

---

### oculto_para

Oculta un usuario frente a ciertos grupos compartidos.

```json
"oculto_para": ["amigos"]
```

Ejemplo:

si un usuario pertenece a:

```json
["familia", "amigos"]
```

y otro usuario comparte ambos grupos,

el grupo oculto será excluido del cálculo de visibilidad.

---

### rol

Permite roles especiales.

```json
"rol": "staff"
```

Actualmente usado para privilegios ampliados y representación visual diferenciada en Guru Maps

---

## filtros.env

Controla comportamiento del filtrado GeoJSON.

Ejemplo:

```env
MAX_EDAD_MIN=60
EXCLUDE_VIEWER_IN_OUTPUT=true
EXCLUDE_NEARBY_METROS=80
REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY=true
MERGE_CLOSEST_DEVICES=true
MERGE_MAX_METROS=100
```

---

## Parámetros disponibles

### MAX_EDAD_MIN

Edad máxima aceptada para una posición.

```env
MAX_EDAD_MIN=60
```

Posiciones más antiguas quedan excluidas.

---

### EXCLUDE_VIEWER_IN_OUTPUT

Oculta la propia posición del usuario autenticado.

```env
EXCLUDE_VIEWER_IN_OUTPUT=true
```

Evita duplicar la propia ubicación en el cliente de mapas.

---

### EXCLUDE_NEARBY_METROS

Oculta usuarios demasiado cercanos al viewer.

```env
EXCLUDE_NEARBY_METROS=80
```

Reduce ruido visual.

---

### REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY

Exige que la posición del viewer sea reciente para aplicar exclusión por proximidad.

```env
REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY=true
```

Evita decisiones basadas en posiciones antiguas.

---

### MERGE_CLOSEST_DEVICES

Fusiona dispositivos cercanos del mismo usuario.

```env
MERGE_CLOSEST_DEVICES=true
```

Útil cuando un usuario publica desde múltiples dispositivos.

---

### MERGE_MAX_METROS

Distancia máxima para mostrar todos los dispositivos de un mismo usuario, si se encuentran dentro del radio, se muestra el ultimo que envía posición.

```env
MERGE_MAX_METROS=100
```

---

## recorder.env

Configuración del recorder OwnTracks.

Define parámetros como:

- broker MQTT
- autenticación TLS
- almacenamiento
- puertos
- configuración del servicio

---

## Modelo de visibilidad

Uno de los pilares de NookMesh es su sistema de visibilidad basado en grupos y roles.

A diferencia de una compartición simple "todos ven a todos", NookMesh permite definir exactamente quién puede ver a quién.

La visibilidad se calcula dinámicamente en cada petición GeoJSON.

---

## Grupos

Cada usuario puede pertenecer a uno o varios grupos:

```json
"grupos": ["familia", "amigos", "senderismo"]
```

Los grupos representan ámbitos de compartición.

Ejemplos:

- familia
- amigos
- trabajo
- senderismo
- voluntarios
- meshtastic
- comunidad

Un usuario solo verá posiciones de otros usuarios con los que comparta al menos un grupo visible.

---

## Ejemplo básico

Usuario A:

```json
"grupos": ["familia"]
```

Usuario B:

```json
"grupos": ["familia"]
```

Resultado:

```text
A puede ver a B
B puede ver a A
```

---

Usuario C:

```json
"grupos": ["trabajo"]
```

Resultado:

```text
A no puede ver a C
C no puede ver a A
```

---

## Múltiples grupos

Un usuario puede pertenecer a varios grupos:

```json
"grupos": ["familia", "senderismo"]
```

La visibilidad se concede si existe al menos un grupo compartido.

Ejemplo:

Usuario A:

```json
["familia", "senderismo"]
```

Usuario B:

```json
["senderismo"]
```

Resultado:

```text
A y B pueden verse
```

---

## oculto_para

Permite ocultar selectivamente un usuario frente a determinados grupos.

Ejemplo:

```json
{
  "grupos": ["familia", "amigos"],
  "oculto_para": ["amigos"]
}
```

Interpretación:

- el usuario pertenece a ambos grupos
- pero no quiere ser visible a través del grupo `amigos`

Resultado:

- usuarios que solo compartan `amigos` no lo verán
- usuarios que compartan `familia` sí podrán verlo

Esto permite visibilidad parcial muy flexible.

---

## Ejemplo real

Usuario:

```json
{
  "grupos": ["familia", "senderismo", "amigos"],
  "oculto_para": ["amigos"]
}
```

Otro usuario:

```json
{
  "grupos": ["amigos"]
}
```

Resultado:

```text
No visible
```

---

Otro usuario:

```json
{
  "grupos": ["familia"]
}
```

Resultado:

```text
Visible
```

---

## Roles

Opcionalmente un usuario puede tener un rol:

```json
"rol": "staff"
```

Actualmente el rol puede utilizarse para:

- privilegios ampliados
- reglas especiales de visibilidad
- diferenciación visual en mapas
- futuras extensiones del sistema

---

## mqtt_admin

Algunos usuarios pueden tener privilegios administrativos MQTT:

```json
"mqtt_admin": true
```

Esto concede acceso completo de lectura sobre tópicos MQTT:

```text
owntracks/#
```

Pensado para:

- administradores
- monitorización
- servicios internos

No afecta directamente a la visibilidad GeoJSON.

---

## system_user

Los usuarios internos del sistema:

```json
"system_user": true
```

No participan en visualización.

Ejemplo:

```json
recorder
```

Estos usuarios existen para tareas de infraestructura.

---

## Cómo se calcula la visibilidad

En cada petición mediante la capa de Guru Maps:

1. Se autentica el usuario mediante token
2. Se identifica su configuración
3. Se obtienen sus grupos
4. Se aplican exclusiones por `oculto_para`
5. Se comparan grupos con otros usuarios
6. Se filtran posiciones no autorizadas
7. Se devuelve únicamente lo permitido

Este cálculo ocurre dinámicamente en tiempo real.

---

## Filosofía del modelo

NookMesh no usa un modelo rígido.

Permite construir reglas sociales reales.

Ejemplos:

- familia que comparte solo entre sí
- amigos visibles solo en eventos
- staff con acceso ampliado
- usuarios ocultos frente a ciertos grupos
- comunidades mesh con distintos niveles de acceso

El objetivo es flexibilidad sin depender de servicios externos.

---

## Configuración de OwnTracks

NookMesh utiliza OwnTracks como cliente de publicación de ubicaciones.

Compatible con:

- iPhone, iPad (iOS)
- Android

Cada dispositivo publica su ubicación mediante usuario y contraseña al broker MQTT de NookMesh.

---

## Parámetros básicos

En OwnTracks configura:

### Mode

```text
Private MQTT
```

---

### Host

Tu broker MQTT:

```text
mqtt.tudominio.com
```

---

### Port

TLS recomendado:

```text
8883
```

Sin TLS (solo pruebas locales):

```text
1883
```

---

### Username

Usuario definido en:

```text
config/users.json
```

Ejemplo:

```text
sergio
```

---

### Password

Contraseña MQTT del usuario:

```text
mqtt_password
```

---

### Device ID

Identificador del dispositivo.

Ejemplo:

```text
iphone
redmi
pixel
car
watch
```

Esto permite multi-dispositivo por usuario.

---

### Tracker ID

Iniciales o identificador corto.

Ejemplo:

```text
SE
RA
AN
```

Se usa en representación visual de la capa de mapa en Guru Maps

---

## Seguridad TLS

Para producción se recomienda siempre:

```text
Use TLS = enabled
```

y certificados válidos.

Esto protege:

- credenciales MQTT
- posiciones GPS
- metadatos de dispositivo

---

## Tópicos MQTT

NookMesh usa estructura estándar OwnTracks:

```text
owntracks/<usuario>/<device>
```

Ejemplo:

```text
owntracks/sergio/iphone
owntracks/raul/redmi
```

---

## Request Location

OwnTracks soporta solicitud remota de ubicación.

El soporte y comportamiento depende del cliente y de permisos MQTT.

NookMesh mantiene compatibilidad con el flujo estándar de OwnTracks.

---

## Multi-dispositivo

Un mismo usuario puede publicar desde varios dispositivos:

```text
owntracks/sergio/iphone
owntracks/sergio/ipad
owntracks/sergio/car
```

NookMesh puede:

- mostrar todos
- fusionar dispositivos cercanos
- representar solo el más reciente según configuración

---

## Visualización en mapas

NookMesh expone endpoints protegidos para clientes compatibles con GeoJSON.

Ejemplo:

GeoJSON:

```text
https://geojson.tudominio.com/nookmesh.geojson?token=TOKEN
```

MapCSS:

```text
https://style.tudominio.com/nookmesh_v1.mapcss?token=TOKEN
```

---

## Guru Maps

Plantilla de superposición de ejemplo para Guru Maps:

```text
docs/nookmesh_gurumaps_overlay.ms
```


Configuración recomendada:

### Nueva capa GeoJSON

Usa:

```text
https://geojson.tudominio.com/nookmesh.geojson?token=TOKEN
```

---

### Estilo MapCSS

Usa:

```text
https://style.tudominio.com/nookmesh_v1.mapcss?token=TOKEN
```

---

## Tokens por usuario

Cada usuario recibe su propio token API.

Esto permite:

- autenticación individual
- filtrado por usuario
- revocación selectiva
- auditoría más sencilla

No compartas tokens entre usuarios, ni capas de Guru Mapas

---

## Compatibilidad

Actualmente NookMesh está optimizado para:

- OwnTracks
- Guru Maps

Al utilizar GeoJSON como formato de salida, otros clientes compatibles podrían integrarse con cambios mínimos.

---

## Seguridad

NookMesh está diseñado con un enfoque **privacy-first** y de mínimo privilegio.

El objetivo es que el control de infraestructura, autenticación y datos permanezca completamente bajo el propietario del despliegue.

---

## Autenticación API

El acceso a endpoints visuales se protege mediante tokens individuales.

Ejemplo:

```text
https://geojson.tudominio.com/nookmesh.geojson?token=TOKEN
```

Cada usuario recibe un token independiente.

Esto permite:

- autenticación individual
- revocación selectiva
- aislamiento entre usuarios
- control granular de acceso

---

## Tokens persistentes

Los tokens no cambian automáticamente en cada regeneración.

Esto evita romper configuraciones activas en clientes como Guru Maps.

Solo cambian cuando:

```json
"regen_token": true
```

está activado para un usuario concreto y se vuelve a ejecutar generate.sh.

---

## Autenticación MQTT

Cada usuario utiliza credenciales MQTT independientes:

```json
"mqtt_password": "..."
```

No se comparten credenciales entre usuarios.

Esto permite:

- aislamiento de acceso
- revocación individual
- auditoría sencilla
- control de permisos MQTT

---

## ACL MQTT

NookMesh genera automáticamente reglas ACL.

Usuarios normales:

```text
owntracks/<usuario>/#
```

Administradores MQTT:

```text
owntracks/#
```

Esto evita edición manual de permisos sensibles.

---

## TLS recomendado

Producción recomendada:

- MQTT sobre TLS
- HTTPS para API
- certificados válidos

Protege:

- credenciales
- posiciones GPS
- metadatos
- tráfico de autenticación

---

## Sin cloud obligatorio

NookMesh no depende de servicios cloud externos.

Tus datos permanecen en tu infraestructura:

- broker MQTT
- recorder
- API
- almacenamiento
- configuración

---

## Separación de componentes

La arquitectura multi-servicio reduce superficie de riesgo.

Separación lógica:

- MQTT broker
- recorder
- worker
- API
- autenticación

Esto mejora:

- mantenimiento
- aislamiento
- troubleshooting
- escalabilidad

---

## Recomendaciones de producción

Para un despliegue seguro:

- usar contraseñas MQTT robustas
- usar TLS
- proteger acceso SSH al host
- no exponer puertos innecesarios
- usar firewall
- hacer backups regulares
- revisar logs periódicamente
- rotar tokens cuando sea necesario

---

## Estructura del proyecto

```text
nookmesh/
├── api/
├── auth/
├── config/
│   ├── cert/
│   ├── generated/
│   ├── users.example.json
│   ├── filtros.example.env
│   └── recorder.example.env
├── data/
│   ├── owntracks/
│   ├── public/
│   └── runtime/
├── mqtt/
├── recorder/
└── worker/
```

---

## Descripción de componentes

### api/

Capa HTTP basada en FastAPI.

Responsabilidades:

- autenticación por token
- filtrado GeoJSON
- entrega de assets
- control de acceso visual

---

### auth/

Provisionado automático.

Responsabilidades:

- generación de credenciales MQTT
- generación de ACL
- generación de tokens API
- construcción de reglas runtime

---

### config/

Configuración persistente.

Incluye:

- usuarios
- filtros
- recorder
- certificados
- archivos generados

---

### data/

Datos persistentes.

Incluye:

- almacenamiento OwnTracks
- runtime generado
- GeoJSON público
- assets visuales

---

### mqtt/

Infraestructura Mosquitto.

Responsabilidades:

- recepción MQTT
- autenticación MQTT
- control ACL

---

### recorder/

Persistencia de ubicaciones OwnTracks.

Responsabilidades:

- ingestión MQTT
- almacenamiento histórico

---

### worker/

Transformación de datos.

Responsabilidades:

- lectura de recorder
- exportación GeoJSON
- fusión de dispositivos
- enriquecimiento de propiedades

---

## Troubleshooting

## Los dispositivos no aparecen

Comprobar:

- contenedor MQTT activo
- contenedor recorder activo
- credenciales MQTT correctas
- configuración OwnTracks correcta
- TLS correctamente configurado
- conectividad entre cliente y broker

Ver logs:

```bash
docker logs nookmesh-mqtt
docker logs nookmesh-recorder
```

---

## No se genera GeoJSON

Comprobar:

- worker activo
- acceso al almacenamiento del recorder
- rutas montadas correctamente
- permisos de archivos

Logs:

```bash
docker logs nookmesh-worker
```

---

## La API devuelve acceso denegado

Comprobar:

- token correcto
- usuario habilitado
- token no revocado
- configuración generada actualizada

Regenerar runtime:

```bash
./auth/generate.sh
```

---

## No aparecen otros usuarios

Comprobar:

- grupos compartidos
- reglas `oculto_para`
- antigüedad de posiciones
- filtros de proximidad
- exclusión del propio viewer

---

## OwnTracks conecta pero no publica

Comprobar:

- host
- puerto
- TLS
- usuario
- contraseña MQTT
- permisos ACL

Tópicos esperados:

```text
owntracks/<usuario>/<device>
```

---

## Problemas con Guru Maps

Comprobar:

- URL GeoJSON correcta
- URL MapCSS correcta
- token válido
- acceso HTTPS
- caché de la app

Verificar manualmente:

```text
https://geojson.tudominio.com/nookmesh.geojson?token=TOKEN
```

---

## Regeneración de credenciales

Tras cambios en usuarios:

```bash
./auth/generate.sh
```

Esto actualiza:

- contraseñas MQTT
- ACL
- tokens API
- runtime de visibilidad

---

## Estado del proyecto

NookMesh es un proyecto activo en evolución.

La arquitectura actual es funcional y utilizada en producción, pero seguirá evolucionando.

Áreas previstas de mejora:

- documentación ampliada
- web oficial
- clientes adicionales
- despliegues simplificados
- observabilidad
- mejoras visuales
- opciones avanzadas de filtrado

---

## Roadmap

Objetivos previstos:

- documentación web completa
- ejemplos de despliegue
- soporte ampliado para clientes GeoJSON
- mejoras en autenticación
- mejores herramientas de administración
- configuración más modular
- integración con más clientes de mapas

---

## Contribuir

Las contribuciones son bienvenidas.

Formas de colaborar:

- Abrir issues
- Proponer mejoras
- Reportar bugs
- Mejorar documentación
- Sugerir integraciones
- Enviar pull requests

Antes de contribuir:

- Nunca incluyas secretos o credenciales reales
- Usa siempre archivos de ejemplo
- Mantén consistencia con la arquitectura existente
- Documenta cambios relevantes

---

## Filosofía del proyecto

NookMesh nace de una idea simple:

**compartir ubicación no debería requerir entregar tus datos a terceros.**

El proyecto apuesta por:

- privacidad
- control
- transparencia
- autoalojamiento
- simplicidad técnica
- extensibilidad

---

## Apoyo al proyecto

Si NookMesh te resulta útil, hay varias formas de apoyar el proyecto:

- Dar una estrella al repositorio
- Reportar errores o proponer mejoras
- Contribuir con código o documentación
- Compartir el proyecto con otras personas
- Apoyar el desarrollo independiente en Ko-fi:

https://ko-fi.com/nooktrail

Tu apoyo ayuda a mantener infraestructura, mejorar documentación y seguir construyendo herramientas abiertas centradas en privacidad para la comunidad.

---

## Recursos adicionales

En `/docs` encontrarás:

- documentación en español (`README.es.md`)
- plantilla de capa para Guru Maps (`nookmesh_gurumaps_overlay.ms`)

---

## Licencia

NookMesh se distribuye bajo licencia **GNU Affero General Public License v3.0 (AGPLv3)**.

Esto significa, en resumen:

- puedes usar NookMesh libremente
- puedes modificarlo
- puedes desplegarlo en tu propia infraestructura
- puedes redistribuirlo
- puedes usarlo incluso como parte de un servicio

Pero si modificas NookMesh y lo ofreces como servicio accesible por red, debes poner esas modificaciones a disposición bajo la misma licencia.

El objetivo es proteger la libertad del proyecto y asegurar que las mejoras vuelvan a la comunidad.

Consulta el archivo `LICENSE` para el texto legal completo.