## ADDED Requirements

### Requirement: Overlays support glass preset styling

`fast_dialog`, `fast_loading`, and `fast_toast` SHALL accept optional style presets implementing BarrelLock glass semantics (frosted barrier, glass sheet, tokenized corner radius and shadow).

#### Scenario: Dialog default appearance

- **WHEN** feature code shows a standard alert via `FastDialog` without custom style
- **THEN** the dialog barrier and sheet use the glass preset aligned with `GlassTokens.modal` values

#### Scenario: Loading overlay readability

- **WHEN** global loading is shown
- **THEN** the blocking layer uses semi-opaque scrim plus centered glass card; loading indicator contrast MUST meet AA on the card surface

### Requirement: Toast remains lightweight

Toasts SHALL NOT use full-screen `BackdropFilter`; they MAY use solid or lightly translucent fills with neumorphic shadow from tokens.

#### Scenario: Success toast on password copy

- **WHEN** user copies a field and toast appears
- **THEN** toast renders within 16 ms budget of extra layout and does not trigger additional blur layers under the tab bar

### Requirement: Overlay packages stay decoupled from apps

Glass presets SHALL live in a layer importable by `fast_*` packages without creating circular dependencies on `barrel_lock` (e.g. small `app_glass_theme` package or exports from `core`).

#### Scenario: Dependency graph

- **WHEN** `melos run analyze` runs on workspace
- **THEN** no `fast_dialog` → `barrel_lock` dependency exists; glass preset types resolve through `core` or dedicated theme package

### Requirement: Degrade path for web and low GPU

On `kIsWeb` or when `GlassQuality.reduced` is active, overlay presets SHALL use opacity and shadow-only styling without backdrop blur.

#### Scenario: Web dialog

- **WHEN** user opens the same dialog on web
- **THEN** visual parity is approximate (solid frosted color) without requiring `BackdropFilter` support quirks
