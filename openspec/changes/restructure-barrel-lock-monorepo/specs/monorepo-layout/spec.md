## ADDED Requirements

### Requirement: Single-app apps directory layout

The repository SHALL organize all BarrelLock application packages directly under `apps/` without an intermediate product folder (e.g. no `apps/BarrelLock/`).

#### Scenario: Platform apps live at apps root

- **WHEN** a developer lists the `apps/` directory
- **THEN** platform packages exist as `apps/android`, `apps/ios`, `apps/macos`, `apps/windows`, `apps/linux`, and `apps/web`

#### Scenario: Shared app packages live at apps root

- **WHEN** a developer lists the `apps/` directory
- **THEN** shared packages exist as `apps/barrel_lock` and `apps/barrel_lock_ui`

### Requirement: Workspace root naming

The repository root directory SHALL be named `barrel_lock`. The root `pubspec.yaml` `name` field SHALL be `barrel_lock_workspace` and describe the BarrelLock monorepo.

#### Scenario: Root pubspec identity

- **WHEN** reading the root `pubspec.yaml`
- **THEN** `name` is `barrel_lock_workspace` and `description` references BarrelLock (not Flutter Bazaar)

### Requirement: Workspace member registration

The root `pubspec.yaml` `workspace:` list SHALL register all app and package paths using the flattened layout (e.g. `apps/android`, `apps/barrel_lock`, `packages/core`).

#### Scenario: Pub get resolves all members

- **WHEN** running `dart pub get` at the repository root
- **THEN** all workspace members resolve without missing path errors

### Requirement: Dart package names unchanged

Physical directory moves SHALL NOT change existing Dart package `name` fields (e.g. `barrel_lock_android`, `barrel_lock`, `core`). Dart `import` statements using `package:` URIs SHALL remain valid without modification.

#### Scenario: Imports remain stable

- **WHEN** application code imports `package:barrel_lock/barrel_lock.dart`
- **THEN** the import resolves successfully after the restructure without source edits

### Requirement: Melos quality gate passes

After restructure, the aggregate quality gate SHALL pass unchanged in scope: `melos run ci` (format:check → analyze → test).

#### Scenario: CI green after migration

- **WHEN** running `melos run ci` at the repository root after migration
- **THEN** the command exits with code 0

### Requirement: Documentation reflects single-app layout

Project documentation and Cursor rules SHALL describe the BarrelLock single-app monorepo layout and SHALL NOT refer to multi-product or `apps/BarrelLock/` paths.

#### Scenario: README structure section

- **WHEN** reading the root README project structure section
- **THEN** paths use `apps/android`, `apps/barrel_lock`, and `packages/` without `apps/BarrelLock/`

### Requirement: Native identifiers preserved

The restructure SHALL NOT change published Android `applicationId` or iOS `PRODUCT_BUNDLE_IDENTIFIER` values.

#### Scenario: Android ID unchanged

- **WHEN** reading `apps/android/android/app/build.gradle.kts` after migration
- **THEN** `applicationId` remains `com.hulk.bazaarAndroid`

#### Scenario: iOS bundle ID unchanged

- **WHEN** reading the iOS Runner build settings after migration
- **THEN** `PRODUCT_BUNDLE_IDENTIFIER` remains `com.hulk.bazaarIos`
