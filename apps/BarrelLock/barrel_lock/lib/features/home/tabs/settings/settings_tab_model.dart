import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'settings_section.dart';

/// 首页「设置」Tab 业务数据（MVVM-C 的 M 层）。
final class SettingsTabModel {
  const SettingsTabModel();

  String get title => '设置';

  String get versionLabel => AppDeviceInfo.versionLabel;

  List<SettingsSectionDescriptor> get sections => const [
    SettingsSectionDescriptor(
      kind: SettingsSectionKind.data,
      title: '数据',
      items: [
        SettingsNavItemDescriptor(
          id: 'data_migration',
          title: '数据迁移',
          subtitle: '导出、导入、蓝牙共享、备份恢复',
          icon: Icons.swap_horiz_outlined,
        ),
      ],
    ),
    SettingsSectionDescriptor(
      kind: SettingsSectionKind.security,
      title: '安全',
      items: [
        SettingsNavItemDescriptor(
          id: 'app_lock',
          title: '锁屏保护',
          subtitle: '后台生物验证与备用密码',
          icon: Icons.shield_outlined,
        ),
        SettingsNavItemDescriptor(
          id: 'clear_data',
          title: '清除所有内容',
          subtitle: '删除全部密码，不可恢复',
          icon: Icons.delete_forever_outlined,
          isDanger: true,
        ),
      ],
    ),
    SettingsSectionDescriptor(
      kind: SettingsSectionKind.support,
      title: '服务支持',
      items: [
        SettingsNavItemDescriptor(
          id: 'help_doc',
          title: '安全帮助文档',
          icon: Icons.menu_book_outlined,
        ),
        SettingsNavItemDescriptor(
          id: 'feedback',
          title: '客服反馈',
          icon: Icons.support_agent_outlined,
        ),
        SettingsNavItemDescriptor(
          id: 'user_agreement',
          title: '用户协议',
          icon: Icons.description_outlined,
        ),
        SettingsNavItemDescriptor(
          id: 'privacy_policy',
          title: '隐私政策',
          icon: Icons.privacy_tip_outlined,
        ),
        SettingsNavItemDescriptor(
          id: 'encryption_doc',
          title: '加密说明',
          icon: Icons.enhanced_encryption_outlined,
        ),
      ],
    ),
    SettingsSectionDescriptor(
      kind: SettingsSectionKind.theme,
      title: '外观',
      items: [
        SettingsNavItemDescriptor(
          id: 'theme',
          title: '主题与显示',
          subtitle: '深色模式、主题色、字体大小',
          icon: Icons.palette_outlined,
        ),
      ],
    ),
    SettingsSectionDescriptor(
      kind: SettingsSectionKind.about,
      title: '关于',
      items: [
        SettingsNavItemDescriptor(
          id: 'app_version',
          title: '版本信息',
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
