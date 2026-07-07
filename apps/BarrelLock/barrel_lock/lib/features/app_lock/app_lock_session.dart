import 'package:core/core.dart';
import 'package:fast_lifecycle/fast_lifecycle.dart';
import 'package:flutter/material.dart';

import 'app_lock_auth_service.dart';
import 'app_lock_model.dart';
import 'app_lock_pin_prompt.dart';

/// 锁屏会话状态。
final class AppLockSessionState {
  const AppLockSessionState({
    required this.isLocked,
    required this.isAuthenticating,
  });

  const AppLockSessionState.idle() : isLocked = false, isAuthenticating = false;

  final bool isLocked;
  final bool isAuthenticating;

  AppLockSessionState copyWith({bool? isLocked, bool? isAuthenticating}) {
    return AppLockSessionState(
      isLocked: isLocked ?? this.isLocked,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
    );
  }
}

/// 管理后台恢复锁定与解锁流程。
final class AppLockSessionNotifier extends Notifier<AppLockSessionState> {
  late final AppLockModel _model;
  late final AppLockAuthService _authService;

  bool _pendingUnlockOnResume = false;
  bool _isColdStart = true;

  @override
  AppLockSessionState build() {
    _model = ref.read(appLockModelProvider);
    _authService = ref.read(appLockAuthServiceProvider);
    return const AppLockSessionState.idle();
  }

  Future<void> onAppPaused() async {
    final preferences = await _model.load();
    if (!preferences.enabled) {
      return;
    }
    _pendingUnlockOnResume = true;
  }

  Future<void> onAppResumed() async {
    if (_isColdStart) {
      _isColdStart = false;
      return;
    }
    if (!_pendingUnlockOnResume || state.isAuthenticating) {
      return;
    }

    final preferences = await _model.load();
    if (!preferences.enabled) {
      _pendingUnlockOnResume = false;
      return;
    }

    await _authenticate(preferences);
  }

  Future<void> _authenticate(AppLockPreferences preferences) async {
    state = state.copyWith(isLocked: true, isAuthenticating: true);

    var result = await _authService.authenticateForAppLock(
      reason: IdentityAuthReason.unlockOnResume,
      preferences: preferences,
    );

    while (result.isFailure) {
      final pin = await ref
          .read(appLockPinPromptProvider.notifier)
          .requestPin(
            IdentityAuthReason.unlockOnResume,
            errorMessage: '密码错误，请重试',
          );
      if (pin == null) {
        result = IdentityAuthResult.cancelled();
        break;
      }
      final valid = await AppIdentityAuth.verifyAppPin(pin);
      result = valid
          ? IdentityAuthResult.success(method: IdentityAuthMethod.appPin)
          : IdentityAuthResult.failure();
    }

    state = state.copyWith(
      isLocked: !result.isSuccess,
      isAuthenticating: false,
    );

    if (result.isSuccess) {
      _pendingUnlockOnResume = false;
    }
  }
}

final appLockSessionProvider =
    NotifierProvider<AppLockSessionNotifier, AppLockSessionState>(
      AppLockSessionNotifier.new,
    );

/// 订阅抹平生命周期并驱动 [AppLockSessionNotifier]。
final class AppLockLifecycleHost extends ConsumerStatefulWidget {
  const AppLockLifecycleHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockLifecycleHost> createState() =>
      _AppLockLifecycleHostState();
}

class _AppLockLifecycleHostState extends ConsumerState<AppLockLifecycleHost>
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
  }

  @override
  void onFlatResumed(RawLifeCycleEvent event) {
    ref.read(appLockSessionProvider.notifier).onAppResumed();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(appLockSessionProvider);
    final pinPrompt = ref.watch(appLockPinPromptProvider);

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (session.isLocked || pinPrompt != null) ...[
          const ModalBarrier(dismissible: false),
          const AppLockPinPromptOverlay(),
        ],
      ],
    );
  }
}
