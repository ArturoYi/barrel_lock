## ADDED Requirements

### Requirement: Backup action creates local snapshot

When the user taps action id `backup` on the data migration page, `DataMigrationViewModel` SHALL invoke `BackupManageModel.createLocalBackup`, show progress while busy, and display success or error feedback.

#### Scenario: Successful local backup

- **WHEN** user taps「本地备份」and the operation succeeds
- **THEN** a success message is shown and a new entry appears in backup history

#### Scenario: Backup failure shows error

- **WHEN** `createLocalBackup` throws (e.g. disk full)
- **THEN** an error toast or inline message is shown and the page remains navigable

### Requirement: Restore action presents backup picker

When the user taps action id `restore`, the Coordinator SHALL present a backup list (Sheet or subpage) sourced from `watchRecentBackups()`.

#### Scenario: Empty backup list

- **WHEN** user taps「恢复备份」and no backups exist
- **THEN** the UI explains that no backups are available

### Requirement: Restore requires explicit confirmation

Before calling `BackupManageModel.restoreFromLocalBackup`, the UI SHALL require the user to confirm restore mode (merge or replace) and acknowledge data-loss risk for replace.

#### Scenario: Confirm replace restore

- **WHEN** user selects a backup and chooses replace with confirmation
- **THEN** the database reflects backup contents per replace rules

### Requirement: Busy state prevents duplicate operations

While backup or restore is in progress, duplicate taps on the same action SHALL be ignored and a loading indicator SHALL be visible.

#### Scenario: Double tap backup

- **WHEN** user taps「本地备份」twice during an in-flight backup
- **THEN** only one backup file is created
