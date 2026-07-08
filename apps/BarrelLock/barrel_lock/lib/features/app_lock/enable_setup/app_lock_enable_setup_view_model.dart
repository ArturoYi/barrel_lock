import 'package:core/core.dart';

import '../session/app_lock_session_view_model.dart';
import '../settings/app_lock_settings_view_model.dart';
import '../shared/model/app_lock_auth_service.dart';
import '../shared/model/app_lock_model.dart';
import '../shared/policy/app_lock_pin_policy.dart';
import 'app_lock_enable_setup_coordinator.dart';
import 'app_lock_enable_setup_state.dart';

/// 开启应用保护前的 PIN 设置 ViewModel（MVVM-C 的 VM 层）。
///
/// 与 [AppLockPinPromptViewModel]（运行时解锁）分离；仅在设置页内嵌 Panel 驱动。
final class AppLockEnableSetupViewModel
    extends Notifier<AppLockEnableSetupState> {
  late final AppLockModel _model;
  late final AppLockAuthService _authService;
  late final AppLockEnableSetupCoordinatorGateway _coordinator;

  @override
  AppLockEnableSetupState build() {
    _model = ref.read(appLockModelProvider);
    _authService = ref.read(appLockAuthServiceProvider);
    _coordinator = ref.read(appLockEnableSetupCoordinatorProvider);
    return const AppLockEnableSetupState.idle();
  }

  /// 进入开启验证流程；不写 `enabled`。
  void begin() {
    state = const AppLockEnableSetupState(
      phase: AppLockEnableSetupPhase.active,
      obscurePin: true,
      obscureConfirmPin: true,
    );
  }

  /// 取消开启验证；Switch 保持关闭。
  void cancel() {
    if (state.phase == AppLockEnableSetupPhase.idle) {
      return;
    }
    _coordinator.onEnableSetupCancelled();
    state = const AppLockEnableSetupState.idle();
  }

  void toggleObscurePin() {
    if (state.isBusy) {
      return;
    }
    state = state.copyWith(obscurePin: !state.obscurePin);
  }

  void toggleObscureConfirmPin() {
    if (state.isBusy) {
      return;
    }
    state = state.copyWith(obscureConfirmPin: !state.obscureConfirmPin);
  }

  /// 校验并落盘 PIN，成功后开启应用保护。
  Future<void> submitPin({
    required String pin,
    required String confirmPin,
  }) async {
    if (state.phase != AppLockEnableSetupPhase.active) {
      return;
    }

    final validationError = AppLockPinPolicy.validateSetup(
      pin: pin,
      confirmPin: confirmPin,
    );
    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      return;
    }

    state = state.copyWith(
      phase: AppLockEnableSetupPhase.submitting,
      clearError: true,
    );

    try {
      await _authService.setupFallbackPin(pin.trim());

      final preferences = await _model.load();
      await _model.save(
        preferences.copyWith(enabled: true, hasFallbackPin: true),
      );

      ref.invalidate(appLockSettingsViewModelProvider);
      await ref.read(appLockSessionProvider.notifier).lockAfterEnabled();

      _coordinator.onEnableSetupCompleted();
      state = const AppLockEnableSetupState.idle();
    } on ArgumentError catch (error) {
      state = state.copyWith(
        phase: AppLockEnableSetupPhase.active,
        errorMessage: error.message?.toString() ?? '密码格式无效',
      );
    } catch (error) {
      state = state.copyWith(
        phase: AppLockEnableSetupPhase.active,
        errorMessage: '开启失败，请重试',
      );
    }
  }
}

final appLockEnableSetupProvider =
    NotifierProvider<AppLockEnableSetupViewModel, AppLockEnableSetupState>(
      AppLockEnableSetupViewModel.new,
    );
