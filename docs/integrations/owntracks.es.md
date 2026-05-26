# Integración con OwnTracks

🇬🇧 [English version](owntracks.md)

Actualmente, NookMesh utiliza **OwnTracks** como cliente principal para captura y publicación de ubicaciones.

OwnTracks es un cliente maduro, orientado a privacidad y especialmente adecuado para arquitecturas self-hosted basadas en MQTT.

Proyecto oficial:

https://owntracks.org/

---

## Rol dentro de NookMesh

OwnTracks es el origen principal de los datos de ubicación.

Responsabilidades:

- capturar ubicación GPS
- detectar cambios de movimiento según plataforma
- recopilar metadatos del dispositivo
- publicar eventos de ubicación mediante MQTT

Flujo completo:

```text
OwnTracks
   ↓
Broker MQTT
   ↓
Recorder
   ↓
Worker
   ↓
API GeoJSON
   ↓
Guru Maps
```

OwnTracks no interactúa directamente con la API ni con Guru Maps.

Solo publica ubicaciones al broker MQTT.

---

## Plataformas compatibles

Actualmente:

- iPhone / iPad (iOS)
- Android

Esto permite entornos mixtos con múltiples usuarios y dispositivos distintos.

---

## Datos utilizados por NookMesh

Dependiendo del dispositivo y configuración, OwnTracks publica múltiples campos.

NookMesh utiliza principalmente:

- latitud (`lat`)
- longitud (`lon`)
- precisión (`acc`)
- altitud (`alt`)
- velocidad (`vel`)
- rumbo (`cog`)
- batería (`batt`)
- tipo de conexión (`conn`)
- timestamp (`tst`)
- identificador de dispositivo (`device`)
- tracker ID (`tid`)
- usuario (`username`)

Ejemplo:

```json
{
  "_type": "location",
  "lat": 38.561445,
  "lon": -0.212222,
  "acc": 13,
  "alt": 683,
  "vel": 10,
  "cog": 221,
  "batt": 80,
  "conn": "m",
  "tid": "SA"
}
```

---

## Comunicación con NookMesh

NookMesh utiliza OwnTracks en:

```text
Private MQTT mode
```

Las ubicaciones se publican mediante MQTT usando el formato estándar:

```text
owntracks/<usuario>/<device>
```

Ejemplo:

```text
owntracks/sandra/iphone
```

NookMesh Recorder consume estos mensajes automáticamente desde el broker MQTT.

---

## Autenticación

Cada usuario utiliza credenciales MQTT independientes.

Definidas en:

```text
config/users.json
```

Ejemplo:

```json
"sergio": {
  "mqtt_password": "PASSWORD_SERGIO"
}
```

Tras ejecutar:

```bash
./auth/generate.sh
```

esas credenciales quedan operativas en Mosquitto.

Ventajas:

- aislamiento entre usuarios
- revocación individual
- control granular
- trazabilidad

---

# Configuración básica

## 1. Instalar OwnTracks

Descarga la app oficial para tu plataforma.

---

## 2. Seleccionar modo

Configurar:

```text
Private MQTT
```

---

## 3. Configurar broker MQTT

### Host

Ejemplo:

```text
mqtt.tudominio.com
```

Debe apuntar al broker MQTT de NookMesh.

---

### Puerto

Producción con TLS:

```text
8883
```

Entornos de laboratorio sin TLS:

```text
1883
```

---

### Usuario

Debe existir en:

```text
config/users.json
```

Ejemplo:

```text
sergio
```

---

### Contraseña

La definida en:

```json
mqtt_password
```

para ese usuario.

---

## 4. TLS

Para despliegues reales:

activar TLS.

En entornos con certificados públicos:

normalmente no requiere configuración adicional.

Con certificados self-signed:

puede requerir configuración manual según plataforma.

Consulta:

[TLS](../configuration/tls.es.md)

---

## 5. Device ID

Identifica el dispositivo físico.

Ejemplos:

```text
iphone
pixel
ipad
tracker
car
```

Esto genera topics como:

```text
owntracks/sergio/iphone
```

