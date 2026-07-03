import 'toast_animation.dart';
import 'toast_position.dart';
import 'toast_priority.dart';

/// 单条 Toast 的行为配置。
final class ToastConfig {
  const ToastConfig({
    this.duration = const Duration(milliseconds: 2000),
    this.position = ToastPosition.center,
    this.animation = ToastAnimation.fadeSlide,
    this.dismissible = false,
    this.bypassLoadingPause = false,
    this.priority = ToastPriority.normal,
  });

  final Duration duration;
  final ToastPosition position;
  final ToastAnimation animation;
  final bool dismissible;
  final bool bypassLoadingPause;
  final ToastPriority priority;
}
