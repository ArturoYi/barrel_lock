## ADDED Requirements

### Requirement: Cipher type catalog defines all five entry kinds

The system SHALL expose a single catalog (`CipherTypeCatalog`) listing all `CipherType` values (1–5) with human-readable label, icon identifier, and `isEnabled` flag indicating whether the add flow supports that type in the current release.

#### Scenario: Catalog lists five types

- **WHEN** the add page loads the type catalog
- **THEN** exactly five descriptors are returned matching websiteLogin, bankCard, identityDocument, secureNote, and sshKey

#### Scenario: Only website and bank card are enabled in this release

- **WHEN** the catalog is queried for enabled types
- **THEN** only `CipherType.websiteLogin` and `CipherType.bankCard` have `isEnabled == true`
