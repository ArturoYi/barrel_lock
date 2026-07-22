import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/material.dart';

import '../widgets/settings_list_tile.dart';
import '../widgets/settings_section_card.dart';
import '../widgets/theme_setting_tile.dart';

/// 根据 [SettingsSectionKind] 渲染 Detail 面板内容（横屏右侧 / 竖屏「外观」内联）。
///
/// - [SettingsSectionKind.theme]：内联主题控件，不跳转子页。
/// - 其余分组：按 [SettingsNavItemDescriptor.isReadOnly] 区分只读行与可导航项。
class SettingsSectionDetail extends StatelessWidget {
  const SettingsSectionDetail({
    super.key,
    required this.section,
    required this.versionLabel,
    required this.onNavItemTap,
  });

  final SettingsSectionDescriptor section;
  final String versionLabel;
  final ValueChanged<String> onNavItemTap;

  @override
  Widget build(BuildContext context) {
    if (section.kind == SettingsSectionKind.theme) {
      return const SettingsSectionCard(children: [ThemeSettingTile()]);
    }

    return SettingsSectionCard(
      children: [for (final item in section.items) _buildItemTile(item)],
    );
  }

  Widget _buildItemTile(SettingsNavItemDescriptor item) {
    if (item.isReadOnly) {
      return SettingsInfoTile(
        title: item.title,
        value: versionLabel,
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
