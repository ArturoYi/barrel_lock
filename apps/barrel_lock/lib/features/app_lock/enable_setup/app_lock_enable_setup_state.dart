/// 开启验证流程内的 PageView 步骤。
enum AppLockEnableSetupStep {
  /// 输入 PIN。
  pin,

  /// 输入忘记密码时的提示语。
  hint,
}

/// 开启应用保护前的 PIN 设置流程阶段。
enum AppLockEnableSetupPhase {
  /// 未展示开启验证 UI。
  idle,

  /// 等待用户输入 PIN。
  active,

  /// 正在落盘 PIN 并开启保护。
  submitting,
}

/// 开启验证流程展示状态（MVVM-C 的 VM 层输出）。
final class AppLockEnableSetupState {
  const AppLockEnableSetupState({
    required this.phase,
    required this.step,
    required this.obscurePin,
    this.errorMessage,
  });

  const AppLockEnableSetupState.idle()
    : phase = AppLockEnableSetupPhase.idle,
      step = AppLockEnableSetupStep.pin,
      obscurePin = true,
      errorMessage = null;

  /// 当前开启验证流程的阶段。
  final AppLockEnableSetupPhase phase;

  /// PageView 当前步骤；仅在 [phase] 为 [AppLockEnableSetupPhase.active] 时有效。
  final AppLockEnableSetupStep step;

  /// 是否遮蔽 PIN 输入框明文（由 [AppLockEnableSetupViewModel.toggleObscurePin] 切换）。
  final bool obscurePin;

  /// PIN 校验或落盘失败时的提示；`null` 表示无错误。
  final String? errorMessage;

  /// 是否处于开启验证流程中（`phase != idle`）；用于禁用设置页控件。
  bool get isVisible => phase != AppLockEnableSetupPhase.idle;

  /// 是否正在提交 PIN 并开启保护（应禁用输入与按钮）。
  bool get isBusy => phase == AppLockEnableSetupPhase.submitting;

  AppLockEnableSetupState copyWith({
    AppLockEnableSetupPhase? phase,
    AppLockEnableSetupStep? step,
    bool? obscurePin,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppLockEnableSetupState(
      phase: phase ?? this.phase,
      step: step ?? this.step,
      obscurePin: obscurePin ?? this.obscurePin,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
