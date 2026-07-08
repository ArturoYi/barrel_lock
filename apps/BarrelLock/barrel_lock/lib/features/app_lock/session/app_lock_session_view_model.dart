import 'package:core/core.dart';

import '../runtime_auth/app_lock_pin_prompt_view_model.dart';
import '../shared/model/app_lock_auth_service.dart';
import '../shared/model/app_lock_model.dart';
import '../shared/model/app_lock_preferences.dart';

/// 锁屏会话运行时状态（MVVM-C 的 VM 层输出）。
///
/// 与 [AppLockPreferences] 不同：描述「当前是否被锁住 / 是否正在验证」，非用户配置。
final class AppLockSessionState {
  const AppLockSessionState({
    required this.isLocked,
    required this.isAuthenticating,
    required this.showBackgroundShield,
  });

  const AppLockSessionState.idle()
    : isLocked = false,
      isAuthenticating = false,
      showBackgroundShield = false;

  /// 是否应显示锁屏遮罩（验证进行中为 `true`）。
  final bool isLocked;

  /// 是否正在执行身份验证循环（防止重入）。
  final bool isAuthenticating;

  /// 应用处于 inactive / paused 时的隐私遮罩（与 [isLocked] 分离，便于最小粒度刷新）。
  final bool showBackgroundShield;

  /// 是否应在 Overlay 中渲染 [AppLockSessionBarrier]。
  bool get showSessionBarrier => showBackgroundShield;

  AppLockSessionState copyWith({
    bool? isLocked,
    bool? isAuthenticating,
    bool? showBackgroundShield,
  }) {
    return AppLockSessionState(
      isLocked: isLocked ?? this.isLocked,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      showBackgroundShield: showBackgroundShield ?? this.showBackgroundShield,
    );
  }
}

/// 锁屏会话 ViewModel（MVVM-C 的 VM 层）。
///
/// 职责：
/// - 冷启动：若 [AppLockPreferences.enabled] 则立即触发验证
/// - 后台恢复：[onAppPaused] 标记待验证，[onAppResumed] 执行验证
/// - 验证循环：生物识别 → PIN 回退 → 失败重试（取消不退出循环，避免遮罩下无入口）
///
/// 生命周期事件由 [AppLockSessionLifecycleBinder] 转发；锁屏 / PIN 遮罩 UI 由各平台 View 实现。
///
/// ## View 接入示例
///
/// ```dart
/// final session = ref.watch(appLockSessionProvider);
/// if (session.isLocked) {
///   // 渲染全屏锁屏遮罩（ModalBarrier 等）
/// }
/// final pinPrompt = ref.watch(appLockPinPromptProvider);
/// if (pinPrompt != null) {
///   // 渲染 PIN 输入 UI
/// }
/// ```
final class AppLockSessionViewModel extends Notifier<AppLockSessionState> {
  late final AppLockModel _model;
  late final AppLockAuthService _authService;

  bool _pendingUnlockOnResume = false;
  var _coldStartLockScheduled = false;
  var _lockEnabled = false;

  @override
  AppLockSessionState build() {
    _model = ref.read(appLockModelProvider);
    _authService = ref.read(appLockAuthServiceProvider);
    _scheduleColdStartLockIfNeeded();
    return const AppLockSessionState.idle();
  }

  void _scheduleColdStartLockIfNeeded() {
    if (_coldStartLockScheduled) {
      return;
    }
    _coldStartLockScheduled = true;
    Future.microtask(_lockOnColdStartIfNeeded);
  }

  Future<void> _lockOnColdStartIfNeeded() async {
    if (state.isAuthenticating) {
      return;
    }

    final preferences = await _loadPreferences();
    if (preferences == null || !preferences.enabled) {
      return;
    }

    await _authenticate(preferences);
  }

  /// inactive / paused 时立即显示隐私遮罩（同步，不 await 偏好加载）。
  void showBackgroundShield() {
    if (!state.showBackgroundShield) {
      state = state.copyWith(showBackgroundShield: true);
    }
  }

