# Roadmap de arquitectura híbrida

🇬🇧 [English version](hybrid-location-roadmap.md)

> Roadmap — visión futura, no implementado actualmente

NookMesh nació inicialmente como una plataforma self-hosted para compartición de ubicación en tiempo real basada en **OwnTracks + MQTT + Docker + GeoJSON API**.

Sin embargo, su arquitectura modular abre la puerta a una evolución más ambiciosa:

convertirse en una plataforma de ubicación **independiente del medio de transporte o de la fuente de datos**.

---

## Visión

Actualmente, NookMesh opera principalmente con una única fuente de ubicación:

```text
OwnTracks
```

utilizando conectividad IP tradicional:

- LTE / 4G / 5G
- Wi-Fi
- redes IP equivalentes

La evolución prevista busca ampliar ese modelo hacia una arquitectura híbrida y multi-fuente.

Objetivo conceptual:

```text
múltiples fuentes
        ↓
   NookMesh backend
        ↓
GeoJSON / clientes
```

Esto permitiría que el backend no dependa exclusivamente de una única app o de conectividad móvil convencional.

---

## Qué es NookMesh hoy

Arquitectura actual:

```text
OwnTracks
   ↓
MQTT
   ↓
Recorder
   ↓
Worker
   ↓
API protegida
   ↓
Guru Maps
```

Características actuales:

- fuente principal: OwnTracks
- transporte: MQTT
- autenticación individual
- filtrado de visibilidad
- procesamiento GeoJSON
- clientes GeoJSON compatibles

Este modelo ya funciona en entornos reales.

---

## Hacia dónde evoluciona

La visión a largo plazo es desacoplar:

```text
captura de ubicación
```

de

```text
procesamiento y visualización
```

permitiendo múltiples fuentes de entrada.

Modelo conceptual futuro:

```text
Location Sources
      ↓
Ingestion Layer
      ↓
Normalization Layer
      ↓
Visibility / Filtering
      ↓
GeoJSON API
      ↓
Clients
```

Esto convertiría NookMesh en una plataforma de ubicación **transport-agnostic**.

---

## Fuentes objetivo potenciales

Ejemplos conceptuales:

- OwnTracks
- Meshtastic
- GPS trackers dedicados
- dispositivos IoT
- gateways híbridos
- bridges MQTT
- futuras fuentes compatibles

No todas están planificadas ni priorizadas actualmente.

Se muestran como posibles direcciones arquitectónicas.

---

## Caso prioritario: Meshtastic

Uno de los escenarios más interesantes es la integración con **Meshtastic**.

Proyecto oficial:

https://meshtastic.org/

Meshtastic permitiría ampliar NookMesh a entornos donde no exista conectividad móvil tradicional.

---

## Casos de uso objetivo

Ejemplos:

- rutas en moto sin cobertura
- senderismo
- expediciones
- actividades outdoor
- coordinación de grupos remotos
- eventos en zonas rurales
- despliegues resilientes
- escenarios híbridos LTE + mesh

---

## Modelo conceptual Meshtastic

Ejemplo:

```text
Meshtastic nodes
      ↓
mesh network
      ↓
gateway / bridge
      ↓
NookMesh ingestion
      ↓
GeoJSON API
      ↓
clients
```

---

## Modelo híbrido ideal

Escenario conceptual:

cuando exista conectividad IP:

```text
OwnTracks → MQTT
```

cuando no exista:

```text
Meshtastic → bridge
```

ambos convergiendo en:

```text
NookMesh backend
```

Ejemplo:

```text
OwnTracks (LTE)
            \
             NookMesh
            /
Meshtastic (mesh)
```

---

## Qué aportaría esta evolución

Una arquitectura híbrida permitiría:

- operación sin cobertura móvil
- redundancia de transporte
- resiliencia operativa
- independencia de un único proveedor o protocolo
- continuidad de tracking
- escenarios distribuidos
- integración de nuevas fuentes

---

## Filosofía

Esta evolución encaja con los principios fundacionales de NookMesh:

- privacidad
- control de infraestructura
- autoalojamiento
- interoperabilidad
- independencia cloud
- modularidad

La idea no es depender de una única app, sino construir una capa backend flexible y soberana.

---

## Por qué la arquitectura actual lo facilita

Aunque hoy NookMesh está centrado en OwnTracks, su diseño modular ya separa claramente:

- autenticación
- transporte
- persistencia
- transformación
- filtrado
- visualización

Esto reduce el acoplamiento entre fuente y cliente.

En otras palabras:

el backend no está completamente ligado a una única app de captura.

---

## Retos técnicos

Una evolución real requeriría resolver múltiples aspectos.

---

### Identidad

Mapear:

```text
node IDs
device IDs
tracker IDs
```

hacia:

```text
usuarios lógicos NookMesh
```

Ejemplo:

```text
Meshtastic node → sergio
```

---

### Normalización de datos

Fuentes distintas publican estructuras diferentes.

Ejemplos:

- OwnTracks
- Meshtastic
- trackers GPS
- dispositivos IoT

NookMesh necesitaría traducir todo a un modelo interno coherente.

---

### Transporte

Definir cómo entran nuevos eventos al backend.

Posibles modelos:

- MQTT bridge
- API ingestion endpoint
- conversor dedicado
- servicio intermedio
- parser especializado

---

### Deduplicación

Escenario híbrido:

el mismo usuario podría aparecer simultáneamente desde:

- OwnTracks
- Meshtastic
- tracker dedicado

Sería necesario resolver:

- cuál es la fuente preferida
- cómo fusionar ubicaciones
- cómo evitar duplicados

---

### Timestamps y stale data

Las redes mesh introducen complejidades adicionales:

- retransmisiones
- forwarding
- latencia
- paquetes retrasados
- información obsoleta

El backend debería distinguir datos válidos de stale data.

---

### Seguridad

Diseñar:

- autenticación entre bridge y backend
- validación de origen
- aislamiento de gateways
- modelo de confianza
- control de ingestión

---

### Observabilidad

Con múltiples fuentes, el debugging se vuelve más complejo.

Ejemplos:

- ¿falló OwnTracks?
- ¿falló el bridge mesh?
- ¿falló la normalización?
- ¿falló la API?

---

## Experiencia cliente ideal

Desde el punto de vista del usuario final, idealmente no habría diferencias.

Guru Maps seguiría consumiendo:

```text
GeoJSON
```

sin necesidad de saber si el origen real es:

- móvil LTE
- red mesh
- tracker externo

La complejidad quedaría encapsulada en backend.

---

## Posibles componentes futuros

Ejemplos conceptuales:

```text
mesh-bridge
hybrid-router
ingestion-service
source-normalizer
tracker-adapter
```

No forman parte del proyecto actual.

---

## Estado actual

Actualmente:

✅ arquitectura modular preparada conceptualmente  
✅ backend desacoplado parcialmente  
✅ pipeline GeoJSON funcional  
❌ multi-source ingestion no implementado  
❌ Meshtastic no implementado  
❌ deduplicación multi-fuente no implementada  

---

## Objetivo estratégico

La visión a largo plazo es que NookMesh evolucione desde:

```text
plataforma OwnTracks + MQTT
```

hacia:

```text
plataforma self-hosted de ubicación multi-fuente
```

capaz de abstraer:

- transporte
- origen de datos
- protocolo de captura

manteniendo una experiencia consistente para clientes de visualización.

---

## Importante

A día de hoy, la única fuente de ubicación oficialmente soportada y documentada es:

```text
OwnTracks
```

Todo lo descrito en este documento representa visión estratégica y roadmap arquitectónico futuro.