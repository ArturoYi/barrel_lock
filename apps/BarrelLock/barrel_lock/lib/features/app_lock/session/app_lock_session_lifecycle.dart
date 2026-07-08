import 'package:core/core.dart';
import 'package:fast_lifecycle/fast_lifecycle.dart';
import 'package:flutter/material.dart';

import 'app_lock_session_view_model.dart';

/// 将平台生命周期事件桥接到 [AppLockSessionViewModel]（Shell 层，非页面 View）。
///
/// 仅负责订阅 pause / resume 并调用 ViewModel；**不渲染任何锁屏 UI**。
/// 各平台或 Shell 应在子树上监听：
///
/// - [appLockSessionProvider] → `isLocked` 时显示锁屏遮罩
/// - [appLockPinPromptProvider] → 非 `null` 时显示 PIN 输入 UI
///
/// 典型装配位置：[ThemedApp] 包裹 [MaterialApp] 的最外层（与 [AppLockOverlay] 分离，仅订阅生命周期）。
final class AppLockSessionLifecycleBinder extends ConsumerStatefulWidget {
  const AppLockSessionLifecycleBinder({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockSessionLifecycleBinder> createState() =>
      _AppLockSessionLifecycleBinderState();
}

class _AppLockSessionLifecycleBinderState
    extends ConsumerState<AppLockSessionLifecycleBinder>
    with LifecycleListenerBinding, FlatLifecycleMixin {
  @override
  void initState() {
    super.initState();
    bindPlatformLifecycle();
  }

  @override
  void dispose() {
    unbindPlatformLifecycle();
    super.dispose();
  }

  @override
  void onFlatInactive(RawLifeCycleEvent event) {
    ref.read(appLockSessionProvider.notifier).showBackgroundShield();
  }

  @override
  void onFlatPaused(RawLifeCycleEvent event) {
    final notifier = ref.read(appLockSessionProvider.notifier);
    notifier.showBackgroundShield();
    notifier.markPendingUnlockOnPause();
    notifier.onAppPaused();
  }

  @override
  void onFlatResumed(RawLifeCycleEvent event) {
    final notifier = ref.read(appLockSessionProvider.notifier);
    notifier.hideBackgroundShield();
    notifier.onAppResumed();
  }

  @override
  void onFlatDetached(RawLifeCycleEvent event) {}

  @override
  Widget build(BuildContext context) => widget.child;
}
