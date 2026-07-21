## ADDED Requirements

### Requirement: User can create folders within a vault

`FolderManageModel` SHALL insert folder rows scoped to a vault UUID with encrypted folder names using `EncryptedNameCodec`.

#### Scenario: Create folder

- **WHEN** `createFolder(vaultUuid: V, name: "社交")` is called with non-empty trimmed name
- **THEN** a folder row is inserted with `vault_uuid = V`, `is_trashed = false`, and decryptable name「社交」

### Requirement: Active folders are watchable by vault

The Model SHALL expose active folders for a vault via `FolderRepository.watchByVault`, decrypting names for UI selection.

#### Scenario: List folders for vault

- **WHEN** vault V has two non-trashed folders
- **THEN** the watch/list API returns both folders with decrypted names
