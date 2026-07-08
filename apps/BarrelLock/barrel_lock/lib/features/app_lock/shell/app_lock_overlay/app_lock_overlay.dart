import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../view_model/app_lock_pin_prompt_view_model.dart';
import '../../view_model/app_lock_session_view_model.dart';
import 'app_lock_pin_prompt_panel.dart';
import 'app_lock_session_barrier.dart';

/// 全局锁屏 Overlay 容器（Shell 层 View，非路由）。
///
/// 监听：
/// - [appLockSessionProvider] → [AppLockSessionBarrier]
/// - [appLockPinPromptProvider] → [AppLockPinPromptPanel]
///
/// 挂载位置（尚未接入）：[ThemedApp] 的 `_overlayBuilder` 包裹链最外层。
final class AppLockOverlay extends ConsumerWidget {
  const AppLockOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(appLockSessionProvider);
    final pinPrompt = ref.watch(appLockPinPromptProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (session.isLocked) const AppLockSessionBarrier(),
        if (pinPrompt != null) AppLockPinPromptPanel(state: pinPrompt),
      ],
    );
  }
}
