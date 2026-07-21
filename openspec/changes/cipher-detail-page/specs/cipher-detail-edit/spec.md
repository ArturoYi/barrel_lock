## ADDED Requirements

### Requirement: User can enter edit mode from detail page

The detail ViewModel SHALL allow toggling into edit mode, pre-filling form state from the loaded cipher using the same form state types as `cipher_add`.

#### Scenario: Enter edit mode

- **WHEN** the user taps「编辑」on a supported cipher type
- **THEN** editable fields appear with current decrypted values and validation is cleared

### Requirement: Saving edits updates encrypted blobs in place

`CipherDetailModel.updateCipher` SHALL re-encrypt overview and full-data blobs, set `updatedAt` and `localModified`, and call `CipherEntryRepository.update` without changing `cipher_uuid`.

#### Scenario: Save website login edits

- **WHEN** the user changes the password and saves valid form data
- **THEN** the same cipher row is updated, list overview reflects the new subtitle if username changed, and detail returns to read-only mode

#### Scenario: Validation blocks save

- **WHEN** the user clears a required field and taps save
- **THEN** no database write occurs and a validation message is shown

### Requirement: Cancel edit discards unsaved changes

The ViewModel SHALL restore read-only state from the last loaded cipher when the user cancels edit mode.

#### Scenario: Cancel after edits

- **WHEN** the user edits fields then taps「取消」
- **THEN** displayed values match the last loaded cipher and no database write occurred
