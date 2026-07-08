import 'package:core/core.dart';

import '../settings/app_lock_settings_view_model.dart';
import '../shared/coordinator/app_lock_coordinator.dart';
import '../shared/model/app_lock_auth_service.dart';
import '../shared/model/app_lock_model.dart';

/// 备用密码管理子流程模式。
enum AppLockPinManageMode {
  /// 首次设置（尚无 PIN）。
  setup,

  /// 已设置时的操作入口（修改 / 清除）。
  hub,

  /// 修改密码表单。
  change,

  /// 清除密码表单。
  clear,
}

/// 备用密码管理页展示状态（MVVM-C 的 VM 层输出）。
final class AppLockPinManageState {
  const AppLockPinManageState({
    required this.mode,
    required this.hasPin,
    required this.isBusy,
    required this.obscureCurrentPin,
    required this.obscurePin,
    required this.obscureConfirmPin,
    this.errorMessage,
    this.canClearPin = true,
    this.clearBlockedReason,
  });

  final AppLockPinManageMode mode;
  final bool hasPin;
  final bool isBusy;
  final bool obscureCurrentPin;
  final bool obscurePin;
  final bool obscureConfirmPin;
  final String? errorMessage;
  final bool canClearPin;
  final String? clearBlockedReason;

  AppLockPinManageState copyWith({
    AppLockPinManageMode? mode,
    bool? hasPin,
    bool? isBusy,
    bool? obscureCurrentPin,
    bool? obscurePin,
    bool? obscureConfirmPin,
    String? errorMessage,
    bool? canClearPin,
    String? clearBlockedReason,
    bool clearError = false,
    bool clearClearBlockedReason = false,
  }) {
    return AppLockPinManageState(
      mode: mode ?? this.mode,
      hasPin: hasPin ?? this.hasPin,
      isBusy: isBusy ?? this.isBusy,
      obscureCurrentPin: obscureCurrentPin ?? this.obscureCurrentPin,
      obscurePin: obscurePin ?? this.obscurePin,
      obscureConfirmPin: obscureConfirmPin ?? this.obscureConfirmPin,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      canClearPin: canClearPin ?? this.canClearPin,
      clearBlockedReason: clearClearBlockedReason
          ? null
          : (clearBlockedReason ?? this.clearBlockedReason),
    );
  }
}

