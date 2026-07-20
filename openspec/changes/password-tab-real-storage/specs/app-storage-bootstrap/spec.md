## ADDED Requirements

### Requirement: App initializes SQLite before first StorageRepositories access

The application SHALL call `AppStorage.init(appNamespace: 'barrel_lock', env: storageEnv)` during startup, after `BarrelLockCrypto.init()` completes and before any widget reads `StorageRepositories.defaults()`.

#### Scenario: Cold start succeeds

- **WHEN** the app launches via `runBarrelLockApp`
- **THEN** `AppStorage.database` returns a valid `AppDatabase` instance without throwing

#### Scenario: Access before init fails fast

- **WHEN** code accesses `AppStorage.database` before `AppStorage.init`
- **THEN** the system throws `StateError` with a message indicating init is required

### Requirement: StorageRepositories is available through Riverpod

The `barrel_lock` package SHALL expose a `storageRepositoriesProvider` that returns `StorageRepositories.defaults()` for production use.

#### Scenario: Feature reads repositories from provider

- **WHEN** a feature Model is constructed through Riverpod
- **THEN** it receives the same shared `StorageRepositories` instance backed by `AppStorage.database`

#### Scenario: Tests override with in-memory database

- **WHEN** a test calls `AppStorage.initForTesting()` and overrides `storageRepositoriesProvider` with `StorageRepositories(memoryDb)`
- **THEN** feature code reads and writes only to the in-memory database
