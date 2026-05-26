# MQTT

🇬🇧 [English version](mqtt.md)

NookMesh utiliza MQTT como backbone de mensajería para transporte de ubicaciones en tiempo real.

La implementación actual está basada en:

```text
Mosquitto
```

MQTT permite desacoplar publicación, transporte y persistencia de ubicaciones.

---

# Rol de MQTT en NookMesh

🇬🇧 [English version](mqtt.md)

Flujo principal:

```text
OwnTracks
   ↓
MQTT (Mosquitto)
   ↓
OwnTracks Recorder
   ↓
Worker
   ↓
API GeoJSON
```

MQTT es responsable de:

- recepción de ubicaciones publicadas
- autenticación de clientes MQTT
- aplicación de ACL (control de acceso MQTT)
- distribución de mensajes al recorder

No participa directamente en:

- filtrado de visibilidad
- generación GeoJSON
- autenticación API
- render visual

---

# Broker actual

🇬🇧 [English version](mqtt.md)

NookMesh utiliza:

```text
Mosquitto
```

desplegado como componente independiente:

```text
mqtt/
```

Esto permite:

- aislamiento del broker
- configuración modular
- endurecimiento de seguridad
- mantenimiento independiente

---

# Topics utilizados

🇬🇧 [English version](mqtt.md)

OwnTracks publica usando la estructura estándar:

```text
owntracks/<usuario>/<device>
```

Ejemplos:

```text
owntracks/sergio/iphone
owntracks/sandra/redmi
owntracks/raul/car
```

Estructura:

- `<usuario>` → identidad lógica
- `<device>` → origen físico de ubicación

---

# Usuarios MQTT

🇬🇧 [English version](mqtt.md)

Cada usuario dispone de credenciales MQTT independientes definidas en:

```text
config/users.json
```

Ejemplo:

```json
"sergio": {
  "mqtt_password": "PASSWORD_SERGIO"
}
```

Durante:

```bash
./auth/generate.sh
```

estas credenciales se convierten en:

```text
config/generated/mqtt-passwords.txt
```

formato compatible con Mosquitto.

Ventajas:

- aislamiento entre usuarios
- revocación individual
- trazabilidad
- seguridad granular

---

# Usuario interno recorder

🇬🇧 [English version](mqtt.md)

NookMesh utiliza una cuenta técnica interna obligatoria:

```text
recorder
```

Definida en:

```text
config/users.json
```

Ejemplo:

```json
"recorder": {
  "enabled": true,
  "mqtt_admin": true,
  "mqtt_password": "PASSWORD_RECORDER",
  "system_user": true
}
```

Y referenciada desde:

```text
config/recorder.env
```

Esta cuenta es utilizada por:

```text
OwnTracks Recorder
```

para consumir mensajes MQTT.

No representa un usuario humano.

---

# ACL MQTT

🇬🇧 [English version](mqtt.md)

NookMesh genera automáticamente:

```text
config/generated/mqtt-acl.txt
```

mediante:

```bash
./auth/generate.sh
```

Este archivo define permisos MQTT individuales.

---

## Usuario estándar

Ejemplo:

```text
user sergio
topic read owntracks/sergio/#
topic write owntracks/sergio/#
```

Permite:

- publicar ubicaciones propias
- leer únicamente su propio namespace MQTT

---

## Usuario con `mqtt_admin`

Si:

```json
"mqtt_admin": true
```

ejemplo:

```text
user sergio
topic read owntracks/#
topic write owntracks/sergio/#
```

Esto concede:

- lectura global del árbol OwnTracks
- escritura únicamente en el namespace del propio usuario

Importante:

```text
mqtt_admin NO concede escritura global
```

---

## Usuario interno `system_user`

Caso real:

```text
user recorder
topic read owntracks/#
```

Características:

- lectura global MQTT
- sin escritura MQTT
- sin token API
- excluido del modelo de visibilidad

Uso exclusivo interno.

---

# Cómo funciona la autenticación

🇬🇧 [English version](mqtt.md)

Proceso simplificado:

### 1. OwnTracks conecta

Ejemplo:

```text
mqtt.nookmesh.example
```

usando:

- usuario MQTT
- contraseña MQTT

---

### 2. Mosquitto valida credenciales

Contra:

```text
mqtt-passwords.txt
```

---

### 3. Mosquitto aplica ACL

Contra:

```text
mqtt-acl.txt
```

---

### 4. Si está autorizado

el mensaje se distribuye.

Ejemplo:

```text
OwnTracks → Recorder
```

---

# Cambio de credenciales MQTT

🇬🇧 [English version](mqtt.md)

Para cambiar credenciales:

### 1. Editar

```text
config/users.json
```

---

### 2. Modificar

```json
"mqtt_password"
```

---

### 3. Regenerar

```bash
./auth/generate.sh
```

Esto actualizará:

```text
mqtt-passwords.txt
mqtt-acl.txt
```

y reiniciará servicios activos compatibles.

---

# Seguridad recomendada

🇬🇧 [English version](mqtt.md)

## Autenticación obligatoria

Nunca expongas un broker abierto.

Siempre utilizar:

- usuario
- contraseña

---

## TLS en producción

Muy recomendable:

- MQTT sobre TLS
- certificados válidos

Protege:

- credenciales
- ubicaciones
- tráfico MQTT

---

## Principio de mínimo privilegio

Preferir:

```text
usuario → solo su namespace
```

en lugar de:

```text
lectura global innecesaria
```

Solo usar:

```json
"mqtt_admin": true
```

cuando sea realmente necesario.

---

# Troubleshooting

🇬🇧 [English version](mqtt.md)

## OwnTracks no conecta

Revisar:

- host broker
- puerto
- DNS
- TLS
- usuario
- contraseña

---

## Authentication failed

Revisar:

```json
mqtt_password
```

y regenerar:

```bash
./auth/generate.sh
```

---

## Recorder no recibe mensajes

Revisar:

- broker activo
- credenciales recorder
- `config/recorder.env`
- usuario `recorder`
- logs del broker
- logs del recorder

---

## MQTT funciona pero no aparecen ubicaciones

MQTT puede estar funcionando correctamente y fallar etapas posteriores.

Revisar:

```text
Recorder
Worker
API
```

---

# Buenas prácticas

🇬🇧 [English version](mqtt.md)

## Una credencial por usuario

No compartir cuentas MQTT entre personas distintas.

---

## Mantener `recorder` separado

No reutilizar la cuenta técnica interna para usuarios humanos.

---

## Limitar `mqtt_admin`

Reducir superficie de exposición.

---

## Usar TLS en despliegues reales

Especialmente si el broker es accesible desde Internet.

---

# Relación con otros componentes

🇬🇧 [English version](mqtt.md)

MQTT conecta:

- OwnTracks
- Mosquitto
- OwnTracks Recorder

No decide:

- qué usuarios se ven
- qué GeoJSON se entrega
- cómo se renderiza el mapa