## ADDED Requirements

### Requirement: Transport mode selection on bluetooth share entry

The bluetooth role picker SHALL offer distinct choices for same-platform nearby transfer and cross-platform BLE transfer. Same-platform options MUST remain labeled as iOS↔iOS or Android↔Android only.

#### Scenario: User chooses cross-platform send

- **WHEN** user selects cross-platform send from the role picker
- **THEN** the app SHALL navigate to the bluetooth backup page configured for cross-platform GATT send

#### Scenario: User chooses same-platform send

- **WHEN** user selects same-platform send
- **THEN** the app SHALL use the existing Multipeer or Nearby delegate without invoking GATT

### Requirement: Cross-platform backup page messaging

The bluetooth backup page in cross-platform mode SHALL explain that iOS and Android can pair via BLE, require foreground operation on both devices, and that large backups may take several minutes.

#### Scenario: Cross-platform receive waiting state

- **WHEN** cross-platform receive is active and discovering
- **THEN** the page SHALL show a waiting state distinct from same-platform copy (e.g.「等待跨平台发送端连接」)

#### Scenario: Cross-platform progress

- **WHEN** BLBG chunks are transferring
- **THEN** the page SHALL show progress derived from EventChannel `progress` events

## MODIFIED Requirements

### Requirement: Bluetooth share defers only when no transport is implemented

The system SHALL NOT show a permanent「即将推出」message once either same-platform P2P or cross-platform GATT is available on the current platform build.

#### Scenario: Tap bluetooth share on supported mobile build

- **WHEN** user taps「蓝牙共享」on iOS or Android with Phase 4 + D8 enabled
- **THEN** the role/mode picker is shown instead of a deferral toast
