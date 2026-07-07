import '../domain/life_platform_source.dart';
import '../domain/lifecycle_scope.dart';
import '../domain/raw_lifecycle_event.dart';
import '../domain/states/android_app_lifecycle_state.dart';
import 'lifecycle_listener_binding.dart';

/// Android 进程 + Activity 双层生命周期 Mixin。
///
/// 进程层方法前缀 `onProcess*`，Activity 层前缀 `onActivity*`。
mixin AndroidAppLifecycleMixin on LifecycleListenerBinding {
  @override
  void onPlatformLifecycleEvent(RawLifeCycleEvent event) {
    if (event.source != LifePlatformSource.android) {
      super.onPlatformLifecycleEvent(event);
      return;
    }

    switch (event.extra.lifecycleScope) {
      case LifecycleScope.process:
        _dispatchProcess(event);
        return;
      case LifecycleScope.activity:
        _dispatchActivity(event);
        return;
      default:
        break;
    }
    super.onPlatformLifecycleEvent(event);
  }

  void _dispatchProcess(RawLifeCycleEvent event) {
    switch (event.rawState) {
      case AndroidAppLifecycleState.onCreate:
        onProcessCreate(event);
      case AndroidAppLifecycleState.onStart:
        onProcessStart(event);
      case AndroidAppLifecycleState.onResume:
        onProcessResume(event);
      case AndroidAppLifecycleState.onPause:
        onProcessPause(event);
      case AndroidAppLifecycleState.onStop:
        onProcessStop(event);
      case AndroidAppLifecycleState.onDestroy:
        onProcessDestroy(event);
    }
  }

  void _dispatchActivity(RawLifeCycleEvent event) {
    switch (event.rawState) {
      case AndroidAppLifecycleState.onCreate:
        onActivityCreate(event);
      case AndroidAppLifecycleState.onStart:
        onActivityStart(event);
      case AndroidAppLifecycleState.onResume:
        onActivityResume(event);
      case AndroidAppLifecycleState.onPause:
        onActivityPause(event);
      case AndroidAppLifecycleState.onStop:
        onActivityStop(event);
      case AndroidAppLifecycleState.onDestroy:
        onActivityDestroy(event);
    }
  }

  void onProcessCreate(RawLifeCycleEvent event) {}

  void onProcessStart(RawLifeCycleEvent event) {}

  void onProcessResume(RawLifeCycleEvent event) {}

  void onProcessPause(RawLifeCycleEvent event) {}

  void onProcessStop(RawLifeCycleEvent event) {}

  void onProcessDestroy(RawLifeCycleEvent event) {}

  void onActivityCreate(RawLifeCycleEvent event) {}

  void onActivityStart(RawLifeCycleEvent event) {}

  void onActivityResume(RawLifeCycleEvent event) {}

  void onActivityPause(RawLifeCycleEvent event) {}

  void onActivityStop(RawLifeCycleEvent event) {}

  void onActivityDestroy(RawLifeCycleEvent event) {}
}
