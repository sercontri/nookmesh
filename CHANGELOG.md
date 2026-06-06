# Changelog

🇪🇸 [Versión en español](CHANGELOG.es.md)

All notable changes to NookMesh will be documented in this file.

This project follows Semantic Versioning (SemVer).

---

## [0.2.1] - 2026-06-06

### Changed

- Improved the runtime environment of the `nookmesh-subscriptions` container.
- Added `Europe/Madrid` timezone support for scheduled tasks.
- Improved subscriptions service logging for diagnostics and observability.
- Improved service restart logging in `auth/generate.sh`.
- Improved scheduled task execution logging.

### Fixed

- Fixed automatic execution of `auth/generate.sh` from the subscriptions service.
- Added required runtime dependencies (`docker-cli`, `jq`, and `openssl`) to the subscriptions container.
- Added host Docker socket access to allow service management from inside the container.
- Fixed timezone configuration in the subscriptions container.
- Fixed automatic regeneration of runtime files associated with user expirations.
- Fixed automatic updates of `visibility.json`, MQTT ACLs, and derived credentials during scheduled executions.

---

## [0.2.0] - 2026-05-29

### Added

- User lifecycle management.
- User states: `active`, `disabled`, and `expired`.
- Expiration dates through `expires_on`.
- Credential retention policies through `retain_credentials`.
- Automatic expiration processing.
- Scheduled subscriptions service (`nookmesh-subscriptions`).
- Runtime configuration option `ENABLE_SUBSCRIPTIONS`.
- Complete subscriptions system documentation.

### Changed

- Refactored `auth/generate.sh`.
- Visibility runtime generation now respects user status.
- MQTT password generation now supports lifecycle policies.
- MQTT ACL generation now supports lifecycle policies.
- API token generation now supports lifecycle policies.
- Updated user examples to reflect the new lifecycle management model.

### Documentation

- Updated README.
- Updated technical documentation index.
- Updated Users documentation.
- Updated Authentication Generator documentation.
- Updated Operational Filters documentation.
- Added Subscriptions documentation.

---

## [0.1.0] - First Public Release

### Added

- OwnTracks integration.
- MQTT transport layer using Mosquitto.
- OwnTracks Recorder integration.
- GeoJSON API.
- Guru Maps integration.
- Multi-user support.
- Multi-device support.
- Group-based visibility model.
- MQTT authentication and automatic ACL generation.
- API token authentication.
- Docker-based deployment architecture.
- Support for secure TLS deployments.
- Initial technical documentation.