import '../adapter/lifecycle_event_callback.dart';
import '../domain/flat/flat_lifecycle_mapper.dart';
import '../domain/flat/flat_lifecycle_phase.dart';
import '../domain/flat/flat_lifecycle_snapshot.dart';
import '../domain/flat/platform_lifecycle_snapshot.dart';
import '../domain/raw_lifecycle_event.dart';
import '../manager/raw_lifecycle_manager.dart';

/// 全局生命周期状态仓库（差异版 + 抹平版快照）。
///
/// 在 [RawLifeCycleManager.initialize] 之后调用 [attach] 即可通过
/// [platform] / [flat] 或顶层 [currentPlatformLifecycle] 快捷读取。
final class LifecycleStateStore {
  LifecycleStateStore._();

  static final LifecycleStateStore instance = LifecycleStateStore._();

  PlatformLifecycleSnapshot _platform = PlatformLifecycleSnapshot.empty;
  FlatLifecycleSnapshot _flat = FlatLifecycleSnapshot.empty;
  FlatLifecycleMapperState _mapperState = FlatLifecycleMapperState.empty;

  LifeCycleEventCallback? _callback;
  bool _attached = false;

  /// 差异版：最近一次原生快照。
  PlatformLifecycleSnapshot get platform => _platform;

  /// 抹平版：最近一次跨平台相位。
  FlatLifecycleSnapshot get flat => _flat;

  /// 快捷：当前抹平相位。
  FlatLifecyclePhase get flatPhase => _flat.phase;

  /// 快捷：当前原生 rawState。
  String? get platformRawState => _platform.rawState;

  /// 快捷：当前原生 lifecycleScope。
  String? get platformLifecycleScope => _platform.lifecycleScope;

  bool get isAttached => _attached;

  /// 订阅 [RawLifeCycleManager] 并持续更新快照。
  void attach([RawLifeCycleManager? manager]) {
    if (_attached) return;
    final target = manager ?? RawLifeCycleManager.instance;
    _callback ??= _onEvent;
    target.addListener(_callback!);
    _attached = true;
  }

  /// 取消订阅（不重置快照）。
  void detach([RawLifeCycleManager? manager]) {
    if (!_attached) return;
    final target = manager ?? RawLifeCycleManager.instance;
    final callback = _callback;
    if (callback != null) {
      target.removeListener(callback);
    }
    _attached = false;
  }

  /// 重置快照与映射器状态（供单测）。
  void reset() {
    _platform = PlatformLifecycleSnapshot.empty;
    _flat = FlatLifecycleSnapshot.empty;
    _mapperState = FlatLifecycleMapperState.empty;
  }

  void _onEvent(RawLifeCycleEvent event) {
    _platform = PlatformLifecycleSnapshot.from(event);
    _mapperState = FlatLifecycleMapper.apply(event, _mapperState);
    _flat = FlatLifecycleSnapshot(
      phase: _mapperState.lastPhase,
      lastEvent: event,
      updatedAt: DateTime.now(),
    );
  }
}
