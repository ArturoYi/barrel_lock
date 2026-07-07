import '../domain/flat/flat_lifecycle_phase.dart';
import '../domain/flat/platform_lifecycle_snapshot.dart';
import '../manager/raw_lifecycle_manager.dart';
import 'lifecycle_state_store.dart';

/// 差异版：读取当前平台原生生命周期快照。
PlatformLifecycleSnapshot get currentPlatformLifecycle =>
    LifecycleStateStore.instance.platform;

/// 抹平版：读取当前跨平台生命周期相位。
FlatLifecyclePhase get currentFlatLifecyclePhase =>
    LifecycleStateStore.instance.flat.phase;

/// 启用全局生命周期状态追踪（需在 [RawLifeCycleManager.initialize] 之后）。
void attachLifecycleStateTracking([RawLifeCycleManager? manager]) {
  LifecycleStateStore.instance.attach(manager);
}

/// 停用全局生命周期状态追踪。
void detachLifecycleStateTracking([RawLifeCycleManager? manager]) {
  LifecycleStateStore.instance.detach(manager);
}

/// [RawLifeCycleManager] 状态读取扩展。
extension LifecycleStateReader on RawLifeCycleManager {
  /// 差异版快照。
  PlatformLifecycleSnapshot get platformLifecycle =>
      LifecycleStateStore.instance.platform;

  /// 抹平版相位。
  FlatLifecyclePhase get flatLifecyclePhase =>
      LifecycleStateStore.instance.flat.phase;

  /// 绑定全局 [LifecycleStateStore]。
  void attachLifecycleStateStore([LifecycleStateStore? store]) {
    (store ?? LifecycleStateStore.instance).attach(this);
  }

  void detachLifecycleStateStore([LifecycleStateStore? store]) {
    (store ?? LifecycleStateStore.instance).detach(this);
  }
}
