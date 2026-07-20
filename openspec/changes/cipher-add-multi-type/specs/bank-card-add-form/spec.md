## ADDED Requirements

### Requirement: User can fill and save a bank card cipher entry on iOS

The iOS add page SHALL provide a bank card form with fields: display name (title), cardholder name, card number, expiry month, expiry year, CVV, optional PIN, and optional notes. On successful save, the system SHALL insert a cipher with `type == CipherType.bankCard`.

#### Scenario: Successful bank card save

- **WHEN** the user selects bank card, fills required fields, and taps Save
- **THEN** a new cipher appears in the password tab list after returning home

#### Scenario: Validation blocks incomplete bank card

- **WHEN** the user leaves card number or CVV empty and taps Save
- **THEN** validation feedback is shown and no database write occurs

#### Scenario: Sensitive fields use obscured input where appropriate

- **WHEN** the bank card form is displayed
- **THEN** card number, CVV, and PIN fields support obscured entry with visibility toggle
