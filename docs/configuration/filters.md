# Operational Filters

🇪🇸 [Versión en español](filters.es.md)

NookMesh allows operational behavior of the GeoJSON pipeline to be adjusted through parameters defined in:

```text
config/filtros.env
```

These parameters control how locations are processed, filtered, and presented before being delivered to clients.

They are not part of the authentication model or the user visibility model, but rather the internal behavior of processing and export operations.

---

## Purpose

Filters allow you to adjust:

- GeoJSON regeneration frequency
- export time window
- timezone for human-readable timestamps
- automatic subscription management
- maximum accepted location age
- exclusion of the authenticated user's own position
- proximity filtering
- multi-device behavior
- map visual cleanup

---

## Configuration File

Example (`config/filtros.example.env`):

```env
TIMEZONE=Europe/Madrid
EXPORT_INTERVAL_SECONDS=3
EXPORT_HOUR_START=6
EXPORT_HOUR_END=1

ENABLE_SUBSCRIPTIONS=true

MAX_EDAD_MIN=60
EXCLUDE_VIEWER_IN_OUTPUT=true

EXCLUDE_NEARBY_METROS=80
REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY=true

MERGE_CLOSEST_DEVICES=true
MERGE_MAX_METROS=100
```

---

## Applying Changes

Some parameters are only read during container startup.

After modifying:

```text
config/filtros.env
```

it may be necessary to restart the corresponding services.

### Required Restart

| Parameter | Restart Required |
|------------|------------|
| TIMEZONE | worker + api |
| EXPORT_INTERVAL_SECONDS | worker |
| EXPORT_HOUR_START | worker |
| EXPORT_HOUR_END | worker |
| MAX_EDAD_MIN | worker + api |
| EXCLUDE_VIEWER_IN_OUTPUT | api |
| EXCLUDE_NEARBY_METROS | api |
| REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY | api |
| MERGE_CLOSEST_DEVICES | api |
| MERGE_MAX_METROS | api |
| ENABLE_SUBSCRIPTIONS | subscriptions |

Examples:

```bash
docker restart nookmesh-worker
docker restart nookmesh-api
```

or:

```bash
docker restart nookmesh-subscriptions
```

---

# Available Parameters

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
- displayed local time

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

Meaning:

the GeoJSON will be rebuilt approximately every:

```text
3 seconds
```

---

### Impact

Lower values:

- faster updates
- higher CPU and disk usage

Higher values:

- lower resource consumption
- less real-time responsiveness

---

## EXPORT_HOUR_START

Start hour for automatic export.

Example:

```env
EXPORT_HOUR_START=6
```

Meaning:

export begins at:

```text
06:00
```

---

## EXPORT_HOUR_END

End hour for automatic export.

Example:

```env
EXPORT_HOUR_END=1
```

Meaning:

export stops at:

```text
01:00
```

---

### Overnight Windows

NookMesh supports windows that cross midnight.

Example:

```env
EXPORT_HOUR_START=22
EXPORT_HOUR_END=6
```

Result:

export remains active between:

```text
22:00 → 06:00
```

---

### Outside Export Window

If the system is outside the configured time window:

NookMesh intentionally clears the GeoJSON output.

Result:

```json
{
  "type": "FeatureCollection",
  "features": []
}
```

This allows map visibility to be completely disabled outside the defined schedule.

---

## ENABLE_SUBSCRIPTIONS

Enables or disables automatic subscription processing.

Example:

```env
ENABLE_SUBSCRIPTIONS=true
```

---

### true

The container:

```text
nookmesh-subscriptions
```

will periodically execute:

```text
auth/generate.sh
```

to:

- apply automatic expirations
- update user statuses
- maintain credentials
- regenerate runtime data when required

---

### false

The container remains running but performs no processing.

The following will not be applied automatically:

- expirations
- status changes
- credential updates

Changes will only take effect when manually executing:

```bash
./auth/generate.sh
```

---

### Important

