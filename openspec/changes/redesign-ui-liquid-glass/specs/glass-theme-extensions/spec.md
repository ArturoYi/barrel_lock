## ADDED Requirements

### Requirement: Theme extensions register with AppTheme

`AppTheme` SHALL attach `GlassTokens`, `NeumorphicTokens`, and `GlassComponentDefaults` (names as implemented) to `ThemeData.extensions` for both light and dark builds.

#### Scenario: ThemedApp provides extensions

- **WHEN** `ThemedApp` builds `MaterialApp.router`
- **THEN** descendant widgets resolve glass theme data via `Theme.of(context).extension<GlassTokens>()` without manual propagation

#### Scenario: Theme mode switch refreshes tokens

- **WHEN** user toggles light/dark/system theme in settings
- **THEN** glass extensions rebuild with the correct brightness-specific token values on the next frame

### Requirement: BuildContext convenience accessors

The shared UI package SHALL export `BuildContext` extensions (e.g. `context.glassTokens`, `context.neumorphicTokens`) mirroring existing `context.theme` patterns in `core`.

#### Scenario: View reads tokens in build

- **WHEN** platform View code imports the shared UI/theme extensions
- **THEN** it can style containers using context accessors without importing implementation libraries from `core` internals

### Requirement: Compatibility with existing theme settings

Glass theme extensions SHALL compose with existing `ThemeNotifier`, `AppThemeMode`, font scale, and `AppColorScheme` persistence without new preference keys unless a glass-specific toggle is added in a later change.

#### Scenario: Font scale increases

- **WHEN** user increases system or app font scale
- **THEN** glass components respect `MediaQuery.textScaler` and token-based minimum touch targets (48 dp logical minimum for primary controls)
