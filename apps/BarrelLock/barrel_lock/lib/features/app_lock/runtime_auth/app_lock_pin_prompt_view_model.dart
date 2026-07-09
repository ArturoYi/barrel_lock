/// 运行时解锁 PIN 请求控制器（`runtime_auth/` 子域）。
///
/// 提供全局、与路由无关的 PIN 输入状态机：业务层通过 `Future` 挂起等待用户输入，
/// [overlay](../overlay/) 层监听 [appLockPinPromptProvider] 渲染遮罩 UI。
///
/// 详见同目录 [BarrelLockIdentityAuthUiDelegate] 中的调用链说明。
library;

import 'dart:async';

import 'package:core/core.dart';

/// 全局 PIN 输入遮罩的只读状态（MVVM-C 的 VM 层输出）。
///
/// Provider 值为 `null` 表示遮罩未显示；非 `null` 时 overlay 应渲染 PIN 输入 UI。
/// 字段由 [AppLockPinPromptViewModel] 维护，View 只读并转发用户事件到 notifier。
final class AppLockPinPromptState {
  const AppLockPinPromptState({
    required this.reason,
    required this.errorMessage,
    required this.attempt,
    this.obscurePin = true,
    this.isSubmitting = false,
  });

  /// 触发本次 PIN 请求的业务场景（标题 / 副文案可参考 [IdentityAuthReason.defaultMessage]）。
  final IdentityAuthReason reason;

  /// 校验失败或空输入时的提示；`null` 表示无错误。
  final String? errorMessage;

  /// 每次 [AppLockPinPromptViewModel.requestPin] 递增，供 View 用做 [Key] 重置输入框。
  final int attempt;

  /// 是否遮蔽 PIN 明文（由 [AppLockPinPromptViewModel.toggleObscure] 切换）。
  final bool obscurePin;

  /// 用户已提交、等待校验方消费 PIN 时为 `true`；应禁用输入与确认按钮。
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
/// 通过内部 [Completer] 将异步 UI 交互桥接为 `Future<String?>`：
///
/// | 驱动方 | 调用 |
/// |--------|------|
/// | [BarrelLockIdentityAuthUiDelegate] | 生物识别不可用或需 PIN 时 [requestPin] |
/// | [AppLockSessionViewModel] | 验证失败后 PIN 重试循环 [requestPin]；成功后 [dismiss] |
/// | overlay View | [submitPin] / [cancel] / [toggleObscure] |
///
/// [requestPin] 若已有挂起请求会先以 `null` 完成旧 Completer，再展示新遮罩。
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
  /// 与当前遮罩绑定的挂起 Future；[dismiss] 或新 [requestPin] 时置空。
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

  /// 用户确认 PIN。
  ///
  /// 空或纯空白输入会写入 [AppLockPinPromptState.errorMessage] 并保持遮罩；
  /// 非空则设置 [AppLockPinPromptState.isSubmitting] 并完成 Completer，由调用方校验。
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

  /// 用户取消输入：完成 Completer 为 `null` 并 [dismiss] 遮罩。
  void cancel() {
    _completer?.complete(null);
    dismiss();
  }

  /// 关闭遮罩并清理挂起的 Completer。
  void dismiss() {
    _completer = null;
    state = null;
  }

  /// 切换 PIN 明文 / 密文显示；提交中或无遮罩时不生效。
  void toggleObscure() {
    final current = state;
    if (current == null || current.isSubmitting) {
      return;
    }
    state = current.copyWith(obscurePin: !current.obscurePin);
  }
}

/// 全局 PIN 遮罩状态；挂载于 [AppLockOverlay] 的 overlay 层与各认证 ViewModel。
final appLockPinPromptProvider =
    NotifierProvider<AppLockPinPromptViewModel, AppLockPinPromptState?>(
      AppLockPinPromptViewModel.new,
    );

/// 兼容旧代码中对 Notifier 类型的引用。
typedef AppLockPinPromptNotifier = AppLockPinPromptViewModel;
