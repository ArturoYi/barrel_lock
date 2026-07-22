import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 卡片内小标题（如「主题模式」「主题色」）。
class SettingsSubsectionTitle extends StatelessWidget {
  const SettingsSubsectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// 竖屏滚动列表中的分组标题（横屏 Master 仅展示 section 行，不再使用本组件）。
class SettingsSectionHeader extends StatelessWidget {
  const SettingsSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
      child: Text(
        title,
        style: context.textTheme.labelLarge?.copyWith(
          color: context.colors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 圆角卡片容器：统一分组内边距、描边，并在子项之间插入分隔线。
///
/// 分隔线 [indent] 与 ListTile leading（56dp）对齐，保持视觉连贯。
class SettingsSectionCard extends StatelessWidget {
  const SettingsSectionCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _intersperse(
          children,
          _SettingsDivider(colorScheme: colorScheme),
        ),
      ),
    );
  }

  static List<Widget> _intersperse(List<Widget> items, Widget separator) {
    if (items.isEmpty) {
      return const [];
    }
    return [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) separator,
        items[i],
      ],
    ];
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: colorScheme.outlineVariant.withValues(alpha: 0.45),
    );
  }
}
