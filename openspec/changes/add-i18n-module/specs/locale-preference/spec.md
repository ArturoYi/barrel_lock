## ADDED Requirements

### Requirement: User can choose app language preference

The application SHALL allow the user to select one of three language preferences: follow system, Simplified Chinese, or English.

#### Scenario: Follow system preference

- **WHEN** the user selects「跟随系统」in language settings
- **THEN** the app UI language follows the OS locale when supported, otherwise falls back to Simplified Chinese

#### Scenario: Fixed Chinese preference

- **WHEN** the user selects「简体中文」
- **THEN** the app UI uses Simplified Chinese regardless of OS locale

#### Scenario: Fixed English preference

- **WHEN** the user selects「English」
- **THEN** the app UI uses English regardless of OS locale

### Requirement: Language preference persists across sessions

The selected language preference SHALL be stored via `AppPreference` / SharedPreferences and restored on cold start.

#### Scenario: Preference survives restart

- **WHEN** the user sets language to English and kills the app
- **THEN** on next launch the app starts in English without requiring re-selection

#### Scenario: Default for new installs

- **WHEN** no language preference has been saved
- **THEN** the default preference is follow system

### Requirement: Language change applies immediately

Changing language preference SHALL update the running app UI without requiring an app restart.

#### Scenario: Immediate UI update

- **WHEN** the user switches from Chinese to English in settings
- **THEN** visible settings labels and navigation update to English in the same session

### Requirement: Locale state is managed via Riverpod

Language preference SHALL be exposed through a `LocaleNotifier` and `localeSettingsProvider` in `packages/core`, mirroring the existing theme settings pattern.

#### Scenario: Widget reads locale reactively

- **WHEN** a `ConsumerWidget` watches `localeSettingsProvider`
- **THEN** it rebuilds when the user changes language preference

#### Scenario: Preference key is registered

- **WHEN** infrastructure reads `PreferenceKeys.allKeys`
- **THEN** the locale preference storage key is included in the managed key list
