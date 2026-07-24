import 'package:flutter/material.dart';

/// 设置页模块标识，横屏 Master-Detail 与竖屏分组共用。
enum SettingsSectionKind { general, theme, data, security, support, about }

/// 设置页分组描述（Hub VM 下发，View 只负责渲染）。
final class SettingsSectionDescriptor {
  const SettingsSectionDescriptor({required this.kind, required this.items});

  final SettingsSectionKind kind;
  final List<SettingsNavItemDescriptor> items;
}

/// 设置项描述。
final class SettingsNavItemDescriptor {
  const SettingsNavItemDescriptor({
    required this.id,
    required this.icon,
    this.isDanger = false,
    this.isReadOnly = false,
  });

  final String id;
  final IconData icon;

  /// 危险操作（如清除数据），UI 以 error 色强调。
  final bool isDanger;

  /// 只读信息行（如版本号），不可点击、不触发导航。
  final bool isReadOnly;
}
