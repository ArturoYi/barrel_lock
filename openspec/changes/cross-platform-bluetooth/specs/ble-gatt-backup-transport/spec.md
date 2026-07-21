## ADDED Requirements

### Requirement: BarrelLock BLE GATT service identity

The cross-platform backup transport SHALL expose a BLE GATT primary service with UUID `A7B4C3D2-E5F6-4789-A012-3456789ABCDE` and two characteristics: Control `…ABC01` (session JSON) and Data `…ABC02` (BLBG byte stream), as defined in the change design.

#### Scenario: Receiver advertises service

- **WHEN** the user starts receive in cross-platform mode on a supported mobile OS
- **THEN** the device SHALL advertise the BarrelLock backup GATT service UUID until the session completes or is cancelled

#### Scenario: Sender discovers cross-platform peer

- **WHEN** the user starts send in cross-platform mode and a receiver is advertising the service UUID
- **THEN** the sender SHALL connect as GATT central and begin the session handshake on the Control characteristic

### Requirement: BLBG GATT chunk framing

Each GATT Data write SHALL carry a `BLBG` frame: magic `BLBG`, `blbtFrameIndex`, `gattChunkIndex`, `gattChunkTotal`, `payloadLen`, and payload. Payload length MUST NOT exceed `(negotiated_mtu - 16)` bytes, with a default target of 512 bytes payload when MTU allows.

#### Scenario: Reassemble BLBT from BLBG chunks

- **WHEN** all BLBG chunks for a given `blbtFrameIndex` are received in order
- **THEN** the implementation SHALL reconstruct the corresponding BLBT frame byte-for-byte before calling `BackupBluetoothTransfer.decodeFrames`

#### Scenario: Reject malformed BLBG

- **WHEN** a received chunk has invalid magic, out-of-range indices, or payload length mismatch
- **THEN** the session SHALL fail with a user-visible error and release GATT resources

### Requirement: Cross-platform session carries BLBK bytes

The GATT transport SHALL send the same `.blbak` bytes as `BackupManageModel.createSnapshotBytes()`, framed as BLBT logical frames then split into BLBG GATT chunks. The receiver SHALL validate via `BackupBluetoothSessionMeta.sha256Hex` before import.

#### Scenario: iOS send to Android receive

- **WHEN** an iOS device completes send in cross-platform mode and an Android device completes receive and merge import
- **THEN** restored data SHALL match a file import of the same `.blbak` bytes on the Android device

#### Scenario: Android send to iOS receive

- **WHEN** an Android device completes send in cross-platform mode and an iOS device completes receive and merge import
- **THEN** restored data SHALL match a file import of the same `.blbak` bytes on the iOS device

### Requirement: GATT session timeout and cancellation

Cross-platform GATT sessions SHALL use a 180 second discovery/transfer timeout. User cancel SHALL stop advertising, scanning, and disconnect GATT within a reasonable time.

#### Scenario: User cancels cross-platform transfer

- **WHEN** the user taps cancel on the bluetooth backup page during a GATT session
- **THEN** native GATT resources SHALL be released and the page SHALL return without importing partial data

#### Scenario: Timeout without peer

- **WHEN** no compatible peer connects within 180 seconds
- **THEN** the UI SHALL show a timeout message and end the session without partial import
