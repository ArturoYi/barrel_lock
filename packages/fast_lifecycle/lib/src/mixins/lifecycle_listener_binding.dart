import '../adapter/lifecycle_event_callback.dart';
import '../domain/raw_lifecycle_event.dart';
import '../manager/raw_lifecycle_manager.dart';

/// 将当前对象注册到 [RawLifeCycleManager] 的基础 Mixin。
///
/// 平台 Mixin 应 `on LifecycleListenerBinding`，在 [onPlatformLifecycleEvent]
/// 中处理本端事件后调用 `super.onPlatformLifecycleEvent(event)` 传递给链上其他 Mixin。
///
/// ```dart
/// class AppLockHandler
///     with LifecycleListenerBinding, IosAppLifecycleMixin {
///   void start() => bindPlatformLifecycle();
///
///   @override
///   void onApplicationDidEnterBackground(RawLifeCycleEvent event) {
///     // 进入后台锁定
///   }
/// }
/// ```
mixin LifecycleListenerBinding {
  LifeCycleEventCallback? _platformLifecycleCallback;

  /// 是否已注册到 [RawLifeCycleManager]。
  bool get isPlatformLifecycleBound => _platformLifecycleCallback != null;

  /// 注册生命周期监听；需在 [RawLifeCycleManager.initialize] 之后调用。
  void bindPlatformLifecycle([RawLifeCycleManager? manager]) {
    final target = manager ?? RawLifeCycleManager.instance;
    _platformLifecycleCallback ??= onPlatformLifecycleEvent;
    target.addListener(_platformLifecycleCallback!);
  }

  /// 从 [RawLifeCycleManager] 移除监听。
  void unbindPlatformLifecycle([RawLifeCycleManager? manager]) {
    final target = manager ?? RawLifeCycleManager.instance;
    final callback = _platformLifecycleCallback;
    if (callback != null) {
      target.removeListener(callback);
    }
  }

  /// 平台 Mixin 覆盖此方法并链式调用 `super`。
  void onPlatformLifecycleEvent(RawLifeCycleEvent event) {}
}
