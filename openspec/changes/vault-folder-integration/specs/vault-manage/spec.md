## ADDED Requirements

### Requirement: User can create a vault from password tab

The application SHALL allow the user to create a new active vault with an encrypted name via `VaultManageModel` and `StorageRepositories.vaults.insert`.

#### Scenario: Create vault from switcher menu

- **WHEN** the user opens the vault switcher and chooses「新建保险库」, enters a non-empty name, and confirms
- **THEN** a new vault row is inserted with `is_trashed = false` and the password tab selects that vault

#### Scenario: Create first vault from empty state

- **WHEN** the database has zero active vaults and the user taps「创建保险库」on the password tab empty state
- **THEN** a vault is created and the tab loads with that vault selected

### Requirement: Default vault bootstrap remains on cipher save

When saving a cipher and no active vault exists, the system SHALL create default vault「我的保险库」via shared vault manage logic before inserting the cipher.

#### Scenario: Implicit bootstrap on add save

- **WHEN** the user saves a valid cipher form and zero active vaults exist
- **THEN** exactly one default vault is created and the cipher references it

#### Scenario: No duplicate vault on save with existing vault

- **WHEN** at least one active vault exists and the user saves a new cipher
- **THEN** vault count does not increase
