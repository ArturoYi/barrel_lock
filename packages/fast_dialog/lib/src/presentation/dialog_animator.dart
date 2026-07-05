import 'package:flutter/material.dart';

import '../domain/dialog_animation.dart';

/// 统一动画工厂：将 [DialogAnimationSpec] 映射为 Flutter Transition Widget。
abstract final class DialogAnimator {
  /// 根据动画类型决定内容面板的对齐方式（底部滑入 → 底部对齐）。
  static Alignment alignmentFor(DialogAnimationType type) {
    return switch (type) {
      DialogAnimationType.slideFromBottom => Alignment.bottomCenter,
      DialogAnimationType.slideFromTop => Alignment.topCenter,
      _ => Alignment.center,
    };
  }

  static Widget wrap({
    required Widget child,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required DialogAnimationSpec spec,
  }) {
    final builder = spec.builder;
    if (builder != null) {
      return builder(child, animation, secondaryAnimation);
    }

    final curved = CurvedAnimation(parent: animation, curve: spec.curve);

    return switch (spec.type) {
      DialogAnimationType.fade => FadeTransition(
        opacity: animation,
        child: child,
      ),
      DialogAnimationType.scale => ScaleTransition(scale: curved, child: child),
      DialogAnimationType.slideFromBottom => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
      DialogAnimationType.slideFromTop => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
      DialogAnimationType.centerPop => ScaleTransition(
        scale: Tween<double>(begin: 0.85, end: 1).animate(curved),
        child: FadeTransition(opacity: animation, child: child),
      ),
    };
  }
}
