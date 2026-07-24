## ADDED Requirements

### Requirement: Toast and Loading can use current locale without Context

The project SHALL provide APIs to show Toast and Loading messages using the active `AppLocalizations` without passing `BuildContext`.

#### Scenario: Loading default message is localized

- **WHEN** code calls the localized loading show helper without a custom message
- **THEN** the visible text uses the `overlay_loading` (or equivalent) string for the active locale

#### Scenario: Toast localized helper

- **WHEN** code invokes a localized Toast helper with an `AppLocalizations` selector function
- **THEN** the Toast displays the string returned for `AppL10n.current`

### Requirement: Built-in overlay message keys exist in all four languages

Common overlay strings for loading, success, error, and please-wait SHALL be defined in ARB for all supported locales.

#### Scenario: English loading overlay

- **WHEN** locale is English and the default loading overlay is shown
- **THEN** the user sees an English loading message, not Chinese

#### Scenario: Arabic error overlay

- **WHEN** locale is Arabic and a localized error Toast helper is used with the shared error key
- **THEN** the user sees Arabic text

### Requirement: Existing Toast API remains compatible

Direct `FastToast.show(String message)` calls with pre-translated strings SHALL continue to work unchanged.

#### Scenario: Explicit string still works

- **WHEN** legacy code passes an already translated string to `FastToast.success`
- **THEN** that exact string is shown without re-localization
