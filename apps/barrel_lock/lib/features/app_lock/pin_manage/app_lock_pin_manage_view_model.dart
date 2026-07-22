import 'package:core/core.dart';

import '../settings/app_lock_settings_view_model.dart';
import '../shared/coordinator/app_lock_coordinator.dart';
import '../shared/model/app_lock_auth_service.dart';
import '../shared/model/app_lock_preferences_repository.dart';
import '../shared/policy/app_lock_pin_policy.dart';

/// 应用内 PIN 管理子流程模式（UI 文案称「备用密码」）。
enum AppLockPinManageMode {
  /// 首次设置（尚未配置应用内 PIN）。
  setup,

  /// 已配置时的操作入口（修改 / 清除）。
  hub,

  /// 修改 PIN 表单。
  change,

  /// 清除 PIN 表单。
  clear,
}

/// 应用内 PIN 管理页展示状态（MVVM-C 的 VM 层输出）。
///
/// 展示字段 [hasFallbackPin] 与 [AppLockPreferences.hasFallbackPin] 同名；
/// 初始化时由 [AppLockAuthService.hasAppPin] 查询 Auth 层 SSOT。
final class AppLockPinManageState {
  const AppLockPinManageState({
    required this.mode,
    required this.hasFallbackPin,
    required this.isBusy,
    required this.obscureCurrentPin,
    required this.obscurePin,
    required this.obscureConfirmPin,
    this.errorMessage,
    this.canClearPin = true,
    this.clearBlockedReason,
  });

  /// 当前子流程；决定 View 渲染 setup / hub / change / clear 哪套表单。
  final AppLockPinManageMode mode;

  /// 是否已配置备用 PIN；与 [AppLockPreferences.hasFallbackPin] 对齐，来源 [AppLockAuthService.hasAppPin]。
  final bool hasFallbackPin;

  /// 保存 / 修改 / 清除 PIN 的异步操作是否进行中；为 true 时 View 应禁用提交。
  final bool isBusy;

  /// change / clear 模式下「当前 PIN」输入框是否遮蔽明文。
  final bool obscureCurrentPin;

  /// setup / change 模式下「新 PIN」输入框是否遮蔽明文。
  final bool obscurePin;

  /// setup / change 模式下「确认 PIN」输入框是否遮蔽明文。
  final bool obscureConfirmPin;

  /// 校验或操作失败时的提示文案；成功 pop 前由 ViewModel 清空。
  final String? errorMessage;

  /// 是否允许清除 PIN；锁屏保护已开启且无生物识别等备选解锁方式时为 false。
  final bool canClearPin;

  /// [canClearPin] 为 false 时的原因说明；点击「清除」时也会写入 [errorMessage] 展示。
  final String? clearBlockedReason;

  AppLockPinManageState copyWith({
    AppLockPinManageMode? mode,
    bool? hasFallbackPin,
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
      hasFallbackPin: hasFallbackPin ?? this.hasFallbackPin,
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

/// 应用内 PIN 管理页 ViewModel（MVVM-C 的 VM 层；路由入口文案为「备用密码」）。
///
/// PIN 明文由 View 层收集后通过方法参数传入；ViewModel 不持有 [TextEditingController]。
final class AppLockPinManageViewModel
    extends AsyncNotifier<AppLockPinManageState> {
  late final AppLockPreferencesRepository _preferencesRepository;
  late final AppLockCoordinatorGateway _coordinator;
  late final AppLockAuthService _authService;

  @override
  Future<AppLockPinManageState> build() async {
    _preferencesRepository = ref.read(appLockPreferencesRepositoryProvider);
    _coordinator = ref.read(appLockCoordinatorProvider);
    _authService = ref.read(appLockAuthServiceProvider);
    return _loadInitialState();
  }

  Future<AppLockPinManageState> _loadInitialState() async {
    final hasFallbackPin = await _authService.hasAppPin();
    final clearPolicy = await _resolveClearPolicy();
    return AppLockPinManageState(
      mode: hasFallbackPin
          ? AppLockPinManageMode.hub
          : AppLockPinManageMode.setup,
      hasFallbackPin: hasFallbackPin,
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
        mode: current.hasFallbackPin
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
    final validationError = AppLockPinPolicy.validateCurrentPin(currentPin);
    if (validationError != null) {
      _setError(validationError);
      return;
    }

    _setBusy(true);
    try {
      final valid = await _authService.verifyAppPin(currentPin.trim());
      if (!valid) {
        _setError('当前密码错误');
        return;
      }

      await _preferencesRepository.clearFallbackPin();
      ref.invalidate(appLockSettingsViewModelProvider);
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
    final validationError = isChange
        ? AppLockPinPolicy.validateChange(
            currentPin: currentPin,
            pin: pin,
            confirmPin: confirmPin,
          )
        : AppLockPinPolicy.validateSetup(pin: pin, confirmPin: confirmPin);
    if (validationError != null) {
      _setError(validationError);
      return;
    }

    _setBusy(true);
    try {
      if (isChange) {
        final valid = await _authService.verifyAppPin(currentPin.trim());
        if (!valid) {
          _setError('当前密码错误');
          return;
        }
      }

      await _preferencesRepository.saveFallbackPin(pin.trim());
      ref.invalidate(appLockSettingsViewModelProvider);
      _coordinator.pop();
    } on ArgumentError catch (error) {
      _setError(error.message?.toString() ?? '密码格式无效');
    } finally {
      _setBusy(false);
    }
  }

  Future<({bool canClear, String? reason})> _resolveClearPolicy() async {
    final preferences = await _preferencesRepository.load();
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