/// 备用密码管理页 ViewModel（MVVM-C 的 VM 层）。
///
/// PIN 明文由 View 层收集后通过方法参数传入；ViewModel 不持有 [TextEditingController]。
///
/// ## View 接入示例
///
/// ```dart
/// final vm = ref.read(appLockPinManageViewModelProvider.notifier);
/// await vm.savePin(pin: pinController.text, confirmPin: confirmController.text);
/// ```
final class AppLockPinManageViewModel
    extends AsyncNotifier<AppLockPinManageState> {
  late final AppLockModel _model;
  late final AppLockCoordinatorGateway _coordinator;
  late final AppLockAuthService _authService;

  @override
  Future<AppLockPinManageState> build() async {
    _model = ref.read(appLockModelProvider);
    _coordinator = ref.read(appLockCoordinatorProvider);
    _authService = ref.read(appLockAuthServiceProvider);
    return _loadInitialState();
  }

  Future<AppLockPinManageState> _loadInitialState() async {
    final hasPin = await _authService.hasAppPin();
    final clearPolicy = await _resolveClearPolicy();
    return AppLockPinManageState(
      mode: hasPin ? AppLockPinManageMode.hub : AppLockPinManageMode.setup,
      hasPin: hasPin,
      isBusy: false,
      obscureCurrentPin: true,
      obscurePin: true,
      obscureConfirmPin: true,
      canClearPin: clearPolicy.canClear,
      clearBlockedReason: clearPolicy.reason,
    );
  }

  /// 处理返回：hub/setup 时 pop；子表单时退回 hub/setup。
  void onPop() {
    final current = state.requireValue;
    if (current.mode == AppLockPinManageMode.hub ||
        current.mode == AppLockPinManageMode.setup) {
      _coordinator.pop();
      return;
    }

    state = AsyncData(
      current.copyWith(
        mode: current.hasPin
            ? AppLockPinManageMode.hub
            : AppLockPinManageMode.setup,
        clearError: true,
        clearClearBlockedReason: true,
      ),
    );
  }

  void openChangeMode() {
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(mode: AppLockPinManageMode.change, clearError: true),
    );
  }

  void openClearMode() {
    final current = state.requireValue;
    if (!current.canClearPin) {
      state = AsyncData(
        current.copyWith(errorMessage: current.clearBlockedReason),
      );
      return;
    }

    state = AsyncData(
      current.copyWith(mode: AppLockPinManageMode.clear, clearError: true),
    );
  }

  void toggleObscureCurrentPin() {
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(obscureCurrentPin: !current.obscureCurrentPin),
    );
  }

  void toggleObscurePin() {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(obscurePin: !current.obscurePin));
  }

  void toggleObscureConfirmPin() {
    final current = state.requireValue;
    state = AsyncData(
      current.copyWith(obscureConfirmPin: !current.obscureConfirmPin),
    );
  }

  /// 首次设置 PIN。
  Future<void> savePin({required String pin, required String confirmPin}) =>
      _saveOrChangePin(isChange: false, pin: pin, confirmPin: confirmPin);

  /// 修改 PIN（需验证当前密码）。
  Future<void> changePin({
    required String currentPin,
    required String pin,
    required String confirmPin,
  }) => _saveOrChangePin(
    isChange: true,
    currentPin: currentPin,
    pin: pin,
    confirmPin: confirmPin,
  );

  /// 清除 PIN（需验证当前密码）。
  Future<void> clearPin({required String currentPin}) async {
    final trimmedCurrent = currentPin.trim();
    if (trimmedCurrent.isEmpty) {
      _setError('请输入当前密码');
      return;
    }

    _setBusy(true);
    try {
      final valid = await _authService.verifyAppPin(trimmedCurrent);
      if (!valid) {
        _setError('当前密码错误');
        return;
      }

      await _authService.clearAppPin();
      final preferences = await _model.load();
      await _model.save(preferences.copyWith(hasFallbackPin: false));
      ref.invalidate(appLockViewModelProvider);
      _coordinator.pop();
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _saveOrChangePin({
    required bool isChange,
    String currentPin = '',
    required String pin,
    required String confirmPin,
  }) async {
    final trimmedCurrent = currentPin.trim();
    final trimmedPin = pin.trim();
    final trimmedConfirm = confirmPin.trim();

    if (isChange && trimmedCurrent.isEmpty) {
      _setError('请输入当前密码');
      return;
    }
    if (trimmedPin.isEmpty || trimmedConfirm.isEmpty) {
      _setError('请填写新密码');
      return;
    }
    if (trimmedPin != trimmedConfirm) {
      _setError('两次输入不一致');
      return;
    }
    if (isChange && trimmedPin == trimmedCurrent) {
      _setError('新密码不能与当前密码相同');
      return;
    }

    _setBusy(true);
    try {
      if (isChange) {
        final valid = await _authService.verifyAppPin(trimmedCurrent);
        if (!valid) {
          _setError('当前密码错误');
          return;
        }
      }

      await _authService.setAppPin(trimmedPin);
      final preferences = await _model.load();
      await _model.save(preferences.copyWith(hasFallbackPin: true));
      ref.invalidate(appLockViewModelProvider);
      _coordinator.pop();
    } on ArgumentError catch (error) {
      _setError(error.message?.toString() ?? '密码格式无效');
    } finally {
      _setBusy(false);
    }
  }

  Future<({bool canClear, String? reason})> _resolveClearPolicy() async {
    final preferences = await _model.load();
    if (!preferences.enabled) {
      return (canClear: true, reason: null);
    }

    final availability = await _authService.checkBiometricAvailability();
    if (availability == BiometricAvailability.available) {
      return (canClear: true, reason: null);
    }

    return (canClear: false, reason: '锁屏保护已开启且无其他解锁方式，请先关闭锁屏保护或启用生物识别');
  }

  void _setBusy(bool isBusy) {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(isBusy: isBusy));
  }

  void _setError(String message) {
    final current = state.requireValue;
    state = AsyncData(current.copyWith(isBusy: false, errorMessage: message));
  }
}

final appLockPinManageViewModelProvider =
    AsyncNotifierProvider<AppLockPinManageViewModel, AppLockPinManageState>(
      AppLockPinManageViewModel.new,
    );
