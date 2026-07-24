## ADDED Requirements

### Requirement: Root ambient background replaces flat scaffold fill

The application shell SHALL render an `AmbientBackground` (gradient mesh, subtle noise, or seed-tinted wash) behind all primary routes, with `Scaffold.backgroundColor` set transparent where the ambient layer is used.

#### Scenario: Home route background

- **WHEN** user lands on home after launch
- **THEN** content does not sit on a flat `ColorScheme.surface` full-bleed rectangle unless a route explicitly opts into solid background

#### Scenario: RTL and wide layout

- **WHEN** layout is RTL or landscape split-view on tablet/desktop
- **THEN** ambient background covers the full window; glass side panels align per reading direction

### Requirement: Navigation chrome is glass-consistent

Bottom navigation (mobile), side navigation (desktop), and settings split views SHALL use shared shell widgets with consistent height, blur, and safe-area padding.

#### Scenario: Settings split view on iOS

- **WHEN** user opens settings in landscape on iPad-class width
- **THEN** master list and detail pane use glass surfaces defined in the shell spec, matching macOS/web split behavior where applicable

### Requirement: Launch and lock surfaces align with language

Launch screen and app-lock overlays SHALL adopt glass or solid privacy modes per existing `AppLockSessionBarrier` behavior: privacy-only mode MUST remain cheap (no blur); interactive unlock MAY use glass with reduced blur sigma.

#### Scenario: App switcher privacy mask

- **WHEN** app enters background privacy overlay
- **THEN** overlay MUST NOT allocate `BackdropFilter` (performance requirement retained)

#### Scenario: Interactive PIN unlock

- **WHEN** user unlocks with PIN on foreground
- **THEN** PIN pad uses neumorphic inset wells on a glass or frosted full-screen scrim per tokens

### Requirement: Duplicate platform backgrounds are removed

After shell migration, `settings_gradient_background` and equivalent duplicated files across platform apps SHALL be deleted in favor of shared shell widgets.

#### Scenario: Single implementation

- **WHEN** migration milestone M1 completes
- **THEN** at most one shared ambient/shell implementation exists for settings background styling
