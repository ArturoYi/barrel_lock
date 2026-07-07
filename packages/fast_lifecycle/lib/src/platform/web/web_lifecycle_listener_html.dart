// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

import '../../adapter/lifecycle_event_callback.dart';
import '../../domain/life_platform_source.dart';
import '../../domain/lifecycle_event_extra.dart';
import '../../domain/lifecycle_scope.dart';
import '../../domain/raw_lifecycle_event.dart';
import '../../domain/states/web_app_lifecycle_state.dart';
import '../../internal/lifecycle_init_options.dart';

/// Web 浏览器原生事件监听（架构第 ③ 层 Web 实现）。
///
/// ## Page Lifecycle 补充（对齐 WidgetsBindingObserver 四态）
/// 除 visibility / focus 外，额外监听：
/// - `pagehide` / `pageshow`（BFCache 场景）
/// - `freeze` / `resume`（Page Lifecycle API）
/// - `beforeunload`（页面卸载 → detached）
///
/// attach 时会根据当前 `document.hidden` / `hasFocus()` 推送初始状态，
/// 避免业务层错过首屏 resumed/inactive。
final class WebLifecycleListener {
  WebLifecycleListener({required this.options});

  final LifeCycleInitOptions options;

  final List<StreamSubscription<html.Event>> _subscriptions = [];
  LifeCycleEventCallback? _onEvent;

  Future<void> attach(LifeCycleEventCallback onEvent) async {
    _onEvent = onEvent;

    _subscriptions
      ..add(html.document.onVisibilityChange.listen(_onVisibilityChange))
      ..add(
        html.window.onFocus.listen(
          (_) => _emit(WebAppLifecycleState.windowFocus),
        ),
      )
      ..add(
        html.window.onBlur.listen(
          (_) => _emit(WebAppLifecycleState.windowBlur),
        ),
      )
      ..add(
        html.window.onPageHide.listen((html.Event event) {
          if (event is html.PageTransitionEvent) {
            _onPageHide(event);
          }
        }),
      )
      ..add(
        html.window.onPageShow.listen(
          (_) => _emit(WebAppLifecycleState.pageShow),
        ),
      )
      ..add(
        html.window.onBeforeUnload.listen(
          (_) => _emit(WebAppLifecycleState.beforeUnload),
        ),
      );

    _listenPageLifecycleApi();
    _emitInitialState();
  }

  Future<void> detach() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    _removePageLifecycleApi();
    _onEvent = null;
  }

  dynamic _freezeListener;
  dynamic _resumeListener;

  void _listenPageLifecycleApi() {
    try {
      final window = html.window as dynamic;
      _freezeListener = (html.Event _) =>
          _emit(WebAppLifecycleState.pageFreeze);
      _resumeListener = (html.Event _) =>
          _emit(WebAppLifecycleState.pageResume);
      window.addEventListener('freeze', _freezeListener);
      window.addEventListener('resume', _resumeListener);
    } on Object {
      _freezeListener = null;
      _resumeListener = null;
    }
  }

  void _removePageLifecycleApi() {
    if (_freezeListener == null && _resumeListener == null) return;
    try {
      final window = html.window as dynamic;
      if (_freezeListener != null) {
        window.removeEventListener('freeze', _freezeListener);
      }
      if (_resumeListener != null) {
        window.removeEventListener('resume', _resumeListener);
      }
    } on Object {
      // 忽略清理失败。
    }
    _freezeListener = null;
    _resumeListener = null;
  }

  void _emitInitialState() {
    final hidden = html.document.hidden ?? false;
    if (hidden) {
      _emit(WebAppLifecycleState.visibilityChangeHidden);
      return;
    }

    _emit(WebAppLifecycleState.visibilityChangeVisible);
    if (_documentHasFocus()) {
      _emit(WebAppLifecycleState.windowFocus);
    } else {
      _emit(WebAppLifecycleState.windowBlur);
    }
  }

  bool _documentHasFocus() {
    try {
      return (html.document as dynamic).hasFocus() as bool;
    } on Object {
      return true;
    }
  }

  void _onVisibilityChange(html.Event _) {
    final hidden = html.document.hidden ?? false;
    _emit(
      hidden
          ? WebAppLifecycleState.visibilityChangeHidden
          : WebAppLifecycleState.visibilityChangeVisible,
    );
  }

  void _onPageHide(html.PageTransitionEvent event) {
    _onEvent?.call(
      RawLifeCycleEvent(
        source: LifePlatformSource.web,
        rawState: WebAppLifecycleState.pageHide,
        extra: LifeCycleEventExtra(
          windowId: options.windowId,
          isMainWindow: options.isMainWindow,
          lifecycleScope: LifecycleScope.browser,
          metadata: {'persisted': event.persisted},
        ),
      ),
    );
  }

  void _emit(String rawState) {
    _onEvent?.call(
      RawLifeCycleEvent(
        source: LifePlatformSource.web,
        rawState: rawState,
        extra: LifeCycleEventExtra(
          windowId: options.windowId,
          isMainWindow: options.isMainWindow,
          lifecycleScope: LifecycleScope.browser,
        ),
      ),
    );
  }
}
