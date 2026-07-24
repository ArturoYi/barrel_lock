import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../widgets/settings_gradient_sliver_app_bar.dart';
import '../widgets/settings_list_tile.dart';
import '../widgets/settings_section_card.dart';
import 'settings_section_detail.dart';

/// 竖屏：单列 [CustomScrollView]，分组标题 + 卡片纵向排列。
///
/// 「外观」分组直接内联 [SettingsSectionDetail]（主题控件），
/// 其余分组在卡片内列出可导航项 / 只读项。
class SettingsPortraitScrollView extends StatelessWidget {
  const SettingsPortraitScrollView({
    super.key,
    required this.state,
    required this.onNavItemTap,
  });

  final SettingsTabViewState state;
  final ValueChanged<String> onNavItemTap;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SettingsGradientSliverAppBar(title: context.l10n.settings_title),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildSection(context, state.sections[index]),
              childCount: state.sections.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    SettingsSectionDescriptor section,
  ) {
    if (section.kind == SettingsSectionKind.theme) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsSectionHeader(
            title: context.l10n.settingsSectionTitle(section.kind),
          ),
          SettingsSectionDetail(
            section: section,
            versionLabel: state.versionLabel,
            localePreference: state.localePreference,
            onNavItemTap: onNavItemTap,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(
          title: context.l10n.settingsSectionTitle(section.kind),
        ),
        SettingsSectionCard(
          children: [
            for (final item in section.items) _buildItemTile(context, item),
          ],
        ),
      ],
    );
  }

  Widget _buildItemTile(BuildContext context, SettingsNavItemDescriptor item) {
    final l10n = context.l10n;
    if (item.isReadOnly) {
      return SettingsInfoTile(
        title: l10n.settingsNavItemTitle(item.id),
        value: state.versionLabel,
        icon: item.icon,
      );
    }

    return SettingsNavTile(
      title: l10n.settingsNavItemTitle(item.id),
      subtitle: l10n.settingsNavItemSubtitle(
        item.id,
        localePreference: state.localePreference,
      ),
      icon: item.icon,
      isDanger: item.isDanger,
      onTap: () => onNavItemTap(item.id),
    );
  }
}
