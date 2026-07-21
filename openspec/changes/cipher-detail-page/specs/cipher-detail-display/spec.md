## ADDED Requirements

### Requirement: Detail page shows type-specific read-only fields

The detail View SHALL render fields appropriate to `CipherEntry.type` using `CipherTypeCatalog` labels and icons. Sensitive fields (passwords, PINs, card numbers) SHALL default to masked display with a reveal toggle.

#### Scenario: Website login read view

- **WHEN** the user opens detail for a website-login cipher
- **THEN** the page shows title, username, masked password, website URL, and notes in labeled rows

#### Scenario: Unsupported type fallback

- **WHEN** the user opens detail for a cipher type without a dedicated read layout (e.g. SSH key)
- **THEN** the page shows title and a message that the type is not yet supported for viewing

### Requirement: Detail header shows metadata

The detail View SHALL display cipher title, type label, current folder name (or「未分组」), and favorite indicator.

#### Scenario: Folder name shown

- **WHEN** cipher C has `folder_uuid = F` and folder F decrypts to「工作」
- **THEN** the detail header or metadata section shows「工作」

#### Scenario: Uncategorized folder

- **WHEN** cipher C has `folder_uuid` NULL
- **THEN** the detail shows「未分组」
