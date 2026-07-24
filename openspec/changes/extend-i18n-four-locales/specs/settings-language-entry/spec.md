## ADDED Requirements

### Requirement: Settings exposes dedicated language entry

The settings tab SHALL include a navigable item for language selection, separate from theme and display settings.

#### Scenario: Language item visible

- **WHEN** the user opens the settings tab
- **THEN** a list item labeled with the localized word for language is visible

#### Scenario: Item shows current selection summary

- **WHEN** the user has selected English as the fixed language
- **THEN** the language settings item subtitle or trailing text indicates English (or localized equivalent)

#### Scenario: Default is follow system

- **WHEN** no language preference has been saved
- **THEN** the summary indicates follow-system behavior

### Requirement: Language selection page supports five options

The language settings screen SHALL allow choosing: follow system, Simplified Chinese, Traditional Chinese, English, or Arabic.

#### Scenario: Select Traditional Chinese

- **WHEN** the user selects Traditional Chinese on the language settings screen
- **THEN** `LocaleNotifier` persists the choice and the app UI updates immediately

#### Scenario: Select Arabic

- **WHEN** the user selects Arabic
- **THEN** the app switches to Arabic strings and RTL shell layout

### Requirement: Inline appearance locale control is not duplicated

The appearance/theme section SHALL NOT contain a second full language picker once the dedicated language entry exists.

#### Scenario: Single language control path

- **WHEN** the user wants to change language
- **THEN** they use the dedicated language settings entry, not a duplicate control under appearance
