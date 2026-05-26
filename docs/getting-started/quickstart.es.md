# Inicio rápido

🇬🇧 [English version](quickstart.md)

Esta guía muestra el camino más rápido para validar una instalación funcional de NookMesh extremo a extremo.

Objetivo: comprobar que una ubicación enviada desde OwnTracks aparece correctamente en Guru Maps usando tu propia infraestructura.

Si aún no has preparado el entorno base, consulta primero:

- [Requisitos](requirements.es.md)
- [Instalación](installation.es.md)

---

## Qué vas a validar

Al finalizar esta guía deberías tener:

- infraestructura NookMesh operativa
- un usuario configurado
- OwnTracks publicando ubicaciones
- recorder persistiendo datos
- worker generando GeoJSON
- API protegida funcionando
- Guru Maps mostrando ubicaciones reales

---

## 1. Preparar configuración mínima

Asegúrate de haber creado:

```text
config/users.json
config/recorder.env
config/filtros.env
```

y haber ejecutado:

```bash
./auth/generate.sh
```

Si no lo has hecho, vuelve a:

- [Instalación](installation.es.md)

---

## 2. Levantar servicios

Inicia el stack completo:

```bash
docker compose -f mqtt/docker-compose.yml up -d
docker compose -f recorder/docker-compose.yml up -d
docker compose -f worker/docker-compose.yml up -d
docker compose -f api/docker-compose.yml up -d
```

Verifica:

```bash
docker ps
```

Deberías ver contenedores como:

- `nookmesh-mqtt`
- `nookmesh-recorder`
- `nookmesh-worker`
- `nookmesh-api`

---

## 3. Configurar OwnTracks

Instala OwnTracks.

Proyecto oficial:

https://owntracks.org/

Configura un usuario existente definido en:

```text
config/users.json
```

Configuración mínima recomendada:

### Mode

```text
Private MQTT
```

### Host

Tu broker MQTT:

```text
mqtt.tudominio.com
```

### Port

Según tu despliegue:

Sin TLS habitual:

```text
1883
```

Con TLS:

```text
8883
```

### Username

Ejemplo:

```text
sergio
```

### Password

La contraseña MQTT configurada para ese usuario.

### Device ID

Ejemplos:

```text
iphone
pixel
android
```

### Tracker ID

Ejemplos:

```text
SE
RA
SA
```

---

## 4. Publicar una ubicación de prueba

Desde OwnTracks, fuerza el envío manual de una ubicación.

Flujo esperado:

```text
OwnTracks
→ MQTT
→ Recorder
→ Worker
→ API
```

---

## 5. Verificar recepción

### MQTT

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

### Datos persistidos

Verifica:

```text
data/owntracks/store/
```

---

### GeoJSON generado

Verifica:

```text
data/public/nookmesh.geojson
```

---

## 6. Obtener token API

Consulta:

```text
config/generated/api-tokens.txt
```

Ejemplo:

```text
sergio:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Guarda el token del usuario configurado.

---

## 7. Verificar API directamente

Antes de usar Guru Maps:

```text
https://geojson.tudominio.com/nookmesh.geojson?token=TU_TOKEN
```

Deberías recibir un GeoJSON válido.

---

## 8. Configurar Guru Maps

Opción recomendada:

importar el overlay incluido:

```text
docs/assets/gurumaps/nookmesh_gurumaps_overlay.ms
```

y adaptar:

- endpoint GeoJSON
- token
- host

Configuración detallada:

- [Guru Maps](../integrations/gurumaps.es.md)

---

## 9. Validación final

Si todo funciona:

✅ OwnTracks publica  
✅ MQTT recibe mensajes  
✅ Recorder persiste  
✅ Worker genera GeoJSON  
✅ API responde  
✅ Guru Maps muestra ubicaciones  

---

## Siguientes pasos

Profundiza en:

- [Usuarios](../configuration/users.es.md)
- [Visibilidad](../configuration/visibility.es.md)
- [TLS](../configuration/tls.es.md)
- [OwnTracks](../integrations/owntracks.es.md)
- [Guru Maps](../integrations/gurumaps.es.md)
- [Autenticación API](../api/authentication.es.md)
