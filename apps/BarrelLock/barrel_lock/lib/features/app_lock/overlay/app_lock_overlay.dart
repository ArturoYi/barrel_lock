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
/// 须在 [MaterialApp] 子树内，锁屏 PIN 等组件依赖 [Material] 祖先）。
final class AppLockOverlay extends ConsumerStatefulWidget {
  const AppLockOverlay({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockOverlay> createState() => _AppLockOverlayState();
}

class _AppLockOverlayState extends ConsumerState<AppLockOverlay>
    with WidgetsBindingObserver {
  static const _authenticationDelay = Duration(milliseconds: 500);

  Timer? _authDelayTimer;
  ProviderSubscription<AppLockSessionState>? _sessionSubscription;

  /// 仅在 inactive/paused 窗口内补充显示，resumed 后立即清除（不持有 provider 状态）。
  var _transientShield = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionSubscription = ref.listenManual(
      appLockSessionProvider,
      _onSessionChanged,
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authDelayTimer?.cancel();
    _sessionSubscription?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        if (!_transientShield) {
          setState(() => _transientShield = true);
        }
        _scheduleBarrierPaint();
      case AppLifecycleState.resumed:
        if (_transientShield) {
          setState(() => _transientShield = false);
        }
        // 兜底：防止 provider 隐私遮罩在乱序生命周期后卡住全屏灰层。
        ref.read(appLockSessionProvider.notifier).hideBackgroundShield();
      case AppLifecycleState.detached:
        break;
    }
  }

  void _onSessionChanged(
    AppLockSessionState? previous,
    AppLockSessionState next,
  ) {
    _scheduleAuthenticationIfNeeded(previous, next);
    if (next.showSessionBarrier || next.isLocked || next.isAuthenticating) {
      _scheduleBarrierPaint();
    }
  }

  void _scheduleBarrierPaint() {
    final binding = WidgetsBinding.instance;
    binding.scheduleForcedFrame();
    binding.addPostFrameCallback((_) => binding.scheduleForcedFrame());
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
    final session = ref.watch(appLockSessionProvider);
    final showSessionBarrier = session.showSessionBarrier;
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

    final showBarrier =
        showLockSession || showSessionBarrier || _transientShield;
    final privacyOnly = showBarrier && !showLockSession;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !showBarrier,
            child: Opacity(
              opacity: showBarrier ? 1 : 0,
              child: AppLockSessionBarrier(
                privacyOnly: privacyOnly,
                child: pinChild,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