After modifying this parameter you must restart:

```bash
docker restart nookmesh-subscriptions
```

---

## MAX_EDAD_MIN

Defines the maximum accepted age for a valid location.

Example:

```env
MAX_EDAD_MIN=60
```

Meaning:

only locations with age:

```text
<= 60 minutes
```

are accepted.

---

### Current Visual States

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
- delivery API
- viewer proximity logic

It is not merely a visual filter.

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

Very useful when the client already displays the local position.

Typical case:

Guru Maps.

Prevents duplicate display of your own location.

---

### false

The user will also see their own position inside the filtered GeoJSON.

---

## EXCLUDE_NEARBY_METROS

Hides users located too close to the authenticated viewer.

Example:

```env
EXCLUDE_NEARBY_METROS=80
```

Meaning:

users within:

```text
80 meters
```

may be excluded from the result.

---

### Purpose

Reduces visual clutter.

Typical scenarios:

- group rides
- stops
- meetings
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
completely empty result
```

It does not merely disable proximity filtering.

No users will be displayed.

This prevents spatial logic from using outdated reference positions.

---

### false

The system will attempt proximity filtering even with older positions.

Generally not recommended.

---

## MERGE_CLOSEST_DEVICES

Controls multi-device consolidation.

Example:

```env
MERGE_CLOSEST_DEVICES=true
```

---

### true

If multiple devices belonging to the same user are sufficiently close:

they may be merged visually.

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

Maximum distance for devices belonging to the same user to be considered mergeable.

Example:

```env
MERGE_MAX_METROS=100
```

Meaning:

if multiple devices are within:

```text
100 meters
```

they may be consolidated.

---

### Device Selection

When multiple devices can be merged:

NookMesh prioritizes:

1. most recent location
2. if timestamps are equal, best GPS accuracy

---

# Relationship With Other Components

## Visibility

These filters do NOT determine:

```text
who can see whom
```

That belongs to:

- authentication
- tokens
- groups
- visibility exclusions

---

## Worker

They directly affect:

```text
nookmesh-worker
```

which is responsible for generating:

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

## Subscription Service

They also affect:

```text
nookmesh-subscriptions
```

which is responsible for:

- automatic expiration processing
- user lifecycle management
- periodic execution of the authentication generator

---

# Practical Example

Assume:

- authenticated viewer with a recent location
- two companions within 50 meters
- multiple devices belonging to the same user

With:

```env
EXCLUDE_NEARBY_METROS=80
MERGE_CLOSEST_DEVICES=true
```

Result:

- very close users may be hidden
- redundant devices may be merged
- the map remains visually cleaner

---

# Best Practices

## Group Trips

Recommended configuration:

```env
EXCLUDE_NEARBY_METROS=80
MERGE_CLOSEST_DEVICES=true
```

---

## Detailed Monitoring

If you want to see absolutely everything:

```env
EXCLUDE_NEARBY_METROS=0
MERGE_CLOSEST_DEVICES=false
```

---

## Avoid Extreme Values

Overly aggressive filters may hide useful information.

---

# Troubleshooting

## A User Does Not Appear

Check:

```env
MAX_EDAD_MIN
EXCLUDE_NEARBY_METROS
REQUIRE_RECENT_VIEWER_POSITION_FOR_PROXIMITY
```

---

## Devices Disappear

Check:

```env
MERGE_CLOSEST_DEVICES
MERGE_MAX_METROS
```

---

## GeoJSON Is Empty At Night

Check:

```env
EXPORT_HOUR_START
EXPORT_HOUR_END
```

---

## Map Updates Too Slowly

Check:

```env
EXPORT_INTERVAL_SECONDS
```

---

## Subscriptions Are Not Updating

Verify:

```env
ENABLE_SUBSCRIPTIONS=true
```

and restart:

```bash
docker restart nookmesh-subscriptions
```

---

## I Changed Filters And Nothing Happens

Restart the corresponding container according to the modified parameter.