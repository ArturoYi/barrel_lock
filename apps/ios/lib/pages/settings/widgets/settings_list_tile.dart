import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 设置 ListTile 统一样式（间距、圆角、字色）。
///
/// [shell] 为 ListTile 包一层透明 [Material]，避免在 [SettingsSectionCard]
/// 等无 Material 祖先时出现 ink / 主题异常。
final class SettingsListTileStyle {
  const SettingsListTileStyle(this.context);

  final BuildContext context;

  static const contentPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 4,
  );

  factory SettingsListTileStyle.of(BuildContext context) {
    return SettingsListTileStyle(context);
  }

  ColorScheme get colors => context.colors;

  TextTheme get text => context.textTheme;

  ShapeBorder get shape =>
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

  TextStyle titleStyle({Color? color, FontWeight? fontWeight}) {
    return text.titleSmall?.copyWith(
          color: color ?? colors.onSurface,
          fontWeight: fontWeight ?? FontWeight.w500,
        ) ??
        TextStyle(
          color: color ?? colors.onSurface,
          fontWeight: fontWeight ?? FontWeight.w500,
        );
  }

  TextStyle subtitleStyle() {
    return text.bodySmall?.copyWith(color: colors.onSurfaceVariant) ??
        TextStyle(color: colors.onSurfaceVariant);
  }

  TextStyle trailingValueStyle() {
    return text.bodyMedium?.copyWith(color: colors.onSurfaceVariant) ??
        TextStyle(color: colors.onSurfaceVariant);
  }

  Color leadingIconColor({bool isDanger = false, bool selected = false}) {
    if (isDanger) {
      return colors.error;
    }
    if (selected) {
      return colors.primary;
    }
    return colors.onSurfaceVariant;
  }

  Color trailingIconColor() => colors.onSurfaceVariant;

  static Widget shell(Widget child) {
    return Material(color: Colors.transparent, child: child);
  }
}

/// 可点击导航的设置项（竖屏分组列表 / 横屏 Detail 面板共用）。
class SettingsNavTile extends StatelessWidget {
  const SettingsNavTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.selected = false,
    this.isDanger = false,
    this.enabled = true,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final bool selected;
  final bool isDanger;
  final bool enabled;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = SettingsListTileStyle.of(context);
    final titleColor = isDanger ? style.colors.error : style.colors.onSurface;

    return SettingsListTileStyle.shell(
      ListTile(
        contentPadding: SettingsListTileStyle.contentPadding,
        enabled: enabled,
        selected: selected,
        selectedTileColor: style.colors.primaryContainer.withValues(
          alpha: 0.35,
        ),
        shape: style.shape,
        leading: Icon(
          icon,
          color: style.leadingIconColor(isDanger: isDanger, selected: selected),
        ),
        title: Text(
          title,
          style: style.titleStyle(
            color: titleColor,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, style: style.subtitleStyle()),
        trailing:
            trailing ??
            (onTap == null || !enabled
                ? null
                : Icon(Icons.chevron_right, color: style.trailingIconColor())),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}

/// 只读信息行（版本号等），右侧展示值、无 chevron。
class SettingsInfoTile extends StatelessWidget {
  const SettingsInfoTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final style = SettingsListTileStyle.of(context);

    return SettingsListTileStyle.shell(
      ListTile(
        contentPadding: SettingsListTileStyle.contentPadding,
        shape: style.shape,
        leading: Icon(icon, color: style.leadingIconColor()),
        title: Text(title, style: style.titleStyle()),
        trailing: Text(value, style: style.trailingValueStyle()),
      ),
    );
  }
}

/// 开关类设置项（锁屏保护等子页使用）。
class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
    this.onChanged,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final style = SettingsListTileStyle.of(context);

    return SettingsListTileStyle.shell(
      SwitchListTile(
        contentPadding: SettingsListTileStyle.contentPadding,
        shape: style.shape,
        secondary: icon == null
            ? null
            : Icon(icon, color: style.leadingIconColor()),
        title: Text(title, style: style.titleStyle()),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, style: style.subtitleStyle()),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
