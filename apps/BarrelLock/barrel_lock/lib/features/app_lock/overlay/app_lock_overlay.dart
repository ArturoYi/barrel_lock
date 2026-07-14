import 'dart:async';

import 'package:barrel_lock/features/app_lock/runtime_auth/app_lock_pin_prompt_view_model.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../session/app_lock_session_view_model.dart';
import 'app_lock_session_barrier.dart';
import 'pin_prompt/app_lock_pin_prompt_panel.dart';

/// 全局锁屏 Overlay 容器（Shell 层 View，非路由）。
///
/// 监听：
/// - [appLockSessionProvider.showSessionBarrier] → 后台隐私遮罩
/// - [appLockSessionProvider.isLocked] / [isAuthenticating] → 锁屏遮罩
/// - [appLockPinPromptProvider] → [AppLockPinPromptPanel]（作为 [AppLockSessionBarrier] 的 child）
///
/// 挂载位置：[ThemedApp] 的 [MaterialApp.builder]（覆盖 Loading / Dialog；
/// 默认 Toast 在其子树内，[ToastOverlayLayer.elevated] Toast 在其同级之上）。
final class AppLockOverlay extends ConsumerStatefulWidget {
  const AppLockOverlay({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockOverlay> createState() => _AppLockOverlayState();
}

class _AppLockOverlayState extends ConsumerState<AppLockOverlay> {
  static const _authenticationDelay = Duration(milliseconds: 500);

  Timer? _authDelayTimer;
  ProviderSubscription<AppLockSessionState>? _sessionSubscription;

  @override
  void initState() {
    super.initState();
    _sessionSubscription = ref.listenManual(
      appLockSessionProvider,
      _scheduleAuthenticationIfNeeded,
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _authDelayTimer?.cancel();
    _sessionSubscription?.close();
    super.dispose();
  }

  void _scheduleAuthenticationIfNeeded(
    AppLockSessionState? previous,
    AppLockSessionState next,
  ) {
    if (!next.isLocked || !next.isAuthenticating) {
      _authDelayTimer?.cancel();
      _authDelayTimer = null;
      return;
    }

    final wasRequested =
        (previous?.isLocked ?? false) && (previous?.isAuthenticating ?? false);
    if (wasRequested) {
      return;
    }

    _authDelayTimer?.cancel();
    _authDelayTimer = Timer(_authenticationDelay, () {
      _authDelayTimer = null;
      if (!mounted) {
        return;
      }
      unawaited(
        ref.read(appLockSessionProvider.notifier).startAuthentication(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final showSessionBarrier = ref.watch(
      appLockSessionProvider.select((session) => session.showSessionBarrier),
    );
    final session = ref.watch(appLockSessionProvider);
    final showLockSession = session.isLocked || session.isAuthenticating;
    final pinPrompt = ref.watch(appLockPinPromptProvider);

    final Widget? pinChild =
        showLockSession && !showSessionBarrier && pinPrompt != null
        ? AppLockPinPromptPanel(state: pinPrompt)
        : showLockSession &&
              !showSessionBarrier &&
              session.authStatusMessage != null
        ? Center(
            child: AppLockPinPromptHeaderSection(
              message: session.authStatusMessage,
            ),
          )
        : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
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
                ? AppLockSessionBarrier(
                    key: const ValueKey('visible'),
                    child: pinChild,
                  )
                : const SizedBox.shrink(key: ValueKey('hidden')),
          ),
        ),
      ],
    );
  }
}
