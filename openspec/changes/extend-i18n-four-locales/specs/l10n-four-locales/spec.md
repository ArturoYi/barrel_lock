## ADDED Requirements

### Requirement: Four supported app locales

The application SHALL support Simplified Chinese, Traditional Chinese, English, and Arabic through `AppLocalizations`.

#### Scenario: Supported locales list

- **WHEN** the app queries `AppLocalizations.supportedLocales`
- **THEN** the list includes locales for Simplified Chinese, Traditional Chinese (`zh_TW` or equivalent), English, and Arabic

#### Scenario: Simplified and Traditional Chinese are distinct

- **WHEN** the user selects Traditional Chinese
- **THEN** UI strings come from the Traditional Chinese ARB, not Simplified Chinese

#### Scenario: Unsupported system locale falls back to Simplified Chinese

- **WHEN** locale resolution receives a locale not in the supported set (e.g. `fr`)
- **THEN** the resolved locale is Simplified Chinese

### Requirement: Arabic enables RTL layout

When Arabic is active, the app shell SHALL lay out text and navigation using right-to-left direction where Flutter locale semantics apply.

#### Scenario: Arabic text direction

- **WHEN** the active locale is Arabic
- **THEN** the root app widget tree uses RTL text direction for Material/Cupertino descendants

### Requirement: All ARB keys exist in four languages

Every key in the template ARB SHALL have matching entries in English, Traditional Chinese, and Arabic ARB files.

#### Scenario: ARB parity for new overlay keys

- **WHEN** keys such as `overlay_loading` are added
- **THEN** the same keys exist in `app_en.arb`, `app_zh_TW.arb`, and `app_ar.arb`

### Requirement: Legacy locale preference migration

Stored preference value `zh` from the prior two-locale release SHALL be interpreted as Simplified Chinese (`zh_hans`).

#### Scenario: Upgrade from zh storage value

- **WHEN** `AppPreference` returns `zh` for locale preference on first read after upgrade
- **THEN** the app treats the preference as Simplified Chinese
