import '../../domain/life_platform_source.dart';
import '../../domain/lifecycle_event_extra.dart';
import '../../domain/lifecycle_scope.dart';
import '../../domain/raw_lifecycle_event.dart';
import '../../domain/states/web_app_lifecycle_state.dart';
import '../../internal/lifecycle_init_options.dart';

/// 构造 Web 端 [RawLifeCycleEvent]。
RawLifeCycleEvent createWebLifecycleEvent({
  required String rawState,
  LifeCycleInitOptions options = const LifeCycleInitOptions(),
}) {
  return RawLifeCycleEvent(
    source: LifePlatformSource.web,
    rawState: rawState,
    extra: LifeCycleEventExtra(
      windowId: options.windowId,
      isMainWindow: options.isMainWindow,
      lifecycleScope: LifecycleScope.browser,
    ),
  );
}

/// @deprecated 使用 [WebAppLifecycleState]。
typedef WebLifecycleRawStates = WebAppLifecycleState;
