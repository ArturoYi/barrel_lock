## ADDED Requirements

### Requirement: Global AppLocalizations without BuildContext

The application SHALL expose the current `AppLocalizations` instance through a global accessor (e.g. `AppL10n.current`) that does not require `BuildContext`.

#### Scenario: ViewModel reads localized string

- **WHEN** a ViewModel invokes `AppL10n.current` after locale has been initialized
- **THEN** it receives the same translations as `context.l10n` for the active locale

#### Scenario: Global accessor updates on locale change

- **WHEN** the user changes language preference in settings
- **THEN** subsequent calls to `AppL10n.current` return strings for the new locale without requiring app restart

#### Scenario: Holder initialized at app start

- **WHEN** the app finishes launching with a resolved locale
- **THEN** `AppL10n.current` is available before the first user interaction
