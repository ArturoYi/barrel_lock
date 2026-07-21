## ADDED Requirements

### Requirement: User can soft-delete cipher from detail page

The detail flow SHALL soft-delete the current cipher by setting `deletedAt` to the current UTC time and `localModified` to true. The cipher MUST NOT appear in the password tab list afterward.

#### Scenario: Confirm delete

- **WHEN** the user confirms delete on cipher C
- **THEN** row C has non-null `deletedAt`, detail navigates back, and C is absent from vault list queries

#### Scenario: Cancel delete dialog

- **WHEN** the user opens delete confirmation then cancels
- **THEN** no database change occurs and the user remains on detail

### Requirement: Favorite can be toggled from detail page

The detail ViewModel SHALL toggle `isFavorite` via `CipherEntryRepository.setFavorite` and update UI immediately.

#### Scenario: Toggle favorite on

- **WHEN** the user marks cipher C as favorite from detail
- **THEN** `isFavorite` is true and the favorite filter includes C

#### Scenario: Toggle favorite off

- **WHEN** the user removes favorite from cipher C
- **THEN** `isFavorite` is false
