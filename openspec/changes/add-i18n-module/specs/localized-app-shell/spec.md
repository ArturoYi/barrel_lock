## ADDED Requirements

### Requirement: Root MaterialApp is localization-aware

`ThemedApp` SHALL configure `MaterialApp` / `MaterialApp.router` with localization delegates, supported locales, active locale, and locale resolution callback derived from `app_l10n` and `localeSettingsProvider`.

#### Scenario: Delegates include Material and Cupertino

- **WHEN** the app builds the root `MaterialApp`
- **THEN** `localizationsDelegates` includes `AppLocalizations.delegate` and the global Material, Widgets, and Cupertino localization delegates

#### Scenario: Locale follows user preference

- **WHEN** `localeSettingsProvider` resolves to English
- **THEN** `MaterialApp.locale` is English and `AppLocalizations.of(context)` returns English strings

### Requirement: Widgets access strings via context extension

The `app_l10n` package SHALL provide a `BuildContext` extension (e.g. `context.l10n`) that returns the current `AppLocalizations` instance.

#### Scenario: Widget displays localized text

- **WHEN** a widget calls `Text(context.l10n.commonCancel)`
- **THEN** the label matches the active locale's translation for `common_cancel`

#### Scenario: Missing localization ancestor fails fast in debug

- **WHEN** `context.l10n` is used outside a `MaterialApp` with proper delegates
- **THEN** debug builds surface a clear error (non-null assertion or framework lookup failure)

### Requirement: Settings exposes language selection UI

Each platform settings UI SHALL include a language control wired to `LocaleNotifier`, consistent with the existing theme settings interaction pattern.

#### Scenario: Language tile visible in settings

- **WHEN** the user opens the settings tab or settings page
- **THEN** a language section allows choosing follow system, 简体中文, or English

#### Scenario: Tile uses locale notifier

- **WHEN** the user changes the segmented language control
- **THEN** `LocaleNotifier.setPreference` is invoked and preference is persisted

### Requirement: Core shell strings are migrated in initial release

High-traffic shell UI strings (tab labels, common actions, 404 page, settings section titles for language/theme) SHALL use `AppLocalizations` instead of hardcoded literals as part of this change's M0–M2 milestone.

#### Scenario: Tab navigation is localized

- **WHEN** the app language is English
- **THEN** bottom or primary tab labels display English text from ARB keys

#### Scenario: Unknown route page is localized

- **WHEN** the user navigates to an unknown route
- **THEN** the 404 message uses a localized string key, not a hardcoded English sentence only
