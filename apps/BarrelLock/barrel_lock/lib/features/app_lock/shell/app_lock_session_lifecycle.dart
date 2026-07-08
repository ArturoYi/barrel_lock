import 'package:core/core.dart';
import 'package:fast_lifecycle/fast_lifecycle.dart';
import 'package:flutter/material.dart';

import '../view_model/app_lock_session_view_model.dart';

/// 将平台生命周期事件桥接到 [AppLockSessionViewModel]（Shell 层，非页面 View）。
///
/// 仅负责订阅 pause / resume 并调用 ViewModel；**不渲染任何锁屏 UI**。
/// 各平台或 Shell 应在子树上监听：
///
/// - [appLockSessionProvider] → `isLocked` 时显示锁屏遮罩
/// - [appLockPinPromptProvider] → 非 `null` 时显示 PIN 输入 UI
///
/// 典型装配位置：[ThemedApp] 的 `builder` 包裹链中。
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
  void onFlatPaused(RawLifeCycleEvent event) {
    ref.read(appLockSessionProvider.notifier).onAppPaused();
    debugPrint('onFlatPaused: PAUSED');
  }

  @override
  void onFlatResumed(RawLifeCycleEvent event) {
    ref.read(appLockSessionProvider.notifier).onAppResumed();
    debugPrint('onFlatResumed: RESUMED');
  }

  @override
  void onFlatDetached(RawLifeCycleEvent event) {
    debugPrint('onFlatDetached: DETACHED');
  }

  @override
  void onFlatInactive(RawLifeCycleEvent event) {
    debugPrint('onFlatInactive: INACTIVE');
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
