## ADDED Requirements

### Requirement: Visual principles express trust and clarity

The product UI SHALL follow BarrelLock Glass Design Language with three pillars: **translucent security** (content readable through controlled blur, not opaque blocks), **refined tactility** (subtle depth via glass + soft neumorphic cues), and **clear hierarchy** (background → ambient layer → glass surface → elevated control → modal).

#### Scenario: Hierarchy on a typical list screen

- **WHEN** user opens the password tab home list
- **THEN** the scrollable list sits on a glass or neumorphic inset surface above a non-interactive ambient background, with primary actions visually above list rows

#### Scenario: Security-sensitive content remains legible

- **WHEN** masked fields or lock overlays are shown
- **THEN** contrast ratios for primary text on glass surfaces MUST meet WCAG 2.1 AA for normal text in both light and dark themes

### Requirement: Liquid glass usage is bounded

Glass effects (blur + semi-transparent fill + hairline border) SHALL be used for navigation chrome, grouped settings, search bars, and floating panels. Full-screen opaque `Scaffold` backgrounds SHALL NOT remain the default app shell after migration.

#### Scenario: Tab bar uses glass chrome

- **WHEN** user views the home tab bar
- **THEN** the tab bar renders with prescribed glass treatment from the design token system

#### Scenario: Dense data tables avoid stacked blur

- **WHEN** a screen displays more than one scrollable glass layer in the same viewport
- **THEN** inner layers MUST use solid or neumorphic inset surfaces without additional `BackdropFilter` unless explicitly allowed by the component catalog

### Requirement: Neumorphism is a restrained accent

Soft dual-shadow inset/outset surfaces SHALL complement glass (e.g. PIN pads, segmented controls, icon buttons). Heavy extruded skeuomorphism and strong bevels SHALL NOT be used.

#### Scenario: Primary button on glass panel

- **WHEN** user sees a primary action on a glass card
- **THEN** the button MAY use neumorphic outset styling while the card uses glass styling, not both at maximum intensity on the same element

### Requirement: Motion supports depth not distraction

Standard transitions SHALL use short durations (150–280 ms) with ease-out curves; parallax and blur animation MUST be disabled when `MediaQuery.disableAnimations` is true or platform reduced-motion is requested.

#### Scenario: Reduced motion

- **WHEN** user enables reduce motion at OS level
- **THEN** glass blur cross-fades and scale animations on dialogs MUST degrade to opacity-only or instant transitions
