## ADDED Requirements

### Requirement: Add page displays a cipher type selector

The add-password page SHALL render a type selector above the form, driven by `CipherTypeCatalog`, allowing the user to choose the cipher category before filling fields.

#### Scenario: Default selection is website login

- **WHEN** the user opens `/cipher/add` without `type` query
- **THEN** website login is selected and the website login form is shown

#### Scenario: Initial type from route query

- **WHEN** the user opens `/cipher/add?type=2`
- **THEN** bank card is selected and the bank card form is shown

#### Scenario: Disabled type cannot be selected

- **WHEN** the user taps a type with `isEnabled == false` (e.g. SSH)
- **THEN** the selection does not change and the user sees feedback that the type is coming soon

#### Scenario: Changing type resets the form

- **WHEN** the user switches from website login to bank card after entering data
- **THEN** the form state resets to empty bank card fields

### Requirement: Type selector syncs with ViewModel cipher type

The ViewModel SHALL hold the selected cipher type as part of `CipherAddFormState.cipherType` and update the active form state when the user selects a new enabled type.

#### Scenario: ViewModel reflects selection

- **WHEN** the user selects bank card in the selector
- **THEN** `CipherAddViewModel` state becomes `BankCardFormState` with `cipherType == CipherType.bankCard`
