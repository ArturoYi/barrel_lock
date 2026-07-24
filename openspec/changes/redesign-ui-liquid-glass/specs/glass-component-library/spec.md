## ADDED Requirements

### Requirement: Shared glass component catalog exists

`barrel_lock_ui` (or a workspace package re-exported by it) SHALL provide documented widgets including at minimum: `GlassPanel`, `GlassAppBar`, `GlassSearchField`, `NeumorphicButton`, `NeumorphicIconButton`, `GlassListTile`, `GlassSectionHeader`, `GlassInsetWell`, `GlassSegmentedControl`, and `AmbientBackground`.

#### Scenario: Platform View uses shared search field

- **WHEN** password tab search UI is migrated
- **THEN** Android and iOS MUST use the same `GlassSearchField` implementation rather than duplicated `BackdropFilter` code

#### Scenario: Export surface

- **WHEN** app code imports `package:barrel_lock_ui/barrel_lock_ui.dart`
- **THEN** glass components and theme extensions needed by Views are available from the public API

### Requirement: Components enforce performance budgets

Each glass component that uses `BackdropFilter` SHALL clip blur to bounds, use `RepaintBoundary` where appropriate, and expose a `GlassQuality` or `enableBlur` flag that defaults from platform capability detection.

#### Scenario: Low quality mode

- **WHEN** `GlassQuality.reduced` is active (debug flag or runtime heuristic)
- **THEN** components render semi-transparent fills without `BackdropFilter` while preserving layout and borders

### Requirement: Composition rules are documented in code

Each public glass widget SHALL document in dartdoc: allowed child types, maximum nesting depth for blur, and pairing with neumorphic variants.

#### Scenario: Nested panel rejection in debug

- **WHEN** developer nests two `GlassPanel` widgets both with blur enabled in debug mode
- **THEN** an assert or debug log WARNs per catalog rules

### Requirement: Settings and form controls migrate to catalog

Settings appearance tiles, language list rows, and common form fields SHALL have glass/neumorphic equivalents in the catalog before platform settings Views are marked complete in the rollout milestone.

#### Scenario: Language settings page

- **WHEN** user opens language settings after M2 rollout
- **THEN** selection rows use `GlassListTile` or successor with checkmark affordance from tokens
