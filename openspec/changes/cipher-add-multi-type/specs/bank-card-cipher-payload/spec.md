## ADDED Requirements

### Requirement: Bank card full data payload matches storage schema

The system SHALL implement `BankCardCipherPayload` extending `CipherFullDataPayload` with JSON fields: `type` (2), `cardholderName`, `cardNumber`, `expiryMonth`, `expiryYear`, `cvv`, optional `pin`, optional `notes`, per `packages/core/lib/storage/密码App数据表设计.md`.

#### Scenario: Encrypt-decrypt roundtrip

- **WHEN** `CipherFullDataCodec.encrypt(BankCardCipherPayload(...))` is called and decrypted
- **THEN** all fields match the original payload

#### Scenario: Codec fromJson dispatches bank card

- **WHEN** `CipherFullDataPayload.fromJson` receives JSON with `"type": 2`
- **THEN** a `BankCardCipherPayload` instance is returned

### Requirement: Bank card overview mapping on save

When saving a bank card cipher, `overview_blob` SHALL use title from the display name field and subtitle from the last four digits of the card number (or full number if shorter than four digits).

#### Scenario: Overview subtitle shows last four digits

- **WHEN** card number `6222021234567890` is saved with title「招商银行」
- **THEN** overview title is「招商银行」and subtitle is `7890`
