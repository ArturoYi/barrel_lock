import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../session/app_lock_session_view_model.dart';
import 'pin_prompt/app_lock_pin_prompt_overlay_layer.dart';
import 'app_lock_session_barrier.dart';

/// 全局锁屏 Overlay 容器（Shell 层 View，非路由）。
///
/// 监听：
/// - [appLockSessionProvider.showSessionBarrier] → 后台隐私遮罩
/// - [appLockSessionProvider.isLocked] / [isAuthenticating] → 锁屏遮罩 + [AppLockPinPromptOverlayLayer]
/// - [appLockPinPromptProvider] → [AppLockPinPromptPanel]（由 [AppLockPinPromptOverlayHost] 挂载）
///
/// 挂载位置：[ThemedApp] 的 [MaterialApp.builder]（覆盖 Loading / Dialog；
/// 默认 Toast 在其子树内，[ToastOverlayLayer.elevated] Toast 在其同级之上）。
final class AppLockOverlay extends ConsumerWidget {
  const AppLockOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSessionBarrier = ref.watch(
      appLockSessionProvider.select((session) => session.showSessionBarrier),
    );
    final showLockSession = ref.watch(
      appLockSessionProvider.select(
        (session) => session.isLocked || session.isAuthenticating,
      ),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                fit: StackFit.expand,
                children: [...previousChildren, ?currentChild],
              );
            },
            child: showSessionBarrier || showLockSession
                ? const AppLockSessionBarrier(key: ValueKey('visible'))
                : const SizedBox.shrink(key: ValueKey('hidden')),
          ),
        ),
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            layoutBuilder: (currentChild, previousChildren) {
              return Stack(
                fit: StackFit.expand,
                children: [...previousChildren, ?currentChild],
              );
            },
            child: showLockSession && !showSessionBarrier
                ? AppLockPinPromptOverlayLayer()
                : const SizedBox.shrink(key: ValueKey('lock-session-hidden')),
          ),
        ),
      ],
    );
  }
}
