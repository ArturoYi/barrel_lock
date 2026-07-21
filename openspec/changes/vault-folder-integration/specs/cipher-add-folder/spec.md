## ADDED Requirements

### Requirement: Add-password page supports folder selection

The cipher add flow SHALL allow selecting a target folder for the new cipher, persisting `folder_uuid` on insert. A null selection SHALL mean uncategorized (`folder_uuid` NULL).

#### Scenario: Save with selected folder

- **WHEN** the user selects folder F and saves a valid cipher form
- **THEN** the inserted cipher row has `folder_uuid = F`

#### Scenario: Save without folder selection

- **WHEN** the user leaves folder as「未分组」and saves
- **THEN** the inserted cipher row has `folder_uuid` NULL

### Requirement: User can create folder from add page

The add-password page SHALL offer「新建文件夹…」that creates a folder in the current vault and selects it for save.

#### Scenario: Quick create folder on add page

- **WHEN** the user creates folder「银行卡」from the add page while vault V is selected
- **THEN** folder「银行卡」exists under V and the next save uses its UUID
