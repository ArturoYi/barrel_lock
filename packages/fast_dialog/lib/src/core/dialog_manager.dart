import 'dart:async';

import 'package:flutter/widgets.dart';

import '../domain/base_dialog.dart';
import '../domain/dialog_config.dart';
import '../domain/dialog_entry.dart';
import 'dialog_overlay_host.dart';

/// 全局弹窗栈 SSOT（Single Source of Truth）。
///
/// ## 核心数据结构
///
/// [_stack]：按 push 顺序维护的 [DialogEntry] 列表，栈顶 = 最后 show 的弹窗。
///
/// ## 关键语义
///
/// | 行为 | 说明 |
/// |------|------|
/// | 同 tag 去重 | 已有 tag 时刷新 builder/config，不新建 Entry |
/// | dismiss | 先播退场动画，再 complete Future、触发 onDismiss |
/// | dismissByRoute | 页面 pop 时清理绑定在该 routeIdentity 上的弹窗 |
/// | attach | Overlay 挂载后重放当前栈（热重启 / 路由 rebuild 场景） |
final class DialogManager extends ChangeNotifier {
  DialogManager._() {
    DialogManagerBridge.dismissById = (id) => dismiss(id: id);
  }

  static final DialogManager instance = DialogManager._();

  final DialogOverlayHost _host = DialogOverlayHost();
  final List<DialogEntry<dynamic>> _stack = [];

  /// 正在执行退场动画的 Entry id，防止重复 dismiss。
  final Set<String> _closingIds = {};

  DialogConfig _config = const DialogConfig();

  /// 当前页面路由标识，由 [DialogRouteObserver] 或 [bindRoute] 设置。
  Object? _currentRouteIdentity;

  int _idSeq = 0;

  /// 当前栈（只读副本）。
  List<DialogEntry<dynamic>> get stack => List.unmodifiable(_stack);

  /// 是否有弹窗在栈中（含正在退场的）。
  bool get isShowing => _stack.isNotEmpty;

  /// 全局配置。
  DialogConfig get config => _config;

  void configure(DialogConfig config) {
    _config = config;
  }

  /// 注册根 [OverlayState]；若栈非空则按 zIndex 顺序重放。
  void attach(OverlayState overlayState) {
    _host.attach(overlayState);
    final sorted = List<DialogEntry<dynamic>>.from(_stack)
      ..sort((a, b) => a.showConfig.zIndex.compareTo(b.showConfig.zIndex));
    for (final entry in sorted) {
      _host.present(entry, onDismiss: () => dismiss(id: entry.id));
    }
  }

  /// 注销 Overlay；不清空栈，便于 remount 后恢复。
  void detach() {
    _host.detach();
  }

  /// 绑定当前路由，后续 show 的弹窗将记录 [DialogEntry.routeIdentity]。
  void bindRoute(Object? routeIdentity) {
    _currentRouteIdentity = routeIdentity;
  }

  /// 展示弹窗；相同 [tag] 已存在时复用并刷新。
  Future<T?> show<T>({
    required WidgetBuilder builder,
    DialogShowConfig? showConfig,
    String? tag,
    BaseDialog<T>? dialog,
  }) {
    final effectiveConfig = _mergeConfig(showConfig ?? dialog?.showConfig);
    final effectiveTag = tag ?? dialog?.tag;

    if (effectiveTag != null) {
      final existing = _findByTag(effectiveTag);
      if (existing != null) {
        _refreshEntry(
          existing,
          builder: builder,
          showConfig: effectiveConfig,
          dialog: dialog,
        );
        return existing.completer.future as Future<T?>;
      }
    }

    final completer = Completer<T?>();
    final entry = DialogEntry<T>(
      id: _nextId(),
      tag: effectiveTag,
      builder: builder,
      showConfig: effectiveConfig,
      completer: completer,
      routeIdentity: _currentRouteIdentity,
      dialog: dialog,
    );

    _stack.add(entry);
    _host.present(entry, onDismiss: () => dismiss(id: entry.id));
    notifyListeners();

    return completer.future;
  }

  /// 展示 [BaseDialog] 实例。
  Future<T?> showDialog<T>(BaseDialog<T> dialog) {
    return show<T>(
      builder: dialog.build,
      showConfig: dialog.showConfig,
      tag: dialog.tag,
      dialog: dialog,
    );
  }

