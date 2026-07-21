## ADDED Requirements

### Requirement: Cross-platform BLE backup transfer

In addition to same-platform P2P (Multipeer on iOS, Nearby on Android), the system SHALL support cross-platform backup transfer between iOS and Android using the BLE GATT transport defined in `ble-gatt-backup-transport`, without changing the BLBK payload or import validation path.

#### Scenario: Cross-platform transfer uses BLBK import path

- **WHEN** cross-platform receive completes and the user confirms merge import
- **THEN** `BackupArchiveCodec.decode` and `restoreFromBytes` SHALL be used identically to file import

### Requirement: Same-platform P2P remains available

Same-platform bluetooth transfer SHALL continue to use platform-native P2P APIs and MUST NOT require GATT for iOS↔iOS or Android↔Android transfers.

#### Scenario: Same-platform iOS pair

- **WHEN** both devices run iOS and user selects same-platform transfer
- **THEN** MultipeerConnectivity SHALL be used and GATT SHALL NOT be started

## MODIFIED Requirements

### Requirement: Future bluetooth transfer sends validated BLBK bytes

When bluetooth transfer is implemented (same-platform or cross-platform), the system SHALL transmit the same `.blbak` bytes produced by `BackupManageModel.createSnapshotBytes()` after user confirmation on the sending device, and the receiver SHALL import via the same merge/replace validation path as file import.

#### Scenario: Receive backup over bluetooth

- **WHEN** a receiver accepts a completed BLBK transfer (P2P or GATT) and user confirms merge import
- **THEN** imported data matches a file-based import of the same bytes

## REMOVED Requirements

### Requirement: Bluetooth share is deferred beyond core backup delivery

**Reason**: Phase 4 same-platform and D8 cross-platform supersede the deferral placeholder.

**Migration**: Remove「即将推出」copy; show transport mode picker instead on mobile builds with implemented delegates.
