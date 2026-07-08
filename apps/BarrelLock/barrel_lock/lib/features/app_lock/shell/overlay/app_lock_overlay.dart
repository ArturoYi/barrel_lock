import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../session/app_lock_session_view_model.dart';
import 'app_lock_pin_prompt_overlay_layer.dart';
import 'app_lock_session_barrier.dart';

/// 全局锁屏 Overlay 容器（Shell 层 View，非路由）。
///
/// 监听：
/// - [appLockSessionProvider] → [AppLockSessionBarrier]
/// - [appLockPinPromptProvider] → [AppLockPinPromptPanel]
///
/// 挂载位置：[ThemedApp] 的 [MaterialApp.builder] 最外层（覆盖 Loading / Toast / Dialog）。
final class AppLockOverlay extends ConsumerWidget {
  const AppLockOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSessionBarrier = ref.watch(
      appLockSessionProvider.select((session) => session.showSessionBarrier),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (showSessionBarrier) const AppLockSessionBarrier(),
        const AppLockPinPromptOverlayLayer(),
      ],
    );
  }
}