---

### Importante

Si utilizas varios dispositivos bajo el mismo usuario:

cada Device ID debe ser único.

Correcto:

```text
iphone
ipad
tracker
```

Incorrecto:

```text
iphone
iphone
```

Duplicar Device ID hará que ambos dispositivos publiquen sobre el mismo topic lógico.

---

## 6. Tracker ID (`tid`)

Identificador corto usado dentro de los mensajes OwnTracks.

Ejemplos:

```text
SE
SA
RA
```

En NookMesh se utiliza para representación visual en mapas.

Ejemplo:

```text
SE
```

puede mostrarse como etiqueta visual del usuario.

---

# Device ID vs Tracker ID

Son conceptos distintos.

## Device ID

Forma parte del topic MQTT.

Ejemplo:

```text
owntracks/sergio/iphone
```

Representa:

dispositivo físico.

---

## Tracker ID (`tid`)

Forma parte del payload del mensaje.

Ejemplo:

```json
"tid": "SE"
```

Representa:

identificador corto visual.

---

# Multi-dispositivo

NookMesh permite varios dispositivos por usuario.

Ejemplo:

```text
owntracks/sergio/iphone
owntracks/sergio/ipad
owntracks/sergio/tracker
```

Casos típicos:

- móvil principal
- tablet
- tracker dedicado
- dispositivo temporal

El comportamiento visual dependerá de:

```text
config/filtros.env
```

especialmente:

```env
MERGE_CLOSEST_DEVICES=true
MERGE_MAX_METROS=100
```

---

# Comportamiento de publicación

OwnTracks puede optimizar publicación según:

- configuración interna
- movimiento detectado
- actividad
- restricciones del sistema operativo
- ahorro energético
- conectividad

Esto afecta directamente a la experiencia en NookMesh.

---

# Consideraciones por plataforma

## iOS

Puede verse afectado por:

- restricciones de background
- permisos de localización
- políticas energéticas
- suspensión automática de apps

---

## Android

Generalmente más flexible, pero depende del fabricante.

Problemas frecuentes:

- optimización agresiva de batería
- restricciones background
- limitaciones del fabricante

Especialmente en:

- Xiaomi
- Oppo
- Huawei
- Realme
- Samsung (según configuración)

---

# Troubleshooting

## No conecta al broker

Revisar:

- host MQTT
- puerto
- DNS
- firewall
- TLS
- usuario
- contraseña

---

## Auth failed

Verificar:

```text
config/users.json
```

y regenerar:

```bash
./auth/generate.sh
```

Si modificaste credenciales.

---

## MQTT conecta pero no aparece en el mapa

Revisar por capas.

### Broker

```bash
docker logs nookmesh-mqtt
```

---

### Recorder

```bash
docker logs nookmesh-recorder
```

---

### Worker

```bash
docker logs nookmesh-worker
```

---

### API

```bash
docker logs nookmesh-api
```

---

También comprobar:

```text
data/owntracks/store/last
```

Si no aparece el dispositivo ahí:

el problema está antes del worker.

---

## Actualización irregular

Posibles causas:

- ahorro energético
- permisos de localización
- restricciones background
- conectividad
- configuración OwnTracks
- suspensión del sistema operativo

---

## No aparecen otros usuarios

Revisar:

- visibilidad (`grupos`)
- `oculto_para`
- antigüedad (`MAX_EDAD_MIN`)
- filtros de proximidad
- token API correcto

---

# Filosofía

OwnTracks encaja especialmente bien con NookMesh porque comparte principios similares:

- privacidad
- control del usuario
- autoalojamiento
- infraestructura propia
- ausencia de dependencia cloud obligatoria

---

# Limitación actual

Actualmente NookMesh está orientado principalmente a OwnTracks como fuente de ubicación.

La arquitectura, sin embargo, permite futuras fuentes alternativas.

---

# Futuro

Posibles integraciones futuras:

- clientes GPS alternativos
- trackers dedicados
- fuentes IoT
- Meshtastic
- nodos híbridos LTE + mesh
