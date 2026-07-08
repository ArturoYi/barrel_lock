import 'dart:async';

import 'package:core/core.dart';

/// 全局 PIN 输入遮罩状态（MVVM-C 的 VM 层输出）。
///
/// `null` 表示遮罩未显示；非 `null` 时 View 应渲染 PIN 输入 UI。
final class AppLockPinPromptState {
  const AppLockPinPromptState({
    required this.reason,
    required this.errorMessage,
    required this.attempt,
    this.obscurePin = true,
    this.isSubmitting = false,
  });

  final IdentityAuthReason reason;
  final String? errorMessage;

  /// 每次 [AppLockPinPromptViewModel.requestPin] 递增，供 View 用做 [Key] 重置输入框。
  final int attempt;
  final bool obscurePin;
  final bool isSubmitting;

  AppLockPinPromptState copyWith({
    String? errorMessage,
    bool? obscurePin,
    bool? isSubmitting,
    bool clearError = false,
  }) {
    return AppLockPinPromptState(
      reason: reason,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      attempt: attempt,
      obscurePin: obscurePin ?? this.obscurePin,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

/// 全局 PIN 输入请求控制器（MVVM-C 的 VM 层）。
///
/// 由 [BarrelLockIdentityAuthUiDelegate] 与 [AppLockSessionViewModel] 共同驱动：
/// - 身份验证需要 PIN 时 → [requestPin] 挂起等待用户输入
/// - 用户提交 / 取消 → [submitPin] / [cancel] 完成 [Future]
///
/// ## View 接入示例
///
/// ```dart
/// final prompt = ref.watch(appLockPinPromptProvider);
/// final vm = ref.read(appLockPinPromptProvider.notifier);
/// if (prompt != null) {
///   // 渲染 PIN 输入 UI，调用 vm.submitPin(text) / vm.cancel()
/// }
/// ```
final class AppLockPinPromptViewModel extends Notifier<AppLockPinPromptState?> {
  Completer<String?>? _completer;

  @override
  AppLockPinPromptState? build() => null;

  /// 显示 PIN 遮罩并等待用户输入；返回 `null` 表示取消。
  Future<String?> requestPin(
    IdentityAuthReason reason, {
    String? errorMessage,
  }) {
    _completer?.complete(null);
    _completer = Completer<String?>();
    state = AppLockPinPromptState(
      reason: reason,
      errorMessage: errorMessage,
      attempt: (state?.attempt ?? 0) + 1,
    );
    return _completer!.future;
  }

  /// 用户确认 PIN；空字符串会写入 [AppLockPinPromptState.errorMessage]。
  void submitPin(String pin) {
    if (state?.isSubmitting ?? false) {
      return;
    }
    final trimmed = pin.trim();
    if (trimmed.isEmpty) {
      state = state?.copyWith(errorMessage: '请输入密码');
      return;
    }
    state = state?.copyWith(isSubmitting: true, clearError: true);
    final completer = _completer;
    _completer = null;
    completer?.complete(trimmed);
  }

  /// 用户取消输入。
  void cancel() {
    _completer?.complete(null);
    dismiss();
  }

  /// 关闭遮罩并清理挂起的 Completer。
  void dismiss() {
    _completer = null;
    state = null;
  }

  void toggleObscure() {
    final current = state;
    if (current == null || current.isSubmitting) {
      return;
    }
    state = current.copyWith(obscurePin: !current.obscurePin);
  }
}

final appLockPinPromptProvider =
    NotifierProvider<AppLockPinPromptViewModel, AppLockPinPromptState?>(
      AppLockPinPromptViewModel.new,
    );

/// 兼容旧代码中对 Notifier 类型的引用。
typedef AppLockPinPromptNotifier = AppLockPinPromptViewModel;
