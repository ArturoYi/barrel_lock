import '../domain/life_platform_source.dart';
import '../domain/lifecycle_scope.dart';
import '../domain/raw_lifecycle_event.dart';
import '../domain/states/linux_app_lifecycle_state.dart';
import 'lifecycle_listener_binding.dart';

/// Linux GTK 窗口生命周期 Mixin。
mixin LinuxAppLifecycleMixin on LifecycleListenerBinding {
  @override
  void onPlatformLifecycleEvent(RawLifeCycleEvent event) {
    if (event.source == LifePlatformSource.linux &&
        event.extra.lifecycleScope == LifecycleScope.window) {
      switch (event.rawState) {
        case LinuxAppLifecycleState.windowMinimize:
          onWindowMinimize(event);
        case LinuxAppLifecycleState.windowRestore:
          onWindowRestore(event);
        case LinuxAppLifecycleState.windowFocus:
          onWindowFocus(event);
        case LinuxAppLifecycleState.windowBlur:
          onWindowBlur(event);
        case LinuxAppLifecycleState.windowClose:
          onWindowClose(event);
      }
      return;
    }
    super.onPlatformLifecycleEvent(event);
  }

  void onWindowMinimize(RawLifeCycleEvent event) {}

  void onWindowRestore(RawLifeCycleEvent event) {}

  void onWindowFocus(RawLifeCycleEvent event) {}

  void onWindowBlur(RawLifeCycleEvent event) {}

  void onWindowClose(RawLifeCycleEvent event) {}
}
