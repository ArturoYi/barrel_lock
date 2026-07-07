import 'package:flutter/widgets.dart';

import '../domain/flat/flat_lifecycle_mapper.dart';
import '../domain/flat/flat_lifecycle_phase.dart';
import '../domain/raw_lifecycle_event.dart';
import 'lifecycle_listener_binding.dart';

/// 抹平版生命周期 Mixin，与 [WidgetsBindingObserver.didChangeAppLifecycleState] 四态对齐。
///
/// 回调命名与 [AppLifecycleState] 一一对应：
/// - [onFlatDetached] ≈ `AppLifecycleState.detached`
/// - [onFlatInactive] ≈ `AppLifecycleState.inactive`
/// - [onFlatResumed]  ≈ `AppLifecycleState.resumed`
/// - [onFlatPaused]   ≈ `AppLifecycleState.paused`
///
/// Web 等不完整平台通过 [FlatLifecycleMapper] 复合推导（可见性 + 焦点 + Page Lifecycle）补齐。
mixin FlatLifecycleMixin on LifecycleListenerBinding {
  FlatLifecyclePhase _flatPhase = FlatLifecyclePhase.unknown;
  FlatLifecycleMapperState _mapperState = FlatLifecycleMapperState.empty;

  /// 当前抹平相位（对齐 [AppLifecycleState]）。
  FlatLifecyclePhase get flatLifecyclePhase => _flatPhase;

  /// 转为 Flutter [AppLifecycleState]；[FlatLifecyclePhase.unknown] 时返回 null。
  AppLifecycleState? get appLifecycleState => _flatPhase.toAppLifecycleState;

  bool get isFlatResumed => _flatPhase == FlatLifecyclePhase.resumed;

  bool get isFlatPaused => _flatPhase == FlatLifecyclePhase.paused;

  bool get isFlatInactive => _flatPhase == FlatLifecyclePhase.inactive;

  bool get isFlatDetached => _flatPhase == FlatLifecyclePhase.detached;

  bool get isFlatInBackground => _flatPhase == FlatLifecyclePhase.paused;

  @override
  void onPlatformLifecycleEvent(RawLifeCycleEvent event) {
    final previous = _flatPhase;
    _mapperState = FlatLifecycleMapper.apply(event, _mapperState);
    final next = _mapperState.lastPhase;

    if (next != previous) {
      _flatPhase = next;
      onFlatLifecyclePhaseChanged(previous, next, event);
      onAppLifecycleStateChanged(next, event);
      _dispatchFlatPhaseEntry(next, event);
    }

    super.onPlatformLifecycleEvent(event);
  }

  /// 相位变化时回调（含 [FlatLifecyclePhase.unknown] 离开时的首次变化）。
  void onFlatLifecyclePhaseChanged(
    FlatLifecyclePhase previous,
    FlatLifecyclePhase current,
    RawLifeCycleEvent event,
  ) {}

  /// 与 [WidgetsBindingObserver.didChangeAppLifecycleState] 等价的统一入口。
  void onAppLifecycleStateChanged(
    FlatLifecyclePhase state,
    RawLifeCycleEvent event,
  ) {}

  /// ≈ `AppLifecycleState.detached`
  void onFlatDetached(RawLifeCycleEvent event) {}

  /// ≈ `AppLifecycleState.inactive`
  void onFlatInactive(RawLifeCycleEvent event) {}

  /// ≈ `AppLifecycleState.resumed`
  void onFlatResumed(RawLifeCycleEvent event) {}

  /// ≈ `AppLifecycleState.paused`
  void onFlatPaused(RawLifeCycleEvent event) {}

  void _dispatchFlatPhaseEntry(
    FlatLifecyclePhase phase,
    RawLifeCycleEvent event,
  ) {
    switch (phase) {
      case FlatLifecyclePhase.detached:
        onFlatDetached(event);
      case FlatLifecyclePhase.inactive:
        onFlatInactive(event);
      case FlatLifecyclePhase.resumed:
        onFlatResumed(event);
      case FlatLifecyclePhase.paused:
        onFlatPaused(event);
      case FlatLifecyclePhase.unknown:
        break;
    }
  }
}
