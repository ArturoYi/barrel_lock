import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'settings_section.dart';

/// 首页「设置」Tab 业务数据（MVVM-C 的 M 层）。
final class SettingsTabModel {
  const SettingsTabModel();

  String get versionLabel => AppDeviceInfo.versionLabel;

  List<SettingsSectionDescriptor> get sections => const [
    SettingsSectionDescriptor(
      kind: SettingsSectionKind.general,
      items: [
        SettingsNavItemDescriptor(
          id: 'language',
          icon: Icons.language_outlined,
        ),
      ],
    ),
    SettingsSectionDescriptor(
      kind: SettingsSectionKind.data,
      items: [
        SettingsNavItemDescriptor(
          id: 'data_migration',
          icon: Icons.swap_horiz_outlined,
        ),
      ],
    ),
    SettingsSectionDescriptor(
      kind: SettingsSectionKind.security,
      items: [
        SettingsNavItemDescriptor(id: 'app_lock', icon: Icons.shield_outlined),
        SettingsNavItemDescriptor(
          id: 'clear_data',
          icon: Icons.delete_forever_outlined,
          isDanger: true,
        ),
      ],
    ),
    SettingsSectionDescriptor(
      kind: SettingsSectionKind.support,
      items: [
        SettingsNavItemDescriptor(
          id: 'help_doc',
          icon: Icons.menu_book_outlined,
        ),
        SettingsNavItemDescriptor(
          id: 'feedback',
          icon: Icons.support_agent_outlined,
        ),
        SettingsNavItemDescriptor(
          id: 'user_agreement',
          icon: Icons.description_outlined,
        ),
        SettingsNavItemDescriptor(
          id: 'privacy_policy',
          icon: Icons.privacy_tip_outlined,
        ),
        SettingsNavItemDescriptor(
          id: 'encryption_doc',
          icon: Icons.enhanced_encryption_outlined,
        ),
      ],
    ),
    SettingsSectionDescriptor(
      kind: SettingsSectionKind.theme,
      items: [
        SettingsNavItemDescriptor(id: 'theme', icon: Icons.palette_outlined),
      ],
    ),
    SettingsSectionDescriptor(
      kind: SettingsSectionKind.about,
      items: [
        SettingsNavItemDescriptor(
          id: 'app_version',
          icon: Icons.info_outline,
          isReadOnly: true,
        ),
      ],
    ),
  ];
}

final settingsTabModelProvider = Provider<SettingsTabModel>(
  (_) => const SettingsTabModel(),
);
