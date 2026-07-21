## ADDED Requirements

### Requirement: User can change folder from detail page

The detail flow SHALL allow assigning cipher C to another folder within the same vault or to uncategorized (`folder_uuid` NULL). Folder choices SHALL come from `FolderManageModel.watchSummariesByVault(vaultUuid)`.

#### Scenario: Move to existing folder

- **WHEN** the user selects folder F for cipher C in vault V
- **THEN** `CipherEntry.folder_uuid` is updated to F and the password tab list regroups C under F

#### Scenario: Move to uncategorized

- **WHEN** the user selects「未分组」
- **THEN** `CipherEntry.folder_uuid` is set to NULL

### Requirement: User can create folder while changing assignment

The detail folder picker SHALL offer「新建文件夹…」, creating a folder via `FolderManageModel.createFolder` and selecting it for the cipher.

#### Scenario: Create and assign folder

- **WHEN** the user creates folder「旅行」from the detail folder picker and confirms
- **THEN** a new folder row exists in vault V and cipher C references its UUID
