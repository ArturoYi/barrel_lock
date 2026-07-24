## ADDED Requirements

### Requirement: Migration follows defined milestones

UI reimplementation SHALL proceed in milestones M0–M5 with explicit exit criteria; no milestone SHALL be marked complete until `melos run analyze` passes and listed screens are migrated.

#### Scenario: M0 foundation gate

- **WHEN** M0 completes
- **THEN** tokens, theme extensions, `AmbientBackground`, and component catalog stubs exist with a debug preview route showing all primitives

#### Scenario: M1 shell gate

- **WHEN** M1 completes
- **THEN** home shell, tab bar, and settings ambient background use shared implementation on all six platform apps

#### Scenario: M2 password tab gate

- **WHEN** M2 completes
- **THEN** vault list, search, switcher, and empty states on mobile platforms use glass components; desktop/web password tab matches layout spec

#### Scenario: M3 cipher flows gate

- **WHEN** M3 completes
- **THEN** cipher detail, add/edit flows, and attachments UI use catalog components for rows, sections, and primary actions

#### Scenario: M4 settings and support gate

- **WHEN** M4 completes
- **THEN** settings (appearance, language, vault), support/feedback, and data migration screens meet design language requirements

#### Scenario: M5 overlays and polish gate

- **WHEN** M5 completes
- **THEN** dialog/loading/toast presets ship; deprecated local decorations removed; golden or widget tests cover at least one light and one dark glass component

### Requirement: View versus feature ownership

Platform `lib/pages/**` Views SHALL consume shared glass widgets and tokens; new decorative `BoxDecoration` in platform Views SHALL NOT be added after M0 except via approved catalog widgets.

#### Scenario: New screen added during rollout

- **WHEN** a developer adds a new settings page during M2
- **THEN** the page MUST be built from glass catalog components without raw gradient copy-paste

### Requirement: Visual regression and performance checks

Each milestone merge SHALL include manual checklist items: 60 fps scroll on password list (mid-tier device target), no more than two simultaneous blur regions on primary routes, and dark mode parity.

#### Scenario: CI widget tests

- **WHEN** M5 completes
- **THEN** repository contains at least one widget test per `GlassPanel` and `NeumorphicButton` verifying token application in light and dark themes

### Requirement: Documentation updates track rollout

Project rules (`.cursor/rules`) SHALL document glass usage constraints (no hard-coded blur, prefer `context.l10n` unchanged) when M0 completes.

#### Scenario: Contributor reads project context

- **WHEN** developer reads project-context rule after M0
- **THEN** it references glass tokens, catalog import path, and migration milestone status
