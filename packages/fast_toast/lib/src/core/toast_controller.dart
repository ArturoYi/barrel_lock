import 'package:flutter/material.dart';

import '../domain/toast_config.dart';
import '../domain/toast_overlay_layer.dart';
import '../domain/toast_overlay_layer_resolver.dart';
import '../domain/toast_priority.dart';
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

  /// 可选：App 按运行时上下文覆盖 overlay 层级（如锁屏期间自动 elevated）。
  static ToastOverlayLayerResolver? overlayLayerResolver;

  final ToastQueue _queue = ToastQueue();
  final ToastOverlayHost _normalHost = ToastOverlayHost();
  final ToastOverlayHost _elevatedHost = ToastOverlayHost();

  ToastRequest? _current;
  bool _isShowing = false;

  ToastOverlayHost _hostFor(ToastOverlayLayer layer) => switch (layer) {
    ToastOverlayLayer.normal => _normalHost,
    ToastOverlayLayer.elevated => _elevatedHost,
  };

  /// 是否正在展示 Toast。
  bool get isShowing => _isShowing;

  /// 待展示队列长度（不含当前条）。
  int get pendingCount => _queue.length;

  /// 队列总长度（含当前条）。
  int get totalCount => _queue.length + (_current == null ? 0 : 1);

  ToastRequest? get current => _current;

  @visibleForTesting
  ToastRequest? get pendingRequest => _queue.first;

  /// 注册根 Overlay；若队列有 pending 请求则尝试展示。
  void attach(
    OverlayState overlayState, {
    ToastOverlayLayer layer = ToastOverlayLayer.normal,
  }) {
    _hostFor(layer).attach(overlayState);
    _tryShowNext();
  }

  /// 注销根 Overlay；立即移除该层 Entry，保留队列。
  void detach({ToastOverlayLayer layer = ToastOverlayLayer.normal}) {
    final host = _hostFor(layer);
    if (_isShowing && _current?.config.overlayLayer == layer) {
      host.removeImmediately();
      _current = null;
      _isShowing = false;
    }
    host.detach();
    notifyListeners();
  }

  /// 投递 Toast 请求并入队。
  void enqueue({
    required String message,
    ToastType type = ToastType.custom,
    ToastConfig? config,
    ToastStyle? style,
  }) {
    final request = ToastRequest(
      message: message,
      type: type,
      config: _resolveOverlayLayer(
        config: config ?? const ToastConfig(),
        message: message,
        type: type,
        style: style,
      ),
      style: style,
    );

    if (request.config.priority == ToastPriority.high) {
      _enqueueHighPriority(request);
      return;
    }

    _queue.enqueue(request);
    _tryShowNext();
  }

  ToastConfig _resolveOverlayLayer({
    required ToastConfig config,
    required String message,
    required ToastType type,
    ToastStyle? style,
  }) {
    if (config.overlayLayer != ToastOverlayLayer.normal) {
      return config;
    }
    final resolver = overlayLayerResolver;
    if (resolver == null) {
      return config;
    }
    final resolved = resolver(
      ToastRequest(message: message, type: type, config: config, style: style),
    );
    if (resolved == null || resolved == ToastOverlayLayer.normal) {
      return config;
    }
    return ToastConfig(
      duration: config.duration,
      position: config.position,
      animation: config.animation,
      dismissible: config.dismissible,
      bypassLoadingPause: config.bypassLoadingPause,
      priority: config.priority,
      overlayLayer: resolved,
    );
  }

  /// 高优：立即移除当前 Toast，插队队首并马上展示；其余 pending 保留。
  void _enqueueHighPriority(ToastRequest request) {
    if (_isShowing && _current != null) {
      _hostFor(_current!.config.overlayLayer).removeImmediately();
      _current = null;
      _isShowing = false;
    }
    _queue.enqueueFront(request);
    _tryShowNext();
    notifyListeners();
  }

  /// 手动关闭当前 Toast；退场结束后自动 dequeue 下一条。
  void dismiss() {
    if (!_isShowing || _current == null) {
      return;
    }
    _hostFor(_current!.config.overlayLayer).dismissCurrent();
  }

  /// 清空队列并立即移除当前 Toast。
  void dismissAll() {
    _queue.clear();
    _normalHost.removeImmediately();
    _elevatedHost.removeImmediately();
    _current = null;
    _isShowing = false;
    notifyListeners();
  }

  /// Loading 关闭后由 App 调用，继续 dequeue。
  void resumeQueue() {
    _tryShowNext();
  }

  void _tryShowNext() {
    if (_isShowing || _queue.isEmpty) {
      return;
    }

    final next = _queue.first;
    if (next == null || _shouldPauseForLoading(next.config)) {
      return;
    }

    final host = _hostFor(next.config.overlayLayer);
    if (host.overlayState == null) {
      return;
    }

    _queue.dequeue();
    _current = next;
    _isShowing = true;
    host.show(request: next, onDismissed: _onCurrentDismissed);
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
    _normalHost.detach();
    _elevatedHost.detach();
    _current = null;
    _isShowing = false;
    loadingPauseCheck = null;
    overlayLayerResolver = null;
  }
}