  /// resumed 时收起隐私遮罩；若待验证则无缝切到 [isLocked]，避免闪屏。
  void hideBackgroundShield() {
    if (state.showBackgroundShield) {
      state = state.copyWith(showBackgroundShield: false);
    }
  }

  /// paused 时同步标记待验证（避免 resume 早于 async [onAppPaused] 完成）。
  void markPendingUnlockOnPause() {
    if (!_lockEnabled) {
      return;
    }
    _pendingUnlockOnResume = true;
  }

  /// 应用进入 paused：校验偏好并刷新待验证标记。
  Future<void> onAppPaused() async {
    final preferences = await _loadPreferences();
    if (preferences == null || !preferences.enabled) {
      _pendingUnlockOnResume = false;
      return;
    }
    _pendingUnlockOnResume = true;
  }

  /// 设置页刚启用锁屏后调用（冷启动逻辑只执行一次，启用后需主动触发）。
  Future<void> lockAfterEnabled() async {
    if (state.isAuthenticating || state.isLocked) {
      return;
    }

    final preferences = await _loadPreferences();
    if (preferences == null || !preferences.enabled) {
      return;
    }

    await _authenticate(preferences);
  }

  /// 应用回到前台：若有待验证标记则启动验证循环。
  Future<void> onAppResumed() async {
    if (!_pendingUnlockOnResume || state.isAuthenticating) {
      return;
    }

    final preferences = await _loadPreferences();
    if (preferences == null) {
      return;
    }
    if (!preferences.enabled) {
      _pendingUnlockOnResume = false;
      return;
    }

    await _authenticate(preferences);
  }

  Future<AppLockPreferences?> _loadPreferences() async {
    final preferences = await _model.load();
    if (!ref.mounted) {
      return null;
    }
    _lockEnabled = preferences.enabled;
    return preferences;
  }

  Future<void> _authenticate(AppLockPreferences preferences) async {
    if (state.isAuthenticating) {
      return;
    }

    state = state.copyWith(
      isLocked: true,
      isAuthenticating: true,
      showBackgroundShield: false,
    );

    while (true) {
      var result = await _authService.authenticateForAppLock(
        reason: IdentityAuthReason.unlockOnResume,
        preferences: preferences,
      );
      if (!ref.mounted) {
        return;
      }

      // 生物识别失败或用户取消 PIN 后，进入 PIN 重试循环。
      while (result.isFailure) {
        final pin = await ref
            .read(appLockPinPromptProvider.notifier)
            .requestPin(
              IdentityAuthReason.unlockOnResume,
              errorMessage: result.message ?? '密码错误，请重试',
            );
        if (!ref.mounted) {
          return;
        }
        if (pin == null) {
          result = IdentityAuthResult.cancelled();
          break;
        }
        final valid = await _authService.verifyAppPin(pin);
        if (!ref.mounted) {
          return;
        }
        result = valid
            ? IdentityAuthResult.success(method: IdentityAuthMethod.appPin)
            : IdentityAuthResult.failure(message: '应用内密码错误');
      }

      if (result.isSuccess) {
        ref.read(appLockPinPromptProvider.notifier).dismiss();
        state = state.copyWith(isLocked: false, isAuthenticating: false);
        _pendingUnlockOnResume = false;
        return;
      }

      if (result.isUnavailable) {
        FastToast.show(result.message ?? '当前无法验证身份，请重试');
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (!ref.mounted) {
          return;
        }
        continue;
      }

      // 用户取消验证时继续重试，避免遮罩下无解锁入口。
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (!ref.mounted) {
        return;
      }
    }
  }
}

final appLockSessionProvider =
    NotifierProvider<AppLockSessionViewModel, AppLockSessionState>(
      AppLockSessionViewModel.new,
    );

/// 兼容旧代码中对 Notifier 类型的引用。
typedef AppLockSessionNotifier = AppLockSessionViewModel;
