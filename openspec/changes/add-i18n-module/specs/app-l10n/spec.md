## ADDED Requirements

### Requirement: Workspace package provides centralized translations

The monorepo SHALL include a dedicated package `packages/app_l10n` registered in the root `workspace:` list, with `resolution: workspace` in its `pubspec.yaml`, exposing a single library entry `app_l10n.dart`.

#### Scenario: Package is resolvable by apps

- **WHEN** a workspace member adds `app_l10n` as a path dependency
- **THEN** `dart pub get` resolves the package without version conflicts

#### Scenario: Public API is exported from entry library

- **WHEN** consumer code imports `package:app_l10n/app_l10n.dart`
- **THEN** `AppLocalizations`, delegates, supported locales, and `BuildContext` extension are available

### Requirement: Translations are maintained via ARB code generation

The `app_l10n` package SHALL use Flutter `gen-l10n` with ARB files as the single source of truth for user-visible strings.

#### Scenario: Template locale is Simplified Chinese

- **WHEN** developers add a new string key
- **THEN** the key MUST be added to `app_zh.arb` first as the template ARB file

#### Scenario: English translations exist for every key

- **WHEN** a key exists in `app_zh.arb`
- **THEN** the same key MUST exist in `app_en.arb` with an English translation

#### Scenario: Generated localizations compile

- **WHEN** `flutter gen-l10n` runs after ARB changes
- **THEN** `AppLocalizations` generates without analyzer errors and `melos run analyze` passes

### Requirement: Supported app locales are zh and en

`AppLocalizations` SHALL declare support for Simplified Chinese (`zh`) and English (`en`) only in the initial release.

#### Scenario: Supported locales list

- **WHEN** the app queries `AppLocalizations.supportedLocales`
- **THEN** the list includes `Locale('zh')` and `Locale('en')`

#### Scenario: Unsupported locale falls back to zh

- **WHEN** `AppLocalizations.resolveLocale` receives a locale not in the supported set (e.g. `fr`)
- **THEN** the resolved locale is `Locale('zh')`

### Requirement: ARB keys follow naming convention

User-visible string keys SHALL use snake_case with feature prefixes (`common_`, `settings_`, `tab_`, `cipher_`, etc.) as documented in the change design.

#### Scenario: Duplicate semantics use one key

- **WHEN** the same label (e.g. cancel action) appears in multiple screens
- **THEN** developers reuse one shared key such as `common_cancel` rather than duplicating literals
