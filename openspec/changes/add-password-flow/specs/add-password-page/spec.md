## ADDED Requirements

### Requirement: User can fill and save a website-login cipher entry

The add-password page SHALL provide fields for display name, **website username**, **website password**, optional website URL, and optional notes. These fields store **third-party service credentials** inside the user's vault, not BarrelLock app account or unlock credentials. On successful save, the system SHALL insert a `cipher` row with encrypted `overview_blob` and `full_data_blob`.

#### Scenario: Successful save

- **WHEN** the user enters valid name, username, and password and taps Save
- **THEN** a new cipher appears in the password tab list after returning home

#### Scenario: Validation blocks empty required fields

- **WHEN** the user leaves name, username, or password empty and taps Save
- **THEN** the system shows validation feedback and does not write to the database

#### Scenario: Cancel returns without saving

- **WHEN** the user taps Cancel
- **THEN** the page closes and no new cipher row is created

### Requirement: Save uses website-login cipher type

The inserted cipher SHALL use `CipherType.websiteLogin` and `folder_uuid` NULL for the first release.

#### Scenario: Cipher type and folder

- **WHEN** a cipher is saved from the add-password form
- **THEN** `cipher.type` equals website-login and `folder_uuid` is NULL

### Requirement: Save failure is surfaced to the user

If encryption or database insert fails, the add-password page SHALL show an error message and keep form input.

#### Scenario: Database failure

- **WHEN** insert throws an exception
- **THEN** the user sees an error message and remains on the add-password page
