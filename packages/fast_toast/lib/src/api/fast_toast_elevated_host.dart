import 'package:flutter/material.dart';

import '../domain/toast_overlay_layer.dart';
import 'fast_toast_overlay.dart';

/// 在 [wrapped] 之上挂载 [ToastOverlayLayer.elevated] Toast host。
///
/// [wrapped] 子树内应已包含 normal 层 [FastToastOverlay]。
final class FastToastElevatedHost extends StatelessWidget {
  const FastToastElevatedHost({super.key, required this.wrapped});

  final Widget wrapped;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        wrapped,
        const FastToastOverlay(
          layer: ToastOverlayLayer.elevated,
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
