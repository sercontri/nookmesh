# Instalación

Este documento describe el proceso base de instalación de NookMesh sobre un entorno Linux o NAS compatible con Docker.

La configuración avanzada de usuarios, visibilidad, seguridad e integraciones se documenta en secciones específicas.

---

## Flujo general de instalación

El proceso recomendado es:

1. Clonar el repositorio
2. Preparar archivos de configuración
3. Configurar usuarios y servicios base
4. Generar credenciales y archivos operativos
5. Desplegar los servicios
6. Validar el stack
7. Configurar clientes (OwnTracks y Guru Maps)

---

## Clonar el repositorio

Descarga el código fuente:

```bash
git clone https://github.com/sercontri/nookmesh.git
cd nookmesh
```

---

## Estructura del proyecto

NookMesh está organizado como una arquitectura modular basada en servicios independientes.

```text
nookmesh/
├── mqtt/
├── recorder/
├── worker/
├── api/
├── auth/
├── config/
├── data/
└── docs/
```

Descripción general:

- **mqtt/** → broker MQTT (Mosquitto)
- **recorder/** → almacenamiento de ubicaciones OwnTracks
- **worker/** → generación y enriquecimiento de GeoJSON
- **api/** → API protegida para consumo de clientes
- **auth/** → generación automática de credenciales, ACL, tokens y runtime
- **config/** → configuración editable
- **data/** → almacenamiento persistente y datos operativos
- **docs/** → documentación técnica

---

## Preparar configuración inicial

Copia los archivos de ejemplo:

```bash
cp config/users.example.json config/users.json
cp config/recorder.example.env config/recorder.env
cp config/filtros.example.env config/filtros.env
```

Estos archivos deben adaptarse a tu entorno antes del despliegue.

---

## Configurar usuarios

Edita:

```text
config/users.json
```

Este archivo define:

- usuarios humanos
- usuarios internos del sistema
- credenciales MQTT
- permisos administrativos
- grupos de visibilidad
- reglas de ocultación
- comportamiento de tokens API

Importante:

- el usuario interno `recorder` debe existir
- debe existir al menos un usuario humano habilitado

La estructura completa se documenta en:

- [Usuarios](../configuration/users.es.md)

---

## Configurar recorder

Edita:

```text
config/recorder.env
```

Este archivo define la configuración del servicio OwnTracks Recorder.

Incluye parámetros como:

- host MQTT
- puerto MQTT
- credenciales del recorder
- almacenamiento
- configuración operativa del recorder

Importante:

sin una configuración correcta del recorder, NookMesh no podrá recibir ni persistir ubicaciones.

---

## Configurar filtros (opcional inicialmente)

Edita:

```text
config/filtros.env
```

Este archivo controla parámetros operativos del procesamiento GeoJSON, como filtros temporales, comportamiento de agregación o límites operativos.

Puede ajustarse más adelante si deseas una puesta en marcha inicial rápida.

Tras modificar este archivo deberás reiniciar:

- `nookmesh-worker`
- `nookmesh-api`

---

## Generar credenciales y runtime

Una vez configurados los archivos base:

```bash
./auth/generate.sh
```

Este proceso genera automáticamente:

```text
config/generated/mqtt-passwords.txt
config/generated/mqtt-acl.txt
config/generated/api-tokens.txt
data/runtime/visibility.json
```

Además:

- procesa la configuración declarativa de usuarios
- genera credenciales MQTT
- construye reglas ACL
- crea tokens individuales de acceso API
- genera configuración runtime utilizada por la API

Si el broker MQTT principal aún no está desplegado, el proceso utilizará un contenedor auxiliar temporal para completar la generación.

---

## Desplegar servicios

NookMesh utiliza una arquitectura multi-compose con servicios independientes.

Orden recomendado:

### 1. Broker MQTT

```bash
docker compose -f mqtt/docker-compose.yml up -d
```

---

### 2. OwnTracks Recorder

```bash
docker compose -f recorder/docker-compose.yml up -d
```

---

### 3. Worker GeoJSON

```bash
docker compose -f worker/docker-compose.yml up -d
```

---

### 4. API

```bash
docker compose -f api/docker-compose.yml up -d
```

---

## Verificar despliegue

Comprueba contenedores activos:

```bash
docker ps
```

Deberías ver contenedores como:

- `nookmesh-mqtt`
- `nookmesh-recorder`
- `nookmesh-worker`
- `nookmesh-api`

---

## Verificar archivos generados

Comprueba:

```bash
ls config/generated
```

Salida esperada:

```text
api-tokens.txt
mqtt-acl.txt
mqtt-passwords.txt
```

Y runtime:

```bash
ls data/runtime
```

Salida esperada:

```text
visibility.json
```

---

## Seguridad recomendada

Para despliegues reales se recomienda:

- MQTT sobre TLS
- HTTPS para la API
- credenciales únicas por usuario
- no reutilizar contraseñas de ejemplo
- no exponer servicios sin autenticación

La configuración TLS se documenta en:

- [TLS](../configuration/tls.es.md)

---

## Siguiente paso

Una vez desplegada la infraestructura base:

1. Configurar OwnTracks
2. Publicar una ubicación de prueba
3. Verificar persistencia en recorder
4. Verificar generación GeoJSON
5. Configurar Guru Maps
6. Validar flujo completo extremo a extremo

Continúa con:

- [Inicio rápido](quickstart.es.md)
- [OwnTracks](../integrations/owntracks.es.md)
- [Guru Maps](../integrations/gurumaps.es.md)