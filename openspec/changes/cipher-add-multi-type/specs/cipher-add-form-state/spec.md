## ADDED Requirements

### Requirement: Form state is a sealed hierarchy per cipher type

`CipherAddFormState` SHALL be a sealed class hierarchy with one concrete state per supported add form (website login, bank card) and a placeholder state for unsupported types. Each state SHALL implement `cipherType`, `canSave`, `isSaving`, and optional error/validation messages.

#### Scenario: Website login canSave rules

- **WHEN** state is `WebsiteLoginFormState` with non-empty title, username, and password
- **THEN** `canSave` is true

#### Scenario: Bank card canSave rules

- **WHEN** state is `BankCardFormState` with non-empty title, cardholder name, card number, expiry month, expiry year, and cvv
- **THEN** `canSave` is true

#### Scenario: Unsupported type cannot save

- **WHEN** state is `UnsupportedTypeFormState`
- **THEN** `canSave` is false
