import 'package:core/core.dart';

import '../session/app_lock_session_view_model.dart';
import '../settings/app_lock_settings_view_model.dart';
import '../shared/model/app_lock_preferences_repository.dart';
import '../shared/policy/app_lock_pin_policy.dart';
import 'app_lock_enable_setup_coordinator.dart';
import 'app_lock_enable_setup_state.dart';

/// 开启应用保护前的 PIN 设置 ViewModel（MVVM-C 的 VM 层）。
///
/// 与 [AppLockPinPromptViewModel]（运行时解锁）分离；仅在设置页内嵌 Panel 驱动。
final class AppLockEnableSetupViewModel
    extends Notifier<AppLockEnableSetupState> {
  late final AppLockPreferencesRepository _preferencesRepository;
  late final AppLockEnableSetupCoordinatorGateway _coordinator;

  @override
  AppLockEnableSetupState build() {
    _preferencesRepository = ref.read(appLockPreferencesRepositoryProvider);
    _coordinator = ref.read(appLockEnableSetupCoordinatorProvider);
    return const AppLockEnableSetupState.idle();
  }

  /// 进入开启验证流程；不写 `enabled`。
  void begin() {
    state = const AppLockEnableSetupState(
      phase: AppLockEnableSetupPhase.active,
      step: AppLockEnableSetupStep.pin,
      obscurePin: true,
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

  /// 从提示语步骤返回 PIN 步骤。
  void backToPinStep() {
    if (state.phase != AppLockEnableSetupPhase.active ||
        state.step != AppLockEnableSetupStep.hint ||
        state.isBusy) {
      return;
    }
    state = state.copyWith(step: AppLockEnableSetupStep.pin, clearError: true);
  }

  /// 切换 PIN 输入框明文 / 密文显示；提交中不生效。
  void toggleObscurePin() {
    if (state.isBusy) {
      return;
    }
    state = state.copyWith(obscurePin: !state.obscurePin);
  }

  /// 校验 PIN 并进入提示语步骤。
  void continueToHintStep({required String pin}) {
    if (state.phase != AppLockEnableSetupPhase.active ||
        state.step != AppLockEnableSetupStep.pin) {
      return;
    }

    final validationError = AppLockPinPolicy.validatePin(pin);
    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      return;
    }

    state = state.copyWith(step: AppLockEnableSetupStep.hint, clearError: true);
  }

  /// 校验提示语并落盘 PIN，成功后开启应用保护。
  Future<void> submitSetup({required String pin, required String hint}) async {
    if (state.phase != AppLockEnableSetupPhase.active ||
        state.step != AppLockEnableSetupStep.hint) {
      return;
    }

    final pinError = AppLockPinPolicy.validatePin(pin);
    if (pinError != null) {
      state = state.copyWith(
        step: AppLockEnableSetupStep.pin,
        errorMessage: pinError,
      );
      return;
    }

    final hintError = AppLockPinPolicy.validateHint(hint);
    if (hintError != null) {
      state = state.copyWith(errorMessage: hintError);
      return;
    }

    state = state.copyWith(
      phase: AppLockEnableSetupPhase.submitting,
      clearError: true,
    );

    try {
      await _preferencesRepository.enableWithFallbackPin(
        pin.trim(),
        fallbackPinHint: hint,
      );
      if (!ref.mounted) {
        return;
      }

      ref.invalidate(appLockSettingsViewModelProvider);
      await ref.read(appLockSessionProvider.notifier).lockAfterEnabled();
      if (!ref.mounted) {
        return;
      }

      _coordinator.onEnableSetupCompleted();
      state = const AppLockEnableSetupState.idle();
    } on ArgumentError catch (error) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        phase: AppLockEnableSetupPhase.active,
        step: AppLockEnableSetupStep.hint,
        errorMessage: error.message?.toString() ?? '密码格式无效',
      );
    } catch (error) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        phase: AppLockEnableSetupPhase.active,
        step: AppLockEnableSetupStep.hint,
        errorMessage: '开启失败，请重试',
      );
    }
  }
}

/// 设置页内嵌开启验证 Panel 的状态；由 [AppLockEnableSetupViewModel] 维护。
final appLockEnableSetupProvider =
    NotifierProvider<AppLockEnableSetupViewModel, AppLockEnableSetupState>(
      AppLockEnableSetupViewModel.new,
      isAutoDispose: true,
    );
