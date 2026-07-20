## ADDED Requirements

### Requirement: Password tab loads vaults from storage

The password tab Model SHALL load active vaults (`is_trashed = false`) from `StorageRepositories.vaults`, decrypt each vault name, and expose them as `VaultSummary` for the UI vault switcher.

#### Scenario: Multiple active vaults

- **WHEN** the database contains two non-trashed vaults with decryptable names
- **THEN** the password tab state includes both vaults in `vaults` and defaults selection to the first vault in stable order

#### Scenario: No vaults in database

- **WHEN** the database contains zero vaults
- **THEN** the password tab shows an empty state without throwing

### Requirement: Password tab lists ciphers grouped by folder

The password tab Model SHALL load ciphers for the selected vault where `deleted_at IS NULL`, decrypt overview blobs, resolve folder names from `StorageRepositories.folders`, and produce `VaultFolderGroup` lists matching the existing UI contract.

#### Scenario: Ciphers in named folders and uncategorized

- **WHEN** a vault has ciphers in folder A and ciphers with `folder_uuid = null`
- **THEN** groups include folder A by decrypted name and an uncategorized group for null-folder ciphers

#### Scenario: Soft-deleted ciphers are hidden

- **WHEN** a cipher has non-null `deleted_at`
- **THEN** it does not appear in any folder group

### Requirement: Search and quick filters operate on decrypted overview

The password tab Model SHALL apply search against decrypted `title`, `subtitle`, and `host`, and apply favorite filter against `is_favorite`. TOTP filter SHALL use `hasTotp` from overview when present.

#### Scenario: Search by title

- **WHEN** the user types a query matching a decrypted cipher title
- **THEN** only matching ciphers appear in folder groups

#### Scenario: Favorites filter

- **WHEN** the user selects the favorites quick filter
- **THEN** only ciphers with `is_favorite = true` are shown

### Requirement: Favorite toggle persists to database

When the user toggles favorite on a cipher card, the ViewModel SHALL update `cipher.is_favorite` in SQLite through the repository and refresh the list.

#### Scenario: Toggle favorite on

- **WHEN** the user taps favorite on an unfavorited cipher
- **THEN** the cipher is stored with `is_favorite = true` and the UI shows the starred state after refresh

### Requirement: No mock seed data in production Model

`PasswordTabModel` SHALL NOT contain hardcoded vault lists, `_seedCiphers()`, or static folder name maps for production data.

#### Scenario: Fresh install empty list

- **WHEN** the database has no cipher rows
- **THEN** the password tab shows the empty list UI and zero folder groups

### Requirement: UI reacts to database changes

The password tab ViewModel SHALL rebuild its state when underlying vault, folder, or cipher tables change (via Drift `watch` streams or equivalent).

#### Scenario: External insert updates list

- **WHEN** a new cipher is inserted for the selected vault while the tab is visible
- **THEN** the new cipher appears without manual page reload
