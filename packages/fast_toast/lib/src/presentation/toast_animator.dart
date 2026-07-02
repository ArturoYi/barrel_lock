import 'package:flutter/material.dart';

import '../domain/toast_animation.dart';
import '../domain/toast_position.dart';

/// Toast 入出场动画容器。
class ToastAnimator extends StatelessWidget {
  const ToastAnimator({
    super.key,
    required this.animation,
    required this.opacity,
    this.slide,
    required this.child,
  });

  final ToastAnimation animation;
  final Animation<double> opacity;
  final Animation<Offset>? slide;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animated = FadeTransition(
      opacity: opacity,
      child: animation == ToastAnimation.fadeSlide && slide != null
          ? SlideTransition(position: slide!, child: child)
          : child,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: animated,
    );
  }
}

Offset slideBeginFor(ToastPosition position) {
  return switch (position.anchor) {
    ToastPositionAnchor.top => const Offset(0, -0.2),
    ToastPositionAnchor.center => const Offset(0, 0.1),
    ToastPositionAnchor.bottom => const Offset(0, 0.2),
  };
}
