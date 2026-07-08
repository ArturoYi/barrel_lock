/// 开启应用保护前的 PIN 设置流程阶段。
enum AppLockEnableSetupPhase {
  /// 未展示开启验证 UI。
  idle,

  /// 等待用户输入 PIN 与确认 PIN。
  active,

  /// 正在落盘 PIN 并开启保护。
  submitting,
}

/// 开启验证流程展示状态（MVVM-C 的 VM 层输出）。
final class AppLockEnableSetupState {
  const AppLockEnableSetupState({
    required this.phase,
    required this.obscurePin,
    required this.obscureConfirmPin,
    this.errorMessage,
  });

  const AppLockEnableSetupState.idle()
    : phase = AppLockEnableSetupPhase.idle,
      obscurePin = true,
      obscureConfirmPin = true,
      errorMessage = null;

  final AppLockEnableSetupPhase phase;
  final bool obscurePin;
  final bool obscureConfirmPin;
  final String? errorMessage;

  bool get isVisible => phase != AppLockEnableSetupPhase.idle;

  bool get isBusy => phase == AppLockEnableSetupPhase.submitting;

  AppLockEnableSetupState copyWith({
    AppLockEnableSetupPhase? phase,
    bool? obscurePin,
    bool? obscureConfirmPin,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AppLockEnableSetupState(
      phase: phase ?? this.phase,
      obscurePin: obscurePin ?? this.obscurePin,
      obscureConfirmPin: obscureConfirmPin ?? this.obscureConfirmPin,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
