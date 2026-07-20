## ADDED Requirements

### Requirement: Default vault is created when none exists on save

When saving a new cipher and no active vault exists, the system SHALL create a default vault named「我的保险库」before inserting the cipher.

#### Scenario: First password in empty database

- **WHEN** the user saves a valid add-password form and the database has zero active vaults
- **THEN** a new vault row is inserted and the cipher references that vault UUID

### Requirement: Default vault is not duplicated

When at least one active vault exists, the system SHALL NOT create another vault during save.

#### Scenario: Save with existing vault

- **WHEN** the database already has an active vault and the user saves a new cipher
- **THEN** only one new cipher row is inserted and vault count remains unchanged
