import '../domain/life_platform_source.dart';
import '../domain/lifecycle_scope.dart';
import '../domain/raw_lifecycle_event.dart';
import '../domain/states/macos_app_lifecycle_state.dart';
import 'lifecycle_listener_binding.dart';

/// macOS NSWindow / NSApplication 生命周期 Mixin。
mixin MacosAppLifecycleMixin on LifecycleListenerBinding {
  @override
  void onPlatformLifecycleEvent(RawLifeCycleEvent event) {
    if (event.source != LifePlatformSource.macos) {
      super.onPlatformLifecycleEvent(event);
      return;
    }

    switch (event.extra.lifecycleScope) {
      case LifecycleScope.window:
        _dispatchWindow(event);
        return;
      case LifecycleScope.application:
        _dispatchApplication(event);
        return;
      default:
        break;
    }
    super.onPlatformLifecycleEvent(event);
  }

  void _dispatchWindow(RawLifeCycleEvent event) {
    switch (event.rawState) {
      case MacosAppLifecycleState.windowDidBecomeKey:
        onWindowDidBecomeKey(event);
      case MacosAppLifecycleState.windowDidResignKey:
        onWindowDidResignKey(event);
      case MacosAppLifecycleState.windowDidMiniaturize:
        onWindowDidMiniaturize(event);
      case MacosAppLifecycleState.windowDidDeminiaturize:
        onWindowDidDeminiaturize(event);
      case MacosAppLifecycleState.windowWillClose:
        onWindowWillClose(event);
    }
  }

  void _dispatchApplication(RawLifeCycleEvent event) {
    switch (event.rawState) {
      case MacosAppLifecycleState.applicationDidHide:
        onApplicationDidHide(event);
      case MacosAppLifecycleState.applicationDidUnhide:
        onApplicationDidUnhide(event);
    }
  }

  void onWindowDidBecomeKey(RawLifeCycleEvent event) {}

  void onWindowDidResignKey(RawLifeCycleEvent event) {}

  void onWindowDidMiniaturize(RawLifeCycleEvent event) {}

  void onWindowDidDeminiaturize(RawLifeCycleEvent event) {}

  void onWindowWillClose(RawLifeCycleEvent event) {}

  void onApplicationDidHide(RawLifeCycleEvent event) {}

  void onApplicationDidUnhide(RawLifeCycleEvent event) {}
}
