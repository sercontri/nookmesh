# Autenticación

NookMesh protege el acceso a datos de ubicación mediante autenticación individual y validación en backend.

El objetivo es evitar exposición accidental o acceso no autorizado a ubicaciones sensibles.

A diferencia de modelos donde el cliente decide qué mostrar, en NookMesh la API controla completamente qué datos puede recibir cada consumidor.

---

## Objetivo

La autenticación protege:

- ubicaciones
- metadatos asociados
- acceso a endpoints API
- aislamiento entre usuarios
- aplicación segura de reglas de visibilidad

Permite:

- control granular
- revocación selectiva
- privacidad real
- separación entre consumidores

---

## Modelo actual

La API utiliza autenticación basada en token individual.

Ejemplo:

```text
https://geojson.tudominio.com/nookmesh.geojson?token=TOKEN
```

Cada usuario no marcado como:

```json
"system_user": true
```

dispone de su propio token de acceso.

---

## Tokens API

Los tokens se generan automáticamente mediante:

```bash
./auth/generate.sh
```

y se almacenan en:

```text
config/generated/api-tokens.txt
```

Formato:

```text
usuario:token
```

Ejemplo:

```text
sergio:0123456789abcdef...
```

---

## Generación y persistencia

Comportamiento actual:

- si un usuario nuevo aparece en `config/users.json`, recibe automáticamente un token
- si el usuario ya existe, su token se conserva
- si se marca `regen_token: true`, se genera uno nuevo
- si el usuario se elimina de `users.json`, su token desaparece

Esto evita romper clientes ya configurados innecesariamente.

---

## Expiración de tokens

Actualmente:

```text
los tokens no expiran automáticamente
```

Permanecen válidos hasta:

- regeneración manual
- eliminación del usuario
- recreación explícita

---

## Flujo de autenticación

Proceso real simplificado:

### 1

El cliente solicita un endpoint protegido.

Ejemplo:

```text
/nookmesh.geojson?token=TOKEN
```

---

### 2

La API valida el token recibido.

---

### 3

Si el token es válido:

- identifica al usuario asociado
- carga su configuración de visibilidad
- aplica reglas de acceso
- filtra el GeoJSON solicitado

---

### 4

Si la validación falla:

acceso denegado.

---

## Autenticación no implica acceso total

Autenticarse correctamente no significa ver todos los datos.

Después de validar identidad, NookMesh sigue aplicando:

- grupos compartidos
- exclusiones `oculto_para`
- filtros operativos
- restricciones contextuales

Ejemplo:

un usuario autenticado correctamente puede seguir sin ver determinadas ubicaciones.

---

## Seguridad

La autenticación se evalúa completamente en backend.

Nunca se delega al cliente.

Esto evita:

- filtrado manipulable en cliente
- exposición accidental
- bypass de reglas de visibilidad

El cliente solo recibe el resultado autorizado final.

---

## Revocación de tokens

Si una credencial se compromete, marca el usuario en:

```json
"regen_token": true
```

y ejecuta:

```bash
./auth/generate.sh
```

Esto:

- genera un nuevo token
- invalida inmediatamente el anterior
- actualiza credenciales operativas
- reinicia servicios compatibles si están activos

Después, el sistema restablece automáticamente:

```json
"regen_token": false
```

---

## HTTPS

Muy importante.

Como el token viaja actualmente en la URL:

```text
?token=TOKEN
```

debe utilizarse siempre:

```text
HTTPS
```

Sin cifrado existiría riesgo de exposición de credenciales.

---

## Consideración sobre query strings

El uso de tokens en query parameters se mantiene actualmente por compatibilidad con clientes como:

```text
Guru Maps
```

pero tiene implicaciones de seguridad.

Los tokens pueden aparecer en:

- logs HTTP
- reverse proxies
- historiales
- herramientas de monitorización
- debugging traces

Por ello:

- usar siempre HTTPS
- limitar exposición de logs
- proteger infraestructura intermedia

---

## Buenas prácticas

### No compartir tokens

Cada token identifica un usuario concreto.

---

### Rotar tokens ante sospecha

Si un token ha podido filtrarse:

regenerarlo inmediatamente.

---

### Aplicar mínimo acceso

No conceder acceso innecesario.

---

### Proteger infraestructura intermedia

Especialmente:

- reverse proxies
- logs
- observabilidad
- debugging

---

## Usuarios sin token

Los usuarios marcados como:

```json
"system_user": true
```

no reciben token API.

Ejemplo típico:

```text
recorder
```

Estos usuarios existen para infraestructura interna.

No para consumo visual.

---

## Recursos protegidos

Este mismo modelo puede utilizarse para proteger otros recursos servidos por la API.

Ejemplos:

- GeoJSON
- assets visuales
- estilos MapCSS
- endpoints auxiliares

---

## Limitaciones actuales

Actualmente no existe:

- autenticación por headers HTTP
- bearer tokens
- expiración automática
- refresh tokens
- integración SSO

El modelo actual prioriza simplicidad y compatibilidad con clientes existentes.

---

## Posibles evoluciones futuras

Modelos potenciales:

- Authorization headers
- bearer tokens
- signed requests
- auth proxy
- SSO
- short-lived credentials

---

## Relación con visibilidad

Autenticación responde:

```text
¿quién eres?
```

Visibilidad responde:

```text
¿qué puedes ver?
```

Son capas independientes y complementarias.

---

## Relación con Guru Maps

Guru Maps solo consume endpoints autenticados.

No participa en:

- autenticación
- autorización
- decisiones internas de visibilidad