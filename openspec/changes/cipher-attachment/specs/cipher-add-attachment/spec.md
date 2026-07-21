## ADDED Requirements

### Requirement: Identity document add form supports optional image attachments

The cipher add flow for `CipherType.identityDocument` SHALL display an attachment section allowing the user to add, preview, and remove pending images before save. Other cipher types SHALL NOT show this section in the first version.

#### Scenario: Attachment section visible on identity document form

- **WHEN** the user selects cipher type identity document on the add page
- **THEN** an attachment section is shown below the form fields

#### Scenario: Attachment section hidden for website login

- **WHEN** the user selects cipher type website login on the add page
- **THEN** no attachment section is shown

### Requirement: User can pick images from camera or gallery

The attachment section SHALL offer actions to capture a photo or pick from the photo library. Accepted MIME types for the first version SHALL be image/jpeg, image/png, and image/webp.

#### Scenario: Pick from gallery

- **WHEN** the user chooses「从相册选择」and selects a JPEG under 5MB
- **THEN** a pending attachment thumbnail appears in the section

#### Scenario: Reject unsupported type

- **WHEN** the user selects a non-image file
- **THEN** the app shows an error and no pending attachment is added

### Requirement: User can remove pending attachments before save

The attachment section SHALL allow removing a pending attachment without persisting to the database.

#### Scenario: Remove pending thumbnail

- **WHEN** the user removes a pending attachment before saving
- **THEN** it disappears from the UI and is not written on save

### Requirement: Save persists pending attachments after cipher insert

On successful cipher save, the add flow SHALL insert all pending attachments linked to the new cipher UUID. Pending attachments MUST NOT be written if save is cancelled.

#### Scenario: Save with two pending images

- **WHEN** the user adds two valid images and saves a valid identity document form
- **THEN** one cipher row is created and two `cipher_attachment` rows reference that cipher

#### Scenario: Save without attachments

- **WHEN** the user saves a valid identity document form with no pending attachments
- **THEN** the cipher row is created and no attachment rows are inserted

#### Scenario: Cancel discards pending attachments

- **WHEN** the user adds pending images and cancels without saving
- **THEN** no attachment rows are inserted

### Requirement: Save surfaces attachment errors

If cipher insert succeeds but attachment insert fails, the add flow SHALL show an error message and MUST NOT navigate away as success.

#### Scenario: Attachment insert failure

- **WHEN** cipher save succeeds but attachment insert fails (e.g. size limit)
- **THEN** the user sees an error snackbar or message and remains on the add page
