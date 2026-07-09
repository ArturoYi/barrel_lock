import 'dart:async';

import 'package:barrel_lock/features/app_lock/runtime_auth/app_lock_pin_prompt_view_model.dart';
import 'package:barrel_lock/features/app_lock/session/app_lock_session_view_model.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'app_lock_pin_prompt_overlay_host.dart';

/// 锁屏会话 Overlay 层：提供根 [Overlay] 祖先，并协调认证延迟与 PIN 面板挂载。
///
/// - [AppLockPinPromptOverlayHost] 监听 [appLockPinPromptProvider] 插入 PIN 面板
/// - 锁屏遮罩由父级 [AppLockOverlay] 渲染
final class AppLockPinPromptOverlayLayer extends ConsumerStatefulWidget {
  const AppLockPinPromptOverlayLayer({super.key});

  @override
  ConsumerState<AppLockPinPromptOverlayLayer> createState() =>
      _AppLockPinPromptOverlayLayerState();
}

class _AppLockPinPromptOverlayLayerState
    extends ConsumerState<AppLockPinPromptOverlayLayer> {
  static const _authenticationDelay = Duration(milliseconds: 500);

  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();

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
    ref.watch(appLockPinPromptProvider);
    return Stack(
      fit: StackFit.expand,
      children: [
        Overlay(key: _overlayKey),
        AppLockPinPromptOverlayHost(overlayKey: _overlayKey),
      ],
    );
  }
}
