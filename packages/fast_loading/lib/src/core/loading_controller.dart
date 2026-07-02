import 'dart:async';

import 'package:flutter/material.dart';

import '../domain/loading_config.dart';
import '../domain/loading_dismiss_result.dart';
import '../domain/loading_display_phase.dart';
import 'loading_overlay_host.dart';

/// Loading 引用计数与 Overlay 生命周期 SSOT。
final class LoadingController extends ChangeNotifier {
  LoadingController._();

  static final LoadingController instance = LoadingController._();

  static const _defaultResultDisplayDuration = Duration(seconds: 1);

  final LoadingOverlayHost _host = LoadingOverlayHost();

  int _refCount = 0;
  LoadingConfig _config = const LoadingConfig();
  LoadingDisplayPhase _displayPhase = LoadingDisplayPhase.loading;
  Widget? _resultWidget;
  String? _resultMessage;
  Timer? _resultDismissTimer;

  /// 当前引用计数。
  int get refCount => _refCount;

  /// 是否正在展示 Loading。
  bool get isShowing => _refCount > 0 || _resultDismissTimer != null;

  /// 当前展示配置（只读）。
  LoadingConfig get config => _config;

  /// 当前展示阶段。
  LoadingDisplayPhase get displayPhase => _displayPhase;

  /// 当前结果态 Widget（success / error 阶段有效）。
  Widget? get resultWidget => _resultWidget;

  /// 当前结果态文案（success / error 阶段有效）。
  String? get resultMessage => _resultMessage;

  /// 注册根 Overlay；挂载后若已有 pending ref，立即插入 Entry。
  void attach(OverlayState overlayState) {
    _host.attach(overlayState);
    if (_refCount > 0 || _resultDismissTimer != null) {
      _host.show();
    }
  }

  /// 注销根 Overlay；移除 Entry 但保留 refCount，便于 remount 后恢复。
  void detach() {
    _host.detach();
  }

  /// 增加引用计数；首次展示时插入 OverlayEntry。
  void show({LoadingConfig? config}) {
    _cancelResultDismiss();

    if (config != null) {
      _config = config;
    }

    _refCount++;

    if (_refCount == 1) {
      _host.show();
    }

    notifyListeners();
  }

  /// 减少引用计数；归零后移除遮罩，或先展示结果态再关闭。
  void dismiss({
    LoadingDismissResult result = LoadingDismissResult.none,
    Widget? resultWidget,
    String? message,
    Duration resultDisplayDuration = _defaultResultDisplayDuration,
  }) {
    if (_refCount == 0) {
      return;
    }

    _refCount--;

    if (_refCount > 0) {
      return;
    }

    if (result != LoadingDismissResult.none) {
      _displayPhase = _toDisplayPhase(result);
      _resultWidget = _resolveResultWidget(result, resultWidget);
      _resultMessage = message;
      _host.show();
      notifyListeners();
      _resultDismissTimer = Timer(resultDisplayDuration, _finishResultDismiss);
      return;
    }

    _host.hide();
    notifyListeners();
  }

  /// 强制归零并移除 OverlayEntry。
  void dismissAll() {
    _refCount = 0;
    _cancelResultDismiss();
    _host.hide();
    notifyListeners();
  }

  /// 语法糖：执行异步任务，自动 show / dismiss。
  Future<T> run<T>(
    Future<T> Function() task, {
    LoadingConfig? config,
    String? message,
  }) async {
    show(
      config: config ?? (message != null ? LoadingConfig(message: message) : null),
    );
    try {
      return await task();
    } finally {
      dismiss();
    }
  }

  Widget? _resolveResultWidget(LoadingDismissResult result, Widget? override) {
    final style = _config.effectiveStyle;
    return switch (result) {
      LoadingDismissResult.none => null,
      LoadingDismissResult.success => override ?? style.successWidget,
      LoadingDismissResult.error => override ?? style.errorWidget,
    };
  }

  LoadingDisplayPhase _toDisplayPhase(LoadingDismissResult result) {
    return switch (result) {
      LoadingDismissResult.success => LoadingDisplayPhase.success,
      LoadingDismissResult.error => LoadingDisplayPhase.error,
      LoadingDismissResult.none => LoadingDisplayPhase.loading,
    };
  }

  void _finishResultDismiss() {
    _resultDismissTimer = null;
    _displayPhase = LoadingDisplayPhase.loading;
    _resultWidget = null;
    _resultMessage = null;
    _host.hide();
    notifyListeners();
  }

  void _cancelResultDismiss() {
    _resultDismissTimer?.cancel();
    _resultDismissTimer = null;
    _displayPhase = LoadingDisplayPhase.loading;
    _resultWidget = null;
    _resultMessage = null;
  }

  @visibleForTesting
  void resetForTest() {
    _refCount = 0;
    _config = const LoadingConfig();
    _cancelResultDismiss();
    _host.detach();
  }
}
