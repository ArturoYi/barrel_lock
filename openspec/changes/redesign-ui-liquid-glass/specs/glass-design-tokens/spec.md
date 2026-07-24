## ADDED Requirements

### Requirement: Design tokens are centralized and typed

The monorepo SHALL define `GlassTokens` (and related token structs) as immutable values resolved from brightness, `AppColorScheme` seed, and optional user theme settings, exposed via `ThemeExtension` on `ThemeData`.

#### Scenario: Light and dark token sets

- **WHEN** `ThemeData.brightness` is `Brightness.light` or `Brightness.dark`
- **THEN** `context.glassTokens` (or equivalent extension) returns a complete token set including blur sigma, surface tints, border opacities, and shadow presets

#### Scenario: Seed color affects accent glass tint

- **WHEN** user selects a different `AppColorScheme` in settings
- **THEN** glass highlight and border accent tokens MUST derive from the active seed color without breaking contrast requirements

### Requirement: Token catalog covers required dimensions

Token definitions SHALL include at minimum: corner radii scale (`xs`–`xl`), spacing scale (4 pt grid), blur sigmas (`glassBar`, `glassPanel`, `modal`), surface fill opacities, hairline border width/color, neumorphic highlight/shadow offsets and spreads, elevation z-index map, and typography roles linked to existing `AppTypography`.

#### Scenario: Component reads blur from tokens only

- **WHEN** a shared glass component applies backdrop blur
- **THEN** it MUST use token blur values, not hard-coded literals in feature or platform View code

#### Scenario: Analyzer rejects magic numbers in new UI code

- **WHEN** CI runs analyze on `barrel_lock_ui` glass components
- **THEN** public widgets MUST not expose raw blur sigma as required constructor parameters except for documented debug overrides

### Requirement: Semantic color roles for vault UX

Beyond Material `ColorScheme`, tokens SHALL define semantic roles: `ambientBackground`, `glassSurface`, `glassBorder`, `insetWell`, `secretField`, `danger`, `success`, usable in both themes.

#### Scenario: Secret field row

- **WHEN** cipher detail displays a copyable secret field
- **THEN** the row background uses `secretField` token styling distinct from generic list tiles
