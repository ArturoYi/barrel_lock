import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../widgets/settings_gradient_background.dart';
import '../widgets/settings_list_tile.dart';
import 'settings_section_detail.dart';

/// 横屏：Master-Detail 分栏。
class SettingsLandscapeSplitView extends StatelessWidget {
  const SettingsLandscapeSplitView({
    super.key,
    required this.state,
    required this.onSectionSelected,
    required this.onNavItemTap,
  });

  final SettingsTabViewState state;
  final ValueChanged<SettingsSectionKind> onSectionSelected;
  final ValueChanged<String> onNavItemTap;

  static const _masterMinWidth = 280.0;
  static const _masterMaxWidth = 360.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected = state.sectionOf(state.selectedSection);

    return LayoutBuilder(
      builder: (context, constraints) {
        final masterWidth = (constraints.maxWidth * 0.36).clamp(
          _masterMinWidth,
          _masterMaxWidth,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsCompactHeaderBar(title: l10n.settings_title),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: masterWidth,
                    child: Material(
                      color: context.colors.surfaceContainerLowest,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
                        children: [
                          for (final section in state.sections)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: SettingsNavTile(
                                title: l10n.settingsSectionTitle(section.kind),
                                subtitle: _sectionSubtitle(
                                  context,
                                  section,
                                  state,
                                ),
                                icon: section.items.first.icon,
                                selected: state.selectedSection == section.kind,
                                onTap: () => onSectionSelected(section.kind),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: Material(
                      color: context.colors.surface,
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          Text(
                            l10n.settingsSectionTitle(selected.kind),
                            style: context.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.settingsSectionHint(selected.kind),
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: SettingsSectionDetail(
                              key: ValueKey(selected.kind),
                              section: selected,
                              versionLabel: state.versionLabel,
                              localePreference: state.localePreference,
                              onNavItemTap: onNavItemTap,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static String? _sectionSubtitle(
    BuildContext context,
    SettingsSectionDescriptor section,
    SettingsTabViewState state,
  ) {
    final l10n = context.l10n;
    if (section.items.length == 1) {
      return l10n.settingsNavItemSubtitle(
        section.items.first.id,
        localePreference: state.localePreference,
      );
    }
    return l10n.settings_sectionItemCount(section.items.length);
  }
}