  /// 关闭栈顶，或通过 [id] / [tag] 指定弹窗。
  void dismiss({String? id, String? tag, dynamic result}) {
    DialogEntry<dynamic>? target;

    if (id != null) {
      target = _findById(id);
    } else if (tag != null) {
      target = _findByTag(tag);
    } else if (_stack.isNotEmpty) {
      target = _stack.last;
    }

    if (target == null || _closingIds.contains(target.id)) {
      return;
    }

    _beginClose(target, result: result);
  }

  /// 关闭全部弹窗。
  void dismissAll({dynamic result}) {
    final entries = List<DialogEntry<dynamic>>.from(_stack);
    for (final entry in entries) {
      if (!_closingIds.contains(entry.id)) {
        _beginClose(entry, result: result, notify: false);
      }
    }
    notifyListeners();
  }

  /// 路由销毁时，清理绑定在该页面上的所有弹窗。
  void dismissByRoute(Object? routeIdentity) {
    if (routeIdentity == null) {
      return;
    }
    final toRemove = _stack
        .where((e) => e.routeIdentity == routeIdentity)
        .toList(growable: false);
    for (final entry in toRemove) {
      if (!_closingIds.contains(entry.id)) {
        _beginClose(entry, notify: false);
      }
    }
    notifyListeners();
  }

  DialogEntry<dynamic>? _findById(String id) {
    for (final entry in _stack) {
      if (entry.id == id) {
        return entry;
      }
    }
    return null;
  }

  DialogEntry<dynamic>? _findByTag(String tag) {
    for (final entry in _stack) {
      if (entry.tag == tag) {
        return entry;
      }
    }
    return null;
  }

  void _refreshEntry(
    DialogEntry<dynamic> existing, {
    required WidgetBuilder builder,
    required DialogShowConfig showConfig,
    BaseDialog<dynamic>? dialog,
  }) {
    final index = _stack.indexOf(existing);
    if (index < 0) {
      return;
    }
    final updated = DialogEntry<dynamic>(
      id: existing.id,
      tag: existing.tag,
      builder: builder,
      showConfig: showConfig,
      completer: existing.completer,
      routeIdentity: existing.routeIdentity,
      dialog: dialog ?? existing.dialog,
    );
    _stack[index] = updated;
    _host.refresh(updated);
    notifyListeners();
  }

  /// 启动退场动画，动画结束后 complete Future 并从栈移除。
  void _beginClose(
    DialogEntry<dynamic> entry, {
    dynamic result,
    bool notify = true,
  }) {
    _closingIds.add(entry.id);

    _host.dismiss(
      entry.id,
      onComplete: () {
        _closingIds.remove(entry.id);
        if (!entry.isCompleted) {
          entry.completer.complete(result ?? entry.dialog?.result);
        }
        entry.showConfig.onDismiss?.call();
        _stack.remove(entry);
        if (notify) {
          notifyListeners();
        }
      },
    );
  }

  /// 将单次 [showConfig] 与全局 [DialogConfig.defaultShowConfig] 合并。
  DialogShowConfig _mergeConfig(DialogShowConfig? override) {
    final base = _config.defaultShowConfig;
    if (override == null) {
      return base;
    }
    return DialogShowConfig(
      mode: override.mode,
      mask: override.mask,
      maskDismissible: override.maskDismissible,
      animation: override.animation,
      ignoreSafeArea: override.ignoreSafeArea,
      usePenetrate: override.usePenetrate,
      zIndex: override.zIndex,
      enableDragDismiss: override.enableDragDismiss,
      dragDismissThreshold: override.dragDismissThreshold,
      scrollable: override.scrollable,
      onShow: override.onShow ?? base.onShow,
      onDismiss: override.onDismiss ?? base.onDismiss,
    );
  }

  String _nextId() {
    _idSeq += 1;
    return 'dialog_$_idSeq';
  }

  @visibleForTesting
  void resetForTest() {
    _closingIds.clear();
    for (final entry in List<DialogEntry<dynamic>>.from(_stack)) {
      if (!entry.isCompleted) {
        entry.completer.complete(null);
      }
    }
    _stack.clear();
    _config = const DialogConfig();
    _currentRouteIdentity = null;
    _idSeq = 0;
    _host.detach();
  }
}
