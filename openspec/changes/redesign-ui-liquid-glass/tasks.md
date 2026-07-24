## 1. M0 — Design tokens & theme extensions

- [ ] 1.1 Add `packages/core/lib/theme/glass/` with `GlassTokens`, `NeumorphicTokens`, semantic color roles, and light/dark resolvers tied to `AppColorScheme` seed
- [ ] 1.2 Register extensions in `AppTheme._build` and export via `core.dart`
- [ ] 1.3 Add `BuildContext` accessors (`glassTokens`, `neumorphicTokens`) in `app_theme_x.dart` or dedicated `glass_theme_x.dart`
- [ ] 1.4 Implement `GlassQuality` enum and `resolveGlassQuality` (web → reduced; debug override)
- [ ] 1.5 Document token anchor values in dartdoc aligned with design.md D4 table
- [ ] 1.6 Widget test: extension present on light/dark `ThemeData` from `AppTheme`

## 2. M0 — Component library foundations

- [ ] 2.1 Create `apps/barrel_lock_ui/lib/glass/` module and export from `barrel_lock_ui.dart`
- [ ] 2.2 Implement `AmbientBackground` (gradient mesh, no blur)
- [ ] 2.3 Implement `GlassPanel` with clip + optional blur + fill/border stack and `enableBlur` / quality hook
- [ ] 2.4 Implement `NeumorphicButton`, `NeumorphicIconButton`, `GlassInsetWell`
- [ ] 2.5 Implement `GlassListTile`, `GlassSectionHeader`, `GlassSearchField`, `GlassSegmentedControl`
- [ ] 2.6 Implement `GlassAppBar` / shell bar wrapper for home tabs
- [ ] 2.7 Add debug-only Glass Gallery page (route or hidden settings entry) showcasing all primitives in light/dark
- [ ] 2.8 Widget tests for `GlassPanel` and `NeumorphicButton` in light and dark

## 3. M0 — Engineering guidelines

- [ ] 3.1 Update `.cursor/rules/project-context-mdc.mdc` with glass SSOT paths and “no magic blur in platform Views” rule
- [ ] 3.2 Add optional `scripts/check_glass_usage.sh` (grep `BackdropFilter` outside allowlist) or document manual review in tasks README

## 4. M1 — App shell

- [ ] 4.1 Wrap `ThemedApp` body with `Stack`: `AmbientBackground` + transparent scaffold default
- [ ] 4.2 Migrate home tab bar (six apps) to shared glass navigation chrome
- [ ] 4.3 Replace Android/iOS `settings_gradient_background` with shared ambient + `GlassPanel` settings master list
- [ ] 4.4 Align macOS/web/windows/linux settings split views with glass master/detail surfaces
- [ ] 4.5 Delete duplicated gradient background widgets after parity check
- [ ] 4.6 Manual pass: RTL (ar) on home + settings shell; reduce-motion behavior

## 5. M2 — Password tab

- [ ] 5.1 Replace Android/iOS `vault_search_bar` with `GlassSearchField`
- [ ] 5.2 Restyle vault list tiles and empty states with `GlassListTile` / section headers
- [ ] 5.3 Restyle vault switcher and landscape side panel with `GlassPanel`
- [ ] 5.4 Desktop/web password tab layouts: apply same components without new local decorations
- [ ] 5.5 Performance check: scroll password list on mid-tier device; ≤2 blur regions in viewport

## 6. M3 — Cipher detail & add flows

- [ ] 6.1 Migrate cipher detail field rows and attachment sections to glass/inset catalog widgets (all platforms)
- [ ] 6.2 Migrate cipher add/edit forms: grouped sections in `GlassPanel`, primary actions `NeumorphicButton`
- [ ] 6.3 Apply `secretField` token styling to copyable secret rows
- [ ] 6.4 Verify contrast AA on detail screens in light and dark with each seed color

## 7. M4 — Settings, support, migration

- [ ] 7.1 Restyle `settings_appearance_tiles` and language settings with glass components
- [ ] 7.2 Migrate remaining settings sections (vault, security, about) on six apps
- [ ] 7.3 Migrate support/feedback and data migration screens in `barrel_lock` features
- [ ] 7.4 Launch screen visual refresh (glass-friendly) without breaking startup timing

## 8. M5 — Overlays, lock UI, cleanup

- [ ] 8.1 Add glass overlay presets consumable by `fast_dialog`, `fast_loading`, `fast_toast` (no `barrel_lock` dependency in fast_*)
- [ ] 8.2 Wire default presets in `runBarrelLockApp` / `ThemedApp` initialization
- [ ] 8.3 App lock: keep privacy overlay blur-free; interactive PIN on glass scrim + `GlassInsetWell` keys
- [ ] 8.4 Remove remaining deprecated local `BoxDecoration` blur/gradient copies in platform Views
- [ ] 8.5 Run `melos run ci`; fix analyze/test regressions
- [ ] 8.6 Spike doc update: `RoundedSuperellipseBorder` for tab bar (resolve Open Question #3) and apply if approved

## 9. Visual specification appendix (design sign-off)

- [ ] 9.1 Record final token table (sigma, opacity, radii) in `packages/core/lib/theme/glass/README.md` after M0 tuning
- [ ] 9.2 Capture before/after screenshots for home, password list, cipher detail, settings (light/dark) for release notes
