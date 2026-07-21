## ADDED Requirements

### Requirement: Export action writes shareable backup file

When the user taps action id `export_file`, the ViewModel SHALL create snapshot bytes via `BackupManageModel`, then use a platform `BackupFilePicker` / share delegate to save or share a `.blbak` file.

#### Scenario: Export to user-selected location

- **WHEN** user completes export and selects a save destination
- **THEN** the chosen path contains a valid `.blbak` decryptable by `BackupArchiveCodec`

#### Scenario: User cancels file picker

- **WHEN** user dismisses the save/share sheet without confirming
- **THEN** no file is written outside app sandbox (except optional temp cleanup)

### Requirement: Import action reads external backup file

When the user taps action id `import_file`, the ViewModel SHALL open a file picker filtered to `.blbak`, read bytes, validate via `BackupArchiveCodec`, then prompt for merge or replace before restore.

#### Scenario: Import merge from file

- **WHEN** user picks a valid backup and confirms merge
- **THEN** backup rows are upserted per merge rules

#### Scenario: Reject invalid file

- **WHEN** user picks a non-BLBK or corrupt file
- **THEN** import aborts with an error and the database is unchanged

### Requirement: Platform file IO is injected

`barrel_lock` SHALL NOT depend directly on `file_picker` or `share_plus`; apps SHALL provide Riverpod overrides for file pick/save/share delegates used by `DataMigrationViewModel`.

#### Scenario: iOS override provides picker

- **WHEN** BarrelLock iOS runs export
- **THEN** the iOS-injected delegate invokes the system document picker or share sheet
