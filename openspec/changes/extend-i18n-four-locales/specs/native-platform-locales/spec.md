## ADDED Requirements

### Requirement: iOS declares supported localizations

The iOS Runner target SHALL declare `CFBundleLocalizations` including English, Simplified Chinese, Traditional Chinese, and Arabic.

#### Scenario: Info.plist lists four languages

- **WHEN** inspecting `Info.plist` for the iOS app
- **THEN** `CFBundleLocalizations` contains `en`, `zh-Hans`, `zh-Hant`, and `ar`

### Requirement: iOS permission usage descriptions are localized

Privacy usage description keys in Info.plist SHALL have localized strings in `InfoPlist.strings` for each supported iOS locale.

#### Scenario: English Face ID prompt

- **WHEN** the device language is English and the app requests Face ID
- **THEN** the system permission dialog shows the English `NSFaceIDUsageDescription` text

#### Scenario: Traditional Chinese camera prompt

- **WHEN** the device language is Traditional Chinese and the app requests camera access
- **THEN** the system permission dialog shows Traditional Chinese `NSCameraUsageDescription` text

#### Scenario: Arabic photo library prompt

- **WHEN** the device language is Arabic and the app requests photo library access
- **THEN** the system permission dialog shows Arabic `NSPhotoLibraryUsageDescription` text

### Requirement: Android restricts and provides locale resources

The Android app module SHALL configure locale resources for English, Simplified Chinese, Traditional Chinese, and Arabic, and use localized `app_name` where applicable.

#### Scenario: resConfigs includes four locales

- **WHEN** inspecting Android Gradle configuration
- **THEN** `resConfigs` (or equivalent) includes en, zh-rCN, zh-rTW, and ar

#### Scenario: Localized app label

- **WHEN** the device locale is Arabic
- **THEN** the Android launcher displays the Arabic `app_name` string from `values-ar/strings.xml`

### Requirement: Permission-related native strings cover current app capabilities

Native string resources SHALL include translations for permission domains used by BarrelLock: biometrics, camera, photo library, Bluetooth, and local network (matching current iOS Info.plist keys).

#### Scenario: Bluetooth description available in four languages on iOS

- **WHEN** reviewing iOS `InfoPlist.strings` for each `.lproj`
- **THEN** `NSBluetoothAlwaysUsageDescription` and `NSLocalNetworkUsageDescription` entries exist with non-empty translations
