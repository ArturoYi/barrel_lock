## ADDED Requirements

### Requirement: Backup file uses BLBK container format

The system SHALL define backup files with extension `.blbak` and on-disk layout: 4-byte magic `BLBK`, 4-byte little-endian `formatVersion`, followed by an `AppCrypto`-encrypted UTF-8 JSON payload (`EncryptedPayload` layout).

#### Scenario: Round-trip encode and decode

- **WHEN** a valid backup snapshot JSON is encoded to bytes and decoded
- **THEN** the decoded tables match the source snapshot and `formatVersion` is preserved

### Requirement: Backup payload includes all password tables

The decrypted JSON payload SHALL include `formatVersion`, `appSchemaVersion`, `exportedAt`, and a `tables` object with arrays for `vault`, `folder`, `cipher`, and `cipher_attachment`. Each row MUST preserve primary keys and encrypted BLOB fields (transport-encoded without altering semantic ciphertext).

#### Scenario: Snapshot contains attachments

- **WHEN** the live database has cipher rows with attachment rows
- **THEN** the encoded payload `tables.cipher_attachment` contains the same row count and attach UUIDs

### Requirement: Backup integrity is verified on import

`BackupArchiveCodec` SHALL compute and verify a SHA-256 checksum over canonical table JSON before import proceeds.

#### Scenario: Reject tampered backup

- **WHEN** a `.blbak` file has a valid outer decrypt but checksum mismatch
- **THEN** import fails with an integrity error and no database rows are modified

### Requirement: Unsupported format versions are rejected

The codec SHALL reject files whose magic, `formatVersion`, or `appSchemaVersion` exceeds the running app's supported maximum.

#### Scenario: Reject future schema backup

- **WHEN** `appSchemaVersion` in the payload is greater than `DatabaseSchemaVersion.current`
- **THEN** the decode operation fails with an upgrade-required error
