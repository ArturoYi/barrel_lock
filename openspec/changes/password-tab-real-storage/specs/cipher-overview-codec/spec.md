## ADDED Requirements

### Requirement: Cipher overview encrypts and decrypts a structured JSON payload

The system SHALL serialize list-display fields (`title`, `subtitle`, optional `host`, optional `hasTotp`) as UTF-8 JSON, encrypt with `AppCrypto.encrypt`, and store the result as `cipher.overview_blob`.

#### Scenario: Encrypt-decrypt roundtrip

- **WHEN** `CipherOverviewCodec.encrypt(data)` is called and the result is passed to `CipherOverviewCodec.decrypt`
- **THEN** the decrypted value equals the original `CipherOverviewData`

#### Scenario: Invalid ciphertext fails safely

- **WHEN** decrypt receives tampered or non-cipher bytes
- **THEN** the codec throws or returns a typed failure without crashing unrelated list items

### Requirement: Encrypted name blobs use the same crypto pattern

Vault and folder name fields (`vault.name`, `folder.name`) SHALL use the same JSON-then-encrypt pattern with payload shape `{"name":"<plaintext>"}`.

#### Scenario: Vault name roundtrip

- **WHEN** a vault name is encrypted and stored in `vault.name` BLOB
- **THEN** decrypt yields the original display name string

### Requirement: List layer never decrypts full_data_blob

The overview codec and password tab list pipeline SHALL NOT read or decrypt `cipher.full_data_blob`.

#### Scenario: List build uses overview only

- **WHEN** the password tab builds `CipherOverviewItem` rows for display
- **THEN** only `overview_blob` and non-sensitive columns (`is_favorite`, `folder_uuid`, timestamps) are used
