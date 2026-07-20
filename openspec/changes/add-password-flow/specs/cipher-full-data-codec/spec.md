## ADDED Requirements

### Requirement: Full data codec supports typed cipher payloads

The system SHALL treat `cipher.full_data_blob` as encrypted UTF-8 JSON with a mandatory `"type"` field matching `cipher.type` (`CipherType` 1–5). `CipherFullDataCodec.encrypt` / `decrypt` MUST dispatch to the concrete payload class by type. Schema for all types is defined in `packages/core/lib/storage/密码App数据表设计.md`.

#### Scenario: Website-login encrypt-decrypt roundtrip

- **WHEN** `CipherFullDataCodec.encrypt(WebsiteLoginCipherPayload(...))` is called and the result is decrypted
- **THEN** the decrypted payload equals the original username, password, and notes

#### Scenario: Tampered blob fails safely

- **WHEN** decrypt receives invalid ciphertext
- **THEN** the codec throws or returns a typed failure without exposing partial plaintext

#### Scenario: Unsupported type throws on decrypt

- **WHEN** decrypt receives JSON with a type that has no payload implementation yet (e.g. bank card)
- **THEN** the codec throws `UnsupportedCipherTypeException`

### Requirement: Website login is first implemented payload

The first release SHALL implement `WebsiteLoginCipherPayload` for `CipherType.websiteLogin`. Other types are schema-defined but UI/form implementation is deferred.

#### Scenario: Website login type field

- **WHEN** a website-login payload is serialized
- **THEN** JSON contains `"type": 1` and fields username, password, optional notes
