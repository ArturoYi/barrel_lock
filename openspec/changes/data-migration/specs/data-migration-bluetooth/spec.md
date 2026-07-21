## ADDED Requirements

### Requirement: Bluetooth share is deferred beyond core backup delivery

Until Phase 4 implementation, tapping action id `bluetooth_share` SHALL NOT perform device pairing or data transfer. The UI SHALL inform the user that nearby Bluetooth transfer is not yet available.

#### Scenario: Tap bluetooth share before Phase 4

- **WHEN** user taps「蓝牙共享」in a build without Phase 4
- **THEN** a clear「即将推出」or equivalent message is shown and no backup bytes are transmitted

### Requirement: Future bluetooth transfer sends validated BLBK bytes

When Phase 4 is implemented, the system SHALL transmit the same `.blbak` bytes produced by `BackupManageModel.createSnapshotBytes()` after optional on-device user confirmation, and the receiver SHALL import via the same merge/replace validation path as file import.

#### Scenario: Receive backup over bluetooth

- **WHEN** Phase 4 receiver accepts a completed BLBK transfer and user confirms merge import
- **THEN** imported data matches a file-based import of the same bytes
