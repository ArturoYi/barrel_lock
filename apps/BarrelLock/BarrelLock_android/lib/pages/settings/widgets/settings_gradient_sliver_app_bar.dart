import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'settings_gradient_background.dart';

/// 竖屏设置页顶部 [SliverAppBar]，渐变 + 可拉伸大标题。
class SettingsGradientSliverAppBar extends StatelessWidget {
  const SettingsGradientSliverAppBar({
    super.key,
    required this.title,
    this.expandedHeight = 148,
    this.compact = false,
  });

  final String title;
  final double expandedHeight;

  /// 预留：子页若需 Sliver 头部时可启用紧凑模式（当前仅横屏用 [SettingsCompactHeaderBar]）。
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    if (compact) {
      return SliverAppBar(
        pinned: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        flexibleSpace: SettingsGradientBackground(colorScheme: colorScheme),
        title: Text(title),
      );
    }

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      stretch: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
      centerTitle: true,
      title: Text(
        title,
        style: context.textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        centerTitle: true,
        background: SettingsGradientBackground(colorScheme: colorScheme),
      ),
    );
  }
}
