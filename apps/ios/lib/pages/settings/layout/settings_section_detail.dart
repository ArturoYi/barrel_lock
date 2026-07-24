import 'package:barrel_lock/barrel_lock.dart';
import 'package:barrel_lock_ui/barrel_lock_ui.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../widgets/settings_list_tile.dart';
import '../widgets/settings_section_card.dart';

/// 根据 [SettingsSectionKind] 渲染 Detail 面板内容（横屏右侧 / 竖屏「外观」内联）。
///
/// - [SettingsSectionKind.theme]：内联主题控件，不跳转子页。
/// - 其余分组：按 [SettingsNavItemDescriptor.isReadOnly] 区分只读行与可导航项。
class SettingsSectionDetail extends StatelessWidget {
  const SettingsSectionDetail({
    super.key,
    required this.section,
    required this.versionLabel,
    required this.localePreference,
    required this.onNavItemTap,
  });

  final SettingsSectionDescriptor section;
  final String versionLabel;
  final AppLocalePreference localePreference;
  final ValueChanged<String> onNavItemTap;

  @override
  Widget build(BuildContext context) {
    if (section.kind == SettingsSectionKind.theme) {
      return const SettingsSectionCard(children: [ThemeSettingTile()]);
    }

    return SettingsSectionCard(
      children: [
        for (final item in section.items) _buildItemTile(context, item),
      ],
    );
  }

  Widget _buildItemTile(BuildContext context, SettingsNavItemDescriptor item) {
    final l10n = context.l10n;
    if (item.isReadOnly) {
      return SettingsInfoTile(
        title: l10n.settingsNavItemTitle(item.id),
        value: versionLabel,
        icon: item.icon,
      );
    }

    return SettingsNavTile(
      title: l10n.settingsNavItemTitle(item.id),
      subtitle: l10n.settingsNavItemSubtitle(
        item.id,
        localePreference: localePreference,
      ),
      icon: item.icon,
      isDanger: item.isDanger,
      onTap: () => onNavItemTap(item.id),
    );
  }
}
