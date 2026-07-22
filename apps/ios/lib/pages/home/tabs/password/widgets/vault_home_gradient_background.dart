import 'package:flutter/material.dart';

/// 密码 Tab 顶部渐变背景，与设置页风格一致。
class VaultHomeGradientBackground extends StatelessWidget {
  const VaultHomeGradientBackground({super.key, required this.colorScheme});

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
            colorScheme.surface.withValues(alpha: 0.15),
          ],
          stops: const [0.0, 0.45, 0.78, 1.0],
        ),
      ),
    );
  }
}
