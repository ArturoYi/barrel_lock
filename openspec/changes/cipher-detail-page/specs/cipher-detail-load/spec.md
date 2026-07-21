## ADDED Requirements

### Requirement: Detail page loads cipher by UUID

`CipherDetailModel` SHALL load a single active cipher by `cipherUuid` via `CipherEntryRepository.findById`. If the row is missing or `deletedAt` is non-null, the Model SHALL surface a not-found error state.

#### Scenario: Successful load

- **WHEN** `loadCipherDetail(cipherUuid: C)` is called and row C exists with `deletedAt` NULL
- **THEN** the Model returns decrypted overview and full-data payload plus vault and folder metadata

#### Scenario: Deleted or missing cipher

- **WHEN** `loadCipherDetail(cipherUuid: C)` is called and row C is missing or soft-deleted
- **THEN** the Model fails with a not-found error and no partial secrets are exposed

### Requirement: Overview and full data are decrypted with existing codecs

The Model SHALL decrypt `overview_blob` with `CipherOverviewCodec` and `full_data_blob` with `CipherFullDataCodec`, then deserialize full data via `CipherFullDataPayload.fromJson`.

#### Scenario: Round-trip after load

- **WHEN** a website-login cipher is loaded
- **THEN** overview title/subtitle/host and full-data username/password/website/notes match the stored plaintext fields

### Requirement: Detail state reacts to database changes

The ViewModel SHALL subscribe to cipher row changes (e.g. `watchAll` filtered by id or re-fetch on save) so that external updates refresh the displayed detail without manual pop.

#### Scenario: Favorite toggled elsewhere

- **WHEN** `isFavorite` changes in the database for cipher C while detail is open
- **THEN** the detail UI reflects the new favorite state on the next emission
