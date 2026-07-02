import 'package:flutter/material.dart';

import '../domain/toast_config.dart';
import '../domain/toast_request.dart';
import '../domain/toast_style.dart';
import '../domain/toast_type.dart';
import 'toast_overlay_host.dart';
import 'toast_queue.dart';

/// Toast 队列调度与单槽展示 SSOT。
final class ToastController extends ChangeNotifier {
  ToastController._();

  static final ToastController instance = ToastController._();

  /// 可选：返回 true 时暂停 dequeue（供 App 注入 `FastLoading.isShowing`）。
  static bool Function()? loadingPauseCheck;

  final ToastQueue _queue = ToastQueue();
  final ToastOverlayHost _host = ToastOverlayHost();

  ToastRequest? _current;
  bool _isShowing = false;

  /// 是否正在展示 Toast。
  bool get isShowing => _isShowing;

  /// 待展示队列长度（不含当前条）。
  int get pendingCount => _queue.length;

  /// 队列总长度（含当前条）。
  int get totalCount => _queue.length + (_current == null ? 0 : 1);

  ToastRequest? get current => _current;

  /// 注册根 Overlay；若队列有 pending 请求则尝试展示。
  void attach(OverlayState overlayState) {
    _host.attach(overlayState);
    _tryShowNext();
  }

  /// 注销根 Overlay；立即移除 Entry，保留队列。
  void detach() {
    _host.removeImmediately();
    _current = null;
    _isShowing = false;
    notifyListeners();
  }

  /// 投递 Toast 请求并入队。
  void enqueue({
    required String message,
    ToastType type = ToastType.custom,
    ToastConfig? config,
    ToastStyle? style,
  }) {
    _queue.enqueue(
      ToastRequest(
        message: message,
        type: type,
        config: config ?? const ToastConfig(),
        style: style,
      ),
    );
    _tryShowNext();
  }

  /// 手动关闭当前 Toast；退场结束后自动 dequeue 下一条。
  void dismiss() {
    if (!_isShowing) {
      return;
    }
    _host.dismissCurrent();
  }

  /// 清空队列并立即移除当前 Toast。
  void dismissAll() {
    _queue.clear();
    _host.removeImmediately();
    _current = null;
    _isShowing = false;
    notifyListeners();
  }

  /// Loading 关闭后由 App 调用，继续 dequeue。
  void resumeQueue() {
    _tryShowNext();
  }

  void _tryShowNext() {
    if (_isShowing || _host.overlayState == null || _queue.isEmpty) {
      return;
    }

    final next = _queue.first;
    if (next == null || _shouldPauseForLoading(next.config)) {
      return;
    }

    _queue.dequeue();
    _current = next;
    _isShowing = true;
    _host.show(
      request: next,
      onDismissed: _onCurrentDismissed,
    );
    notifyListeners();
  }

  bool _shouldPauseForLoading(ToastConfig config) {
    if (config.bypassLoadingPause) {
      return false;
    }
    final check = loadingPauseCheck;
    return check != null && check();
  }

  void _onCurrentDismissed() {
    _current = null;
    _isShowing = false;
    notifyListeners();
    _tryShowNext();
  }

  @visibleForTesting
  void resetForTest() {
    _queue.clear();
    _host.detach();
    _current = null;
    _isShowing = false;
    loadingPauseCheck = null;
  }
}
