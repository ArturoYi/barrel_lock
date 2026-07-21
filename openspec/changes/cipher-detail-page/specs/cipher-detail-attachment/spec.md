## ADDED Requirements

### Requirement: Detail page lists attachments for supported types

For cipher types with `supportsAttachments == true`, the detail View SHALL show attachment metadata from `AttachmentManageModel.watchMetadataByCipher(cipherUuid)`.

#### Scenario: Bank card with attachments

- **WHEN** the user opens detail for a bank-card cipher with two attachments
- **THEN** two attachment rows with file names and sizes are visible

### Requirement: User can preview and delete attachments from detail

The detail flow SHALL allow previewing decrypted image bytes via `loadDecryptedBytes` and deleting via `deleteAttachment`.

#### Scenario: Delete attachment

- **WHEN** the user confirms deletion of attachment A from detail
- **THEN** attachment A is removed from the database and disappears from the list

### Requirement: User can add attachments from detail

The detail flow SHALL allow adding new attachments subject to the same limits as `cipher_add` (5 files, 5MB each, allowed MIME types).

#### Scenario: Add attachment on detail

- **WHEN** the user picks a valid image for cipher C that currently has 3 attachments
- **THEN** a fourth attachment row is inserted and shown without leaving detail
