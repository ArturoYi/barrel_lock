import '../domain/flat/platform_lifecycle_snapshot.dart';
import '../domain/raw_lifecycle_event.dart';
import 'lifecycle_listener_binding.dart';

/// 差异版状态 Mixin：记录最近一次原生 [PlatformLifecycleSnapshot]。
///
/// 推荐 Mixin 顺序（从左到右，事件先经本平台专用 Mixin 分发）：
/// `LifecycleListenerBinding, IosAppLifecycleMixin, FlatLifecycleMixin, PlatformLifecycleStateMixin`
mixin PlatformLifecycleStateMixin on LifecycleListenerBinding {
  PlatformLifecycleSnapshot _platformSnapshot = PlatformLifecycleSnapshot.empty;

  /// 当前平台原生快照（差异版）。
  PlatformLifecycleSnapshot get platformLifecycleSnapshot => _platformSnapshot;

  /// 当前原生 rawState。
  String? get currentPlatformRawState => _platformSnapshot.rawState;

  /// 当前原生 lifecycleScope。
  String? get currentPlatformLifecycleScope => _platformSnapshot.lifecycleScope;

  @override
  void onPlatformLifecycleEvent(RawLifeCycleEvent event) {
    _platformSnapshot = PlatformLifecycleSnapshot.from(event);
    onPlatformLifecycleStateChanged(_platformSnapshot, event);
    super.onPlatformLifecycleEvent(event);
  }

  /// 每次原生状态变更时回调。
  void onPlatformLifecycleStateChanged(
    PlatformLifecycleSnapshot snapshot,
    RawLifeCycleEvent event,
  ) {}
}
