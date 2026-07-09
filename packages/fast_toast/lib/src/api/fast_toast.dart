import '../core/toast_controller.dart';
import '../domain/toast_config.dart';
import '../domain/toast_overlay_layer_resolver.dart';
import '../domain/toast_style.dart';
import '../domain/toast_type.dart';

/// 全局 Toast 门面，无需 [BuildContext]。
abstract final class FastToast {
  static ToastController get _controller => ToastController.instance;

  /// 是否正在展示 Toast。
  static bool get isShowing => _controller.isShowing;

  /// 待展示队列长度（不含当前条）。
  static int get pendingCount => _controller.pendingCount;

  /// 注入 Loading 暂停检查（例如 `() => FastLoading.isShowing`）。
  static set loadingPauseCheck(bool Function()? check) {
    ToastController.loadingPauseCheck = check;
  }

  /// 注入 Overlay 层级解析（例如锁屏期间自动 elevated）。
  static set overlayLayerResolver(ToastOverlayLayerResolver? resolver) {
    ToastController.overlayLayerResolver = resolver;
  }

  /// 展示 Toast。
  static void show(
    String message, {
    ToastType type = ToastType.custom,
    ToastConfig? config,
    ToastStyle? style,
  }) {
    _controller.enqueue(
      message: message,
      type: type,
      config: config,
      style: style,
    );
  }

  /// 成功 Toast。
  static void success(
    String message, {
    ToastConfig? config,
    ToastStyle? style,
  }) {
    show(message, type: ToastType.success, config: config, style: style);
  }

  /// 错误 Toast。
  static void error(String message, {ToastConfig? config, ToastStyle? style}) {
    show(message, type: ToastType.error, config: config, style: style);
  }

  /// 信息 Toast。
  static void info(String message, {ToastConfig? config, ToastStyle? style}) {
    show(message, type: ToastType.info, config: config, style: style);
  }

  /// 关闭当前 Toast。
  static void dismiss() {
    _controller.dismiss();
  }

  /// 清空队列并关闭当前 Toast。
  static void dismissAll() {
    _controller.dismissAll();
  }

  /// Loading 关闭后继续 dequeue。
  static void resume() {
    _controller.resumeQueue();
  }
}
