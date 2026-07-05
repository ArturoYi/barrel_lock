import 'package:flutter/widgets.dart';

/// 内置弹窗入场/退场动画类型。
enum DialogAnimationType {
  fade,
  scale,
  slideFromBottom,
  slideFromTop,
  centerPop,
}

/// 自定义动画构建器：完全接管 child 的入退场过渡。
typedef DialogAnimationBuilder =
    Widget Function(
      Widget child,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    );

/// 动画规格：选择内置 [type] 或通过 [DialogAnimationSpec.custom] 注入 builder。
final class DialogAnimationSpec {
  const DialogAnimationSpec({
    this.type = DialogAnimationType.fade,
    this.duration = const Duration(milliseconds: 250),
    this.reverseDuration,
    this.curve = Curves.easeOutCubic,
    this.builder,
  });

  const DialogAnimationSpec.custom({
    required this.builder,
    this.duration = const Duration(milliseconds: 250),
    this.reverseDuration,
  }) : type = DialogAnimationType.fade,
       curve = Curves.easeOutCubic;

  final DialogAnimationType type;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve curve;
  final DialogAnimationBuilder? builder;
}
