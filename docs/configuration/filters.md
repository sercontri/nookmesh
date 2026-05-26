# Operational Filters

🇪🇸 [Versión en español](filters.es.md)

NookMesh allows adjustment of the operational behavior of the GeoJSON pipeline through parameters defined in:

```text
config/filtros.env
```

These parameters control how locations are processed, filtered, and presented before being delivered to clients.

They are not part of the authentication model or user visibility model, but rather the internal processing and export behavior.

---

## Purpose

Filters allow you to control:

- GeoJSON regeneration frequency
- export time window
- timezone for human-readable timestamps
- maximum accepted location age
- exclusion of the authenticated user's own position
- proximity filtering
- multi-device behavior
- visual map cleanup

---

## Configuration file

Real example (`config/filtros.example.env`):

```env
TIMEZONE=Europe/Madrid
EXPORT_INTERVAL_SECONDS=3
EXPORT_HOUR_START=6
EXPORT_HOUR_END=1
MAX_EDAD_MIN=60
EXCLUDE_VIEWER_IN_OUTPUT=true
EXCLUDE_NEARBY_METROS=80
REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY=true
MERGE_CLOSEST_DEVICES=true
MERGE_MAX_METROS=100
```

---

## Applying changes

After modifying this file, restart the services that consume these variables:

```bash
docker restart nookmesh-worker
docker restart nookmesh-api
```

---

# Available parameters

🇪🇸 [Versión en español](filters.es.md)

## TIMEZONE

Timezone used for human-readable timestamps included in GeoJSON descriptions.

Example:

```env
TIMEZONE=Europe/Madrid
```

Important:

this **does not affect internal age calculations**, which are always performed in UTC.

It only affects:

- descriptive text
- time shown to the user

---

## EXPORT_INTERVAL_SECONDS

Frequency at which the worker regenerates:

```text
data/public/nookmesh.geojson
```

Example:

```env
EXPORT_INTERVAL_SECONDS=3
```

Interpretation:

GeoJSON will be rebuilt approximately every:

```text
3 seconds
```

---

### Impact

Lower values:

- faster updates
- higher CPU / disk usage

Higher values:

- lower resource usage
- reduced real-time responsiveness

---

## EXPORT_HOUR_START

Automatic export start time.

Example:

```env
EXPORT_HOUR_START=6
```

Interpretation:

start exporting at:

```text
06:00
```

---

## EXPORT_HOUR_END

Automatic export stop time.

Example:

```env
EXPORT_HOUR_END=1
```

Interpretation:

stop exporting at:

```text
01:00
```

---

### Overnight windows

NookMesh supports windows that cross midnight.

Example:

```env
EXPORT_HOUR_START=22
EXPORT_HOUR_END=6
```

Result:

export active between:

```text
22:00 → 06:00
```

---

### Outside export window

If the system is outside the configured time window:

NookMesh deliberately clears the GeoJSON.

Result:

```json
{
  "type": "FeatureCollection",
  "features": []
}
```

This allows visualization to be completely disabled outside the defined schedule.

---

## MAX_EDAD_MIN

Defines the maximum accepted age for a location to be considered valid.

Example:

```env
MAX_EDAD_MIN=60
```

Interpretation:

only locations with age:

```text
<= 60 minutes
```

are accepted.

---

### Current visual states

Current logic uses:

```text
< 5 min      → green
5–29 min     → orange
30–60 min    → red
> MAX_EDAD   → hidden
```

---

### Important

This value affects:

- GeoJSON export
- API delivery
- viewer proximity logic

It is not just a visual filter.

---

## EXCLUDE_VIEWER_IN_OUTPUT

Controls whether the authenticated user should see their own position.

Example:

```env
EXCLUDE_VIEWER_IN_OUTPUT=true
```

---

### true

The user's own position is excluded.

Very useful when the client already shows the local device position.

Typical case:

Guru Maps.

Avoids duplicating your own location on screen.

---

### false

The user will also see their own position inside the filtered GeoJSON.

---

## EXCLUDE_NEARBY_METROS

Hides users that are too close to the authenticated viewer.

Example:

```env
EXCLUDE_NEARBY_METROS=80
```

Interpretation:

users within:

```text
80 meters
```

may be excluded from the result.

---

### Purpose

Reduce visual clutter.

Typical scenarios:

- group rides
- stops
- meetups
- convoys

---

## REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY

Controls whether proximity filtering requires a recent viewer position.

Example:

```env
REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY=true
```

---

### true

If the viewer does not have a recent position:

```text
age > MAX_EDAD_MIN
```

NookMesh returns:

```text
a completely empty result
```

It does not merely disable proximity filtering.

No users will be shown.

This prevents spatial logic from being applied using stale reference data.

---

### false

The system will attempt proximity filtering even with older viewer positions.

Normally not recommended.

---

## MERGE_CLOSEST_DEVICES

Controls multi-device consolidation.

Example:

```env
MERGE_CLOSEST_DEVICES=true
```

---

### true

If multiple devices from the same user are close enough:

they may be visually merged.

---

### false

Each published device may appear separately.

Example:

```text
owntracks/sergio/iphone
owntracks/sergio/ipad
owntracks/sergio/tracker
```

---

## MERGE_MAX_METROS

Maximum distance for considering devices from the same user mergeable.

Example:

```env
MERGE_MAX_METROS=100
```

Interpretation:

if multiple devices are within:

```text
100 meters
```

they may be consolidated.

---

### Device selection

If multiple devices are mergeable:

NookMesh prioritizes:

1. most recent location
2. if timestamps match, best GPS accuracy

---

# Relationship with other components

🇪🇸 [Versión en español](filters.es.md)

## Visibility

These filters do NOT determine:

```text
who can see whom
```

That belongs to:

- authentication
- tokens
- groups
- hidden rules

---

## Worker

They directly affect:

```text
nookmesh-worker
```

Responsible for generating:

```text
nookmesh.geojson
```

---

## API

The API also applies additional logic:

- authentication
- visibility filtering
- viewer exclusion
- age filtering
- proximity filtering
- multi-device merge
- final GeoJSON rendering

---

# Practical example

🇪🇸 [Versión en español](filters.es.md)

Suppose:

- authenticated viewer with a recent position
- two companions within 50 meters
- multiple devices for the same user

With:

```env
EXCLUDE_NEARBY_METROS=80
MERGE_CLOSEST_DEVICES=true
```

Result:

- very close users may be hidden
- redundant devices may be merged
- the map becomes visually cleaner

---

# Best practices

🇪🇸 [Versión en español](filters.es.md)

## Group rides

Recommended configuration:

```env
EXCLUDE_NEARBY_METROS=80
MERGE_CLOSEST_DEVICES=true
```

---

## Detailed monitoring

If you want to see absolutely everything:

```env
EXCLUDE_NEARBY_METROS=0
MERGE_CLOSEST_DEVICES=false
```

---

## Avoid extreme values

Overly aggressive filters may hide useful information.

---

# Troubleshooting

🇪🇸 [Versión en español](filters.es.md)

## A user does not appear

Check:

```env
MAX_EDAD_MIN
EXCLUDE_NEARBY_METROS
REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY
```

---

## Devices disappear

Check:

```env
MERGE_CLOSEST_DEVICES
MERGE_MAX_METROS
```

---

## GeoJSON is empty at night

Check:

```env
EXPORT_HOUR_START
EXPORT_HOUR_END
```

---

## The map does not update quickly

Check:

```env
EXPORT_INTERVAL_SECONDS
```

---

## I changed filters and nothing happens

Restart:

```bash
docker restart nookmesh-worker
docker restart nookmesh-api
```