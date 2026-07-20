## ADDED Requirements

### Requirement: Password tab add entry opens cipher add route

The password tab coordinator SHALL navigate to `AppRoutes.cipherAdd` with the currently selected vault ID when available, instead of the detail placeholder route.

#### Scenario: Add from password tab with selected vault

- **WHEN** the user taps the add button while vault「个人库」is selected
- **THEN** navigation targets `/cipher/add` with `vaultId` for that vault

#### Scenario: Add from empty vault state

- **WHEN** the user taps add while no vault is selected
- **THEN** navigation targets `/cipher/add` without `vaultId` and the add flow resolves vault on save

## REMOVED Requirements

### Requirement: Add password opens detail placeholder

**Reason**: Replaced by dedicated add-password page  
**Migration**: Use `AppRoutes.cipherAdd`; remove `AppRoutes.detail(id: 'new')` from `PasswordTabCoordinator.openAddPassword`
