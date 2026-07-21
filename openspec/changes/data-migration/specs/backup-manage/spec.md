## ADDED Requirements

### Requirement: BackupManageModel creates full snapshots

`BackupManageModel` SHALL read all rows from `StorageRepositories` (`vaults`, `folders`, `cipherEntries`, `cipherAttachments`) and produce a `.blbak` byte array via `BackupArchiveCodec` without decrypting business BLOBs.

#### Scenario: Create snapshot from populated database

- **WHEN** `createSnapshotBytes()` is called on a database with at least one vault and cipher
- **THEN** returned bytes decode to a payload whose table row counts match the source repositories

### Requirement: Local backups are written to app storage

The Model SHALL write snapshot bytes to `{applicationDocumentsDirectory}/backups/{logId}.blbak` and insert a corresponding `backup_log` row with `backupPath`, `backupTime`, `vaultVersion`, and `isEncrypted = true`.

#### Scenario: Create local backup

- **WHEN** `createLocalBackup(note: optional)` succeeds
- **THEN** a file exists at the recorded `backupPath` and a `backup_log` row is queryable by `logId`

### Requirement: Recent backups are listable

The Model SHALL expose `watchRecentBackups()` ordered by `backupTime` descending, returning metadata (logId, backupTime, backupPath, note) without loading full file bytes.

#### Scenario: List two backups

- **WHEN** two local backups exist
- **THEN** `watchRecentBackups()` emits both entries with newest first

### Requirement: Restore supports merge and replace modes

`BackupManageModel` SHALL support:

- **merge**: upsert rows by primary key UUID; rows present locally but absent in backup are retained
- **replace**: delete all business-table rows then insert backup rows inside a transaction

#### Scenario: Merge preserves local-only cipher

- **WHEN** local DB has cipher L and backup contains cipher B only
- **THEN** after merge import both L and B exist

#### Scenario: Replace removes local-only data

- **WHEN** local DB has cipher L and backup contains cipher B only
- **THEN** after replace import only B exists

### Requirement: Restore validates before writing

Restore operations SHALL decode and checksum-verify the backup before any merge/replace write.

#### Scenario: Failed validation leaves DB unchanged

- **WHEN** restore is attempted with a corrupt `.blbak`
- **THEN** no vault/cipher rows are added or deleted
