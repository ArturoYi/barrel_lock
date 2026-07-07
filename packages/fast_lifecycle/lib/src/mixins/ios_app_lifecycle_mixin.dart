import '../domain/life_platform_source.dart';
import '../domain/lifecycle_scope.dart';
import '../domain/raw_lifecycle_event.dart';
import '../domain/states/ios_app_lifecycle_state.dart';
import 'lifecycle_listener_binding.dart';

/// iOS [UIApplicationDelegate] 生命周期 Mixin。
///
/// Mixin 后覆盖对应 `onApplication*` 方法即可响应 iOS 原生回调。
mixin IosAppLifecycleMixin on LifecycleListenerBinding {
  @override
  void onPlatformLifecycleEvent(RawLifeCycleEvent event) {
    if (event.source == LifePlatformSource.ios &&
        event.extra.lifecycleScope == LifecycleScope.application) {
      switch (event.rawState) {
        case IosAppLifecycleState.applicationDidFinishLaunching:
          onApplicationDidFinishLaunching(event);
        case IosAppLifecycleState.applicationDidBecomeActive:
          onApplicationDidBecomeActive(event);
        case IosAppLifecycleState.applicationWillResignActive:
          onApplicationWillResignActive(event);
        case IosAppLifecycleState.applicationDidEnterBackground:
          onApplicationDidEnterBackground(event);
        case IosAppLifecycleState.applicationWillEnterForeground:
          onApplicationWillEnterForeground(event);
        case IosAppLifecycleState.applicationWillTerminate:
          onApplicationWillTerminate(event);
      }
      return;
    }
    super.onPlatformLifecycleEvent(event);
  }

  void onApplicationDidFinishLaunching(RawLifeCycleEvent event) {}

  void onApplicationDidBecomeActive(RawLifeCycleEvent event) {}

  void onApplicationWillResignActive(RawLifeCycleEvent event) {}

  void onApplicationDidEnterBackground(RawLifeCycleEvent event) {}

  void onApplicationWillEnterForeground(RawLifeCycleEvent event) {}

  void onApplicationWillTerminate(RawLifeCycleEvent event) {}
}
