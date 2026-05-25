# Visibility model

NookMesh implements a relational visibility model based on shared groups and selective exclusions.

The goal is to enable real-time location sharing without exposing all information to every participant.

Visibility decisions are made entirely within your own infrastructure before any data is delivered to the client.

---

## Model philosophy

Unlike rigid systems where:

```text
everyone sees everyone
```

or:

```text
group A sees group B
```

NookMesh uses a relational model between:

- authenticated user (viewer)
- evaluated user (target)

Visibility depends on the relationship between both.

---

## Core concepts

Each user can:

- belong to one or more groups
- selectively hide from certain groups
- participate in multiple contexts simultaneously

The logic is built from:

```json
grupos
oculto_para
```

---

# Involved fields

## `grupos`

Defines the user's membership scopes.

Example:

```json
"grupos": ["familia", "amigos", "viaje1"]
```

Interpretation:

that user simultaneously belongs to:

- family
- friends
- trip1

---

## `oculto_para`

Defines visibility exceptions.

Example:

```json
"oculto_para": ["viaje1"]
```

Interpretation:

even if the user belongs to:

```text
viaje1
```

that group cannot be used to grant visibility toward that user.

Important:

this does **not globally hide** the user.

It only affects relationships built through those groups.

---

# Actual visibility logic

The current implementation conceptually applies:

```text
shared_groups = viewer_groups ∩ target_groups
visible_groups = shared_groups - target_hidden_groups
```

If:

```text
visible_groups
```

is empty:

the user will not be visible.

If it contains at least one group:

the user will be visible.

---

## Simple example

Viewer:

```json
"grupos": ["familia", "amigos"]
```

Target:

```json
"grupos": ["amigos", "trabajo"]
"oculto_para": []
```

Result:

```text
shared_groups = amigos
visible_groups = amigos
```

The target is visible.

---

## Example with exclusion

Viewer:

```json
"grupos": ["viaje1"]
```

Target:

```json
"grupos": ["familia", "viaje1"]
"oculto_para": ["viaje1"]
```

Result:

```text
shared_groups = viaje1
visible_groups = empty
```

The target will NOT be visible.

---

## Mixed example

Viewer:

```json
"grupos": ["familia", "viaje1"]
```

Target:

```json
"grupos": ["familia", "viaje1"]
"oculto_para": ["viaje1"]
```

Result:

```text
shared_groups = familia + viaje1
visible_groups = familia
```

The target will be visible.

Because at least one valid shared group still exists.

---

# Practical scenarios

## Family

Everyone visible to each other:

```json
"grupos": ["familia"]
```

---

## Temporary trip

Create:

```text
trip-alps
```

Add participants:

```json
"grupos": ["trip-alps"]
```

Everyone will see each other unless exclusions apply.

---

## Selective trip hiding

Sandra:

```json
"grupos": ["familia", "trip-alps"]
"oculto_para": ["trip-alps"]
```

Result:

- visible to family
- invisible to users who only share trip-alps

---

## Work separation

Example:

```json
"grupos": ["work"]
```

allows professional visibility to remain isolated from other contexts.

---

# Users without groups

If a user has no groups:

```json
"grupos": []
```

result:

- they will see no one
- no one will see them

The API will return:

```json
{
  "type": "FeatureCollection",
  "features": []
}
```

Groups are required to participate in the visibility model.

---

# Internal system users

Users marked as:

```json
"system_user": true
```

are excluded from the model.

Example:

```text
recorder
```

They:

- do not receive API tokens
- do not appear in `visibility.json`
- do not participate in visibility comparisons
- do not appear in public GeoJSON

---

# Internal runtime

During:

```bash
./auth/generate.sh
```

NookMesh builds:

```text
data/runtime/visibility.json
```

This file contains the operational model used by the API.

Example:

```json
{
  "sergio": {
    "grupos": ["familia", "amigos"],
    "rol": "staff"
  },
  "sandra": {
    "grupos": ["familia", "viaje1"],
    "oculto_para": ["viaje1"]
  }
}
```

---

# What does NOT affect visibility

## `rol`

Example:

```json
"rol": "staff"
```

It does not participate in visibility decisions.

Current usage includes:

- visual differentiation
- presentation logic
- metadata behavior

But it does not change which users can see each other.

---

## Visualization client

Guru Maps does not decide visibility.

It only consumes the filtered result returned by the API.

---

## Publishing client

OwnTracks does not participate in visibility rules.

It only publishes locations.

---

# Resolution flow

Simplified process:

### 1. Authentication

The API authenticates the viewer token.

---

### 2. Configuration loading

Loads:

```text
visibility.json
```

---

### 3. Viewer identification

Retrieves viewer groups.

---

### 4. Target comparison

For each available user:

- read their groups
- read their exclusions

---

### 5. Relational evaluation

Calculate:

```text
(shared groups) - (hidden groups)
```

---

### 6. Filtering

Only authorized users are delivered.

---

# Best practices

## Use clear group names

Better:

```text
family
friends
work
trip-alps
```

than:

```text
g1
tmp
misc
```

---

## Avoid unnecessary complexity

Do not create redundant groups without a real need.

---

## Design around real scenarios

Think in terms of:

- family
- trips
- friends
- events
- work

---

# Security and privacy

This model enables:

- selective sharing
- contextual privacy
- separation between scopes
- granular control

All visibility logic is resolved server-side.

The final client never receives unauthorized users.