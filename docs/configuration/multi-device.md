# Multi-device

🇪🇸 [Versión en español](multi-device.es.md)

NookMesh allows a single logical identity to use multiple physical devices simultaneously.

This enables scenarios where a user:

- changes devices
- uses multiple devices at the same time
- keeps secondary devices active
- publishes location from different physical sources

The architecture clearly separates:

```text
logical identity ≠ physical device
```

---

# Core concept

🇪🇸 [Versión en español](multi-device.es.md)

In NookMesh:

## User

Represents a logical identity.

Examples:

```text
sergio
sandra
raul
```

The user is the primary control unit for:

- MQTT authentication
- API authentication
- groups
- visibility
- roles
- permissions

Defined in:

```text
config/users.json
```

---

## Device

Represents a physical location source.

Examples:

```text
iphone
pixel
ipad
tracker
tablet
backup
```

A device has no standalone identity within NookMesh.

It belongs to an existing user.

---

# Relationship with OwnTracks

🇪🇸 [Versión en español](multi-device.es.md)

OwnTracks publishes using the MQTT structure:

```text
owntracks/<user>/<device>
```

Example:

```text
owntracks/sergio/iphone
owntracks/sergio/ipad
owntracks/sergio/tracker
```

Here:

- `sergio` = logical identity
- `iphone` = physical device

---

# Internal persistence

🇪🇸 [Versión en español](multi-device.es.md)

OwnTracks Recorder stores each device independently.

Real example:

```text
data/owntracks/store/last/sergio/iphone/sergio-iphone.json
```

Conceptual structure:

```text
data/owntracks/store/last/
└── sergio/
    ├── iphone/
    │   └── sergio-iphone.json
    ├── ipad/
    │   └── sergio-ipad.json
    └── tracker/
        └── sergio-tracker.json
```

Each device maintains its own latest persisted location.

---

# How NookMesh processes devices

🇪🇸 [Versión en español](multi-device.es.md)

The exporter scans all discovered devices.

Conceptually:

```text
user
  → devices
      → individual JSON files
```

Each valid JSON initially generates an independent feature.

This means multiple devices belonging to the same user are processed individually.

---

# Important requirement

🇪🇸 [Versión en español](multi-device.es.md)

For multiple devices to belong to the same logical identity:

they must share the same MQTT user.

Correct:

```text
owntracks/sergio/iphone
owntracks/sergio/ipad
```

Incorrect for the same identity:

```text
owntracks/sergio/iphone
owntracks/sergio2/ipad
```

In that case, NookMesh treats them as different users.

---

# User must exist in NookMesh

🇪🇸 [Versión en español](multi-device.es.md)

If a device publishes using a user not defined in:

```text
config/users.json
```

it will not appear in NookMesh.

Reason:

only users present in:

```text
data/runtime/visibility.json
```

are exported.

This prevents accidental exposure of unknown users.

---

# Device merging

🇪🇸 [Versión en español](multi-device.es.md)

NookMesh can consolidate nearby devices belonging to the same user.

Configuration:

```env
MERGE_CLOSEST_DEVICES=true
MERGE_MAX_METROS=100
```

---

## What merging does

If multiple devices belonging to the same user are within the configured radius:

```text
MERGE_MAX_METROS
```

they are consolidated into a single logical representation.

Important:

this only happens between devices belonging to the same user.

Never between different users.

---

## Selection criteria

If multiple devices compete within the merge radius:

NookMesh keeps:

### 1. The most recent

Comparing:

```text
tst
```

---

### 2. If tied, the most accurate

Comparing:

```text
acc
```

(lower value = better GPS accuracy)

---

## Example

Devices:

```text
sergio/iphone
sergio/ipad
```

Situation:

- 35 meters apart
- `MERGE_MAX_METROS=100`

Result:

a single representation.

If:

- iphone has the most recent timestamp

then iphone is kept.

If:

- both have the same timestamp
- ipad has better GPS accuracy

then ipad is kept.

---

# If merging is disabled

🇪🇸 [Versión en español](multi-device.es.md)

With:

```env
MERGE_CLOSEST_DEVICES=false
```

each device is processed independently.

This may produce multiple representations for the same user.

Example:

```text
sergio/iphone
sergio/ipad
sergio/tracker
```

---

# Visual representation

🇪🇸 [Versión en español](multi-device.es.md)

The API generates visual output from each final feature.

Each visible location produces:

- one icon
- one label

Conceptually:

```text
visible feature
   → icon
   → label
```

This is why a single visible user may internally become multiple rendered GeoJSON entities.

---

# Use cases

🇪🇸 [Versión en español](multi-device.es.md)

## Device replacement

Before:

```text
owntracks/sergio/iphone13
```

After:

```text
owntracks/sergio/iphone16
```

No need to change:

- permissions
- groups
- tokens
- visibility

Only the device ID changes.

---

## Multiple simultaneous devices

Example:

```text
owntracks/sergio/iphone
owntracks/sergio/ipad
owntracks/sergio/tracker
```

Useful for:

- primary phone
- tablet
- dedicated tracker
- backup device

---

## Testing

Example:

```text
owntracks/sergio/test-device
```

Allows behavior validation without creating new users.

---

# Best practices

🇪🇸 [Versión en español](multi-device.es.md)

## Keep identity stable

Better:

```text
sergio
```

even if hardware changes.

Not:

```text
sergio
sergio2
sergio-test
```

if they represent the same person.

---

## Name devices clearly

Better:

```text
iphone
ipad
tracker
backup
```

than:

```text
dev1
tmp
abc
```

---

## Use merging according to the scenario

Enabled:

better visual experience for multiple nearby devices.

Disabled:

useful for debugging or explicit multi-device tracking.

---

# Security

🇪🇸 [Versión en español](multi-device.es.md)

MQTT authentication applies to the logical user.

There is no independent authentication per device.

This means all devices publishing as:

```text
sergio
```

share:

- the same MQTT user
- the same MQTT password

---

# Future

🇪🇸 [Versión en español](multi-device.es.md)

This design makes future integrations with multiple physical sources easier.

Conceptual example:

```text
sergio = logical identity
iphone = source A
tracker = source B
mesh node = source C
```

The architecture already cleanly separates identity from physical source.