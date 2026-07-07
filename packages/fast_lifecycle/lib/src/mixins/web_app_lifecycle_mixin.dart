import '../domain/life_platform_source.dart';
import '../domain/lifecycle_scope.dart';
import '../domain/raw_lifecycle_event.dart';
import '../domain/states/web_app_lifecycle_state.dart';
import 'lifecycle_listener_binding.dart';

/// Web 浏览器生命周期 Mixin。
mixin WebAppLifecycleMixin on LifecycleListenerBinding {
  @override
  void onPlatformLifecycleEvent(RawLifeCycleEvent event) {
    if (event.source == LifePlatformSource.web &&
        event.extra.lifecycleScope == LifecycleScope.browser) {
      switch (event.rawState) {
        case WebAppLifecycleState.visibilityChangeHidden:
          onVisibilityChangeHidden(event);
        case WebAppLifecycleState.visibilityChangeVisible:
          onVisibilityChangeVisible(event);
        case WebAppLifecycleState.windowFocus:
          onWindowFocus(event);
        case WebAppLifecycleState.windowBlur:
          onWindowBlur(event);
      }
      return;
    }
    super.onPlatformLifecycleEvent(event);
  }

  void onVisibilityChangeHidden(RawLifeCycleEvent event) {}

  void onVisibilityChangeVisible(RawLifeCycleEvent event) {}

  void onWindowFocus(RawLifeCycleEvent event) {}

  void onWindowBlur(RawLifeCycleEvent event) {}
}
