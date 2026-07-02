import 'toast_config.dart';
import 'toast_style.dart';
import 'toast_type.dart';

/// 入队待展示的 Toast 请求（不可变）。
final class ToastRequest {
  const ToastRequest({
    required this.message,
    this.type = ToastType.custom,
    this.config = const ToastConfig(),
    this.style,
  });

  final String message;
  final ToastType type;
  final ToastConfig config;
  final ToastStyle? style;

  ToastStyle resolveStyle() => style ?? ToastStyle.forType(type);
}
