import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

import '../widgets/settings_gradient_background.dart';
import '../widgets/settings_list_tile.dart';
import 'settings_section_detail.dart';

/// 横屏：Master-Detail 分栏。
///
/// **Master（左栏）** 仅展示 [SettingsSectionKind] 一级分组，点击切换右侧 Detail。
/// 具体设置项只在 Detail 中呈现并响应 [onNavItemTap]，避免与竖屏「一步直达」行为不一致。
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
            SettingsCompactHeaderBar(title: state.title),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: masterWidth,
                    child: Material(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLowest,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
                        children: [
                          for (final section in state.sections)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: SettingsNavTile(
                                title: section.title,
                                subtitle: _sectionSubtitle(section),
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
                      color: Theme.of(context).colorScheme.surface,
                      child: ListView(
                        padding: const EdgeInsets.all(24),
                        children: [
                          Text(
                            selected.title,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _detailHint(selected.kind),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 24),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: SettingsSectionDetail(
                              key: ValueKey(selected.kind),
                              section: selected,
                              versionLabel: state.versionLabel,
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

  /// Master 行副标题：单项分组用 item 副标题，多项分组显示条目数。
  static String? _sectionSubtitle(SettingsSectionDescriptor section) {
    if (section.items.length == 1) {
      return section.items.first.subtitle;
    }
    return '${section.items.length} 项';
  }

  static String _detailHint(SettingsSectionKind kind) {
    return switch (kind) {
      SettingsSectionKind.theme => '调整应用外观与可读性。',
      SettingsSectionKind.data => '导入导出与备份相关操作将在此展开。',
      SettingsSectionKind.security => '锁屏保护与危险操作需二次确认。',
      SettingsSectionKind.support => '帮助文档与法律条款外链入口。',
      SettingsSectionKind.about => '应用版本与构建信息。',
    };
  }
}
