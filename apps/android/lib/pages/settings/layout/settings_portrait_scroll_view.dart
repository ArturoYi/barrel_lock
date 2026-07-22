import 'package:barrel_lock/barrel_lock.dart';
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
        SettingsGradientSliverAppBar(title: state.title),
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
          SettingsSectionHeader(title: section.title),
          SettingsSectionDetail(
            section: section,
            versionLabel: state.versionLabel,
            onNavItemTap: onNavItemTap,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionHeader(title: section.title),
        SettingsSectionCard(
          children: [for (final item in section.items) _buildItemTile(item)],
        ),
      ],
    );
  }

  Widget _buildItemTile(SettingsNavItemDescriptor item) {
    if (item.isReadOnly) {
      return SettingsInfoTile(
        title: item.title,
        value: state.versionLabel,
        icon: item.icon,
      );
    }

    return SettingsNavTile(
      title: item.title,
      subtitle: item.subtitle,
      icon: item.icon,
      isDanger: item.isDanger,
      onTap: () => onNavItemTap(item.id),
    );
  }
}
