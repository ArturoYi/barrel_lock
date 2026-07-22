import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 设置页渐变背景（竖向）。
///
/// 供 [SettingsGradientSliverAppBar] 复用；横屏紧凑头部使用横向渐变，
/// 色值取自同一 [ColorScheme]，见 [SettingsCompactHeaderBar]。
class SettingsGradientBackground extends StatelessWidget {
  const SettingsGradientBackground({super.key, required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colorScheme.primary,
            ?Color.lerp(
              colorScheme.primary,
              colorScheme.primaryContainer,
              0.55,
            ),
            colorScheme.primaryContainer.withValues(alpha: 0.85),
            colorScheme.surface.withValues(alpha: 0.2),
          ],
          stops: const [0.0, 0.45, 0.78, 1.0],
        ),
      ),
    );
  }
}

/// 横屏 Master-Detail 顶栏：固定高度、横向渐变，避免占用过多垂直空间。
class SettingsCompactHeaderBar extends StatelessWidget {
  const SettingsCompactHeaderBar({
    super.key,
    required this.title,
    this.height = 64,
  });

  final String title;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [colorScheme.primary, colorScheme.primaryContainer],
          ),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
