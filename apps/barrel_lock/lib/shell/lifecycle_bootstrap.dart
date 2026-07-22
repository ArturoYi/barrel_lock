import 'package:fast_lifecycle/fast_lifecycle.dart';

/// BarrelLock 全平台生命周期引导（在 [ThemedApp] 启动时调用）。
///
/// 初始化 [RawLifeCycleManager] 并启用 [LifecycleStateStore] 全局快照，
/// 供 App Lock 等业务通过 [currentFlatLifecyclePhase] / 平台 Mixin 使用。
Future<void> bootstrapBarrelLockLifecycle({
  LifeCycleInitOptions options = const LifeCycleInitOptions(),
}) async {
  await RawLifeCycleManager.instance.initialize(options: options);
  attachLifecycleStateTracking();
}

/// 释放生命周期监听（在 [ThemedApp] dispose 时调用）。
Future<void> disposeBarrelLockLifecycle() async {
  detachLifecycleStateTracking();
  await RawLifeCycleManager.instance.dispose();
}
