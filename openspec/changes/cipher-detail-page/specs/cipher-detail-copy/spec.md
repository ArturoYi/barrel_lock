## ADDED Requirements

### Requirement: User can copy individual fields to clipboard

The detail View SHALL provide a copy action per copyable field (username, password, URL, card number, notes, etc.). Invoking copy SHALL write the field's plaintext to the system clipboard.

#### Scenario: Copy password

- **WHEN** the user taps copy on the password field of a website-login cipher
- **THEN** the clipboard contains the decrypted password string

#### Scenario: Copy username

- **WHEN** the user taps copy on the username field
- **THEN** the clipboard contains the username string

### Requirement: Copy success is acknowledged in UI

After a successful copy, the app SHALL show brief feedback (e.g. SnackBar「已复制」) without leaving the detail page.

#### Scenario: SnackBar after copy

- **WHEN** the user copies any field successfully
- **THEN** a SnackBar or equivalent toast confirms the copy
