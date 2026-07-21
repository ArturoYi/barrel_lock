## ADDED Requirements

### Requirement: Attachments are stored as encrypted BLOBs

`AttachmentManageModel` SHALL encrypt attachment file bytes with `AppCrypto` and persist them in `cipher_attachment.encrypted_file`. File names SHALL be encrypted with `EncryptedNameCodec` (or equivalent JSON-encrypted name BLOB) in `file_name`. Plaintext file bytes MUST NOT be written to disk as separate files in this capability.

#### Scenario: Insert attachment for cipher

- **WHEN** `insertAttachment(cipherUuid: C, fileName: "front.jpg", bytes: B)` is called with valid size and MIME
- **THEN** a row is inserted with `cipher_uuid = C`, decryptable name「front.jpg」, and decryptable content equal to `B`

### Requirement: Attachment metadata is queryable without loading file BLOB

The Model SHALL expose metadata-only queries by cipher UUID (attach id, decrypted file name, file size, createdAt) without requiring callers to decrypt `encrypted_file` for listing.

#### Scenario: List attachments by cipher

- **WHEN** cipher C has two attachments
- **THEN** `watchMetadataByCipher(C)` emits two items with names and sizes and does not require full-file decryption for the list API

### Requirement: Attachment file is decrypted only on explicit load

The Model SHALL provide `loadDecryptedBytes(attachUuid)` that reads and decrypts `encrypted_file` on demand.

#### Scenario: Load file for preview

- **WHEN** `loadDecryptedBytes(attachUuid: A)` is called for a valid attachment
- **THEN** the returned bytes match the original plaintext uploaded for A

### Requirement: Attachment size and count limits are enforced

The Model SHALL reject inserts when a single file exceeds 5MB or when the cipher would exceed 5 attachments.

#### Scenario: Reject oversized file

- **WHEN** `insertAttachment` is called with bytes larger than 5MB
- **THEN** the operation fails with a validation error and no row is inserted

#### Scenario: Reject too many attachments

- **WHEN** cipher C already has 5 attachments and a sixth insert is attempted
- **THEN** the operation fails with a validation error and no row is inserted

### Requirement: Deleting attachment removes encrypted row

The Model SHALL delete an attachment row by `attach_uuid`. Cascade on cipher delete is handled by the database FK.

#### Scenario: Delete attachment

- **WHEN** `deleteAttachment(attachUuid: A)` is called
- **THEN** row A no longer exists in `cipher_attachment`
