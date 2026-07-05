import 'dart:ui';

import 'package:flutter/material.dart';

import '../domain/dialog_mask.dart';

/// 全屏遮罩层：支持纯色 / 高斯模糊 / 无遮罩。
///
/// [dismissible] 为 true 时，点击遮罩触发 [onDismiss]。
final class DialogBarrier extends StatelessWidget {
  const DialogBarrier({
    super.key,
    required this.mask,
    required this.dismissible,
    this.onDismiss,
  });

  final DialogMask mask;
  final bool dismissible;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return switch (mask) {
      DialogMaskNone() => const SizedBox.shrink(),
      DialogMaskColor(:final color) => _ColorBarrier(
        color: color,
        dismissible: dismissible,
        onDismiss: onDismiss,
      ),
      DialogMaskBlur(:final sigma, :final tint) => _BlurBarrier(
        sigma: sigma,
        tint: tint,
        dismissible: dismissible,
        onDismiss: onDismiss,
      ),
    };
  }
}

class _ColorBarrier extends StatelessWidget {
  const _ColorBarrier({
    required this.color,
    required this.dismissible,
    this.onDismiss,
  });

  final Color color;
  final bool dismissible;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: dismissible ? onDismiss : null,
      behavior: HitTestBehavior.opaque,
      child: ColoredBox(color: color),
    );
  }
}

class _BlurBarrier extends StatelessWidget {
  const _BlurBarrier({
    required this.sigma,
    required this.tint,
    required this.dismissible,
    this.onDismiss,
  });

  final double sigma;
  final Color tint;
  final bool dismissible;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: dismissible ? onDismiss : null,
      behavior: HitTestBehavior.opaque,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: ColoredBox(color: tint),
      ),
    );
  }
}
