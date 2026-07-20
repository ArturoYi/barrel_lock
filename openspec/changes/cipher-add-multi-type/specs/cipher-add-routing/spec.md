## MODIFIED Requirements

### Requirement: Cipher add route is registered in AppRoutes

The application SHALL expose route `/cipher/add` with optional query parameters `vaultId` and `type` (integer `CipherType`) through `AppRoutes.cipherAdd`.

#### Scenario: Push add page without vault context

- **WHEN** `AppRouter.push(AppRoutes.cipherAdd())` is called
- **THEN** the add-password page is displayed with website login selected

#### Scenario: Push add page with vault context

- **WHEN** `AppRouter.push(AppRoutes.cipherAdd(vaultId: 'vault-1'))` is called
- **THEN** the add-password page opens with vault context `vault-1`

#### Scenario: Push add page with cipher type

- **WHEN** `AppRouter.push(AppRoutes.cipherAdd(type: CipherType.bankCard))` is called
- **THEN** the add-password page opens with bank card form selected

### Requirement: All platform router configs provide cipherAdd builder

Each BarrelLock platform app SHALL register a `cipherAdd` builder in `app_router_config.dart` so navigation does not fail at runtime.

#### Scenario: iOS router configuration

- **WHEN** the iOS app configures `AppRouteBuilders`
- **THEN** the `cipherAdd` builder returns a `CipherAddPage` widget that passes `vaultId` and `type` from query parameters
