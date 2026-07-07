import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_lock_auth_service.dart';
import 'app_lock_coordinator.dart';
import 'app_lock_model.dart';
import 'app_lock_view_model.dart';

/// 备用密码管理子流程。
enum AppLockPinManageMode {
  /// 首次设置。
  setup,

  /// 已设置时的操作入口。
  hub,

  /// 修改密码。
  change,

  /// 清除密码。
  clear,
}

/// PIN 管理页展示状态。
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

/// 备用密码管理页 ViewModel。
final class AppLockPinManageViewModel
    extends AsyncNotifier<AppLockPinManageState> {
  late final AppLockModel _model;
  late final AppLockCoordinatorGateway _coordinator;
  late final AppLockAuthService _authService;

  final currentPinController = TextEditingController();
  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();

  @override
  Future<AppLockPinManageState> build() async {
    _model = ref.read(appLockModelProvider);
    _coordinator = ref.read(appLockCoordinatorProvider);
    _authService = ref.read(appLockAuthServiceProvider);
    ref.onDispose(() {
      currentPinController.dispose();
      pinController.dispose();
      confirmPinController.dispose();
    });
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

  void onPop() {
    final current = state.requireValue;
    if (current.mode == AppLockPinManageMode.hub ||
        current.mode == AppLockPinManageMode.setup) {
      _coordinator.pop();
      return;
    }

    _clearInputFields();
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
    _clearInputFields();
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

    _clearInputFields();
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

  Future<void> savePin() => _saveOrChangePin(isChange: false);

  Future<void> changePin() => _saveOrChangePin(isChange: true);

  Future<void> clearPin() async {
    final currentPin = currentPinController.text.trim();
    if (currentPin.isEmpty) {
      _setError('请输入当前密码');
      return;
    }

    _setBusy(true);
    try {
      final valid = await AppIdentityAuth.verifyAppPin(currentPin);
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

  Future<void> _saveOrChangePin({required bool isChange}) async {
    final currentPin = currentPinController.text.trim();
    final pin = pinController.text.trim();
    final confirm = confirmPinController.text.trim();

    if (isChange && currentPin.isEmpty) {
      _setError('请输入当前密码');
      return;
    }
    if (pin.isEmpty || confirm.isEmpty) {
      _setError('请填写新密码');
      return;
    }
    if (pin != confirm) {
      _setError('两次输入不一致');
      return;
    }
    if (isChange && pin == currentPin) {
      _setError('新密码不能与当前密码相同');
      return;
    }

    _setBusy(true);
    try {
      if (isChange) {
        final valid = await AppIdentityAuth.verifyAppPin(currentPin);
        if (!valid) {
          _setError('当前密码错误');
          return;
        }
      }

      await _authService.setAppPin(pin);
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

  void _clearInputFields() {
    currentPinController.clear();
    pinController.clear();
    confirmPinController.clear();
  }
}

final appLockPinManageViewModelProvider =
    AsyncNotifierProvider<AppLockPinManageViewModel, AppLockPinManageState>(
      AppLockPinManageViewModel.new,
    );

/// 备用密码管理页（设置 / 修改 / 清除）。
final class AppLockPinManagePage extends ConsumerWidget {
  const AppLockPinManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appLockPinManageViewModelProvider);
    final viewModel = ref.read(appLockPinManageViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: viewModel.onPop),
        title: Text(_titleForMode(state.value?.mode)),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败：$error')),
        data: (data) => ListView(
          padding: const EdgeInsets.all(24),
          children: switch (data.mode) {
            AppLockPinManageMode.hub => _hubBody(context, data, viewModel),
            AppLockPinManageMode.setup => _setupBody(context, data, viewModel),
            AppLockPinManageMode.change => _changeBody(
              context,
              data,
              viewModel,
            ),
            AppLockPinManageMode.clear => _clearBody(context, data, viewModel),
          },
        ),
      ),
    );
  }

  static String _titleForMode(AppLockPinManageMode? mode) {
    return switch (mode) {
      AppLockPinManageMode.hub => '备用密码',
      AppLockPinManageMode.setup => '设置备用密码',
      AppLockPinManageMode.change => '修改备用密码',
      AppLockPinManageMode.clear => '清除备用密码',
      null => '备用密码',
    };
  }

  static List<Widget> _hubBody(
    BuildContext context,
    AppLockPinManageState data,
    AppLockPinManageViewModel viewModel,
  ) {
    return [
      Text(
        '备用密码已设置。修改或清除前需验证当前密码。',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      if (data.errorMessage != null) ...[
        const SizedBox(height: 12),
        Text(
          data.errorMessage!,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
      const SizedBox(height: 24),
      ListTile(
        leading: const Icon(Icons.edit_outlined),
        title: const Text('修改备用密码'),
        trailing: const Icon(Icons.chevron_right),
        onTap: data.isBusy ? null : viewModel.openChangeMode,
      ),
      ListTile(
        leading: Icon(
          Icons.delete_outline,
          color: data.canClearPin
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          '清除备用密码',
          style: TextStyle(
            color: data.canClearPin
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: data.canClearPin
            ? null
            : Text(
                data.clearBlockedReason ?? '',
                style: Theme.of(context).textTheme.bodySmall,
              ),
        trailing: const Icon(Icons.chevron_right),
        enabled: !data.isBusy,
        onTap: data.isBusy ? null : viewModel.openClearMode,
      ),
    ];
  }

  static List<Widget> _setupBody(
    BuildContext context,
    AppLockPinManageState data,
    AppLockPinManageViewModel viewModel,
  ) {
    return [
      Text(
        '当设备不支持或未开启生物识别时，使用此密码解锁应用。',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 24),
      ..._newPinFields(data, viewModel),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: data.isBusy ? null : viewModel.savePin,
        child: _actionChild(data.isBusy, '保存'),
      ),
    ];
  }

  static List<Widget> _changeBody(
    BuildContext context,
    AppLockPinManageState data,
    AppLockPinManageViewModel viewModel,
  ) {
    return [
      ..._currentPinField(data, viewModel),
      const SizedBox(height: 16),
      ..._newPinFields(data, viewModel),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: data.isBusy ? null : viewModel.changePin,
        child: _actionChild(data.isBusy, '保存新密码'),
      ),
    ];
  }

  static List<Widget> _clearBody(
    BuildContext context,
    AppLockPinManageState data,
    AppLockPinManageViewModel viewModel,
  ) {
    return [
      Text(
        '清除后，若生物识别不可用，将无法使用锁屏保护。',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      ),
      const SizedBox(height: 24),
      ..._currentPinField(data, viewModel),
      const SizedBox(height: 24),
      FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
        ),
        onPressed: data.isBusy ? null : viewModel.clearPin,
        child: _actionChild(data.isBusy, '确认清除'),
      ),
    ];
  }

  static List<Widget> _currentPinField(
    AppLockPinManageState data,
    AppLockPinManageViewModel viewModel,
  ) {
    return [
      TextField(
        controller: viewModel.currentPinController,
        obscureText: data.obscureCurrentPin,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: '当前密码',
          errorText: data.errorMessage,
          suffixIcon: IconButton(
            onPressed: viewModel.toggleObscureCurrentPin,
            icon: Icon(
              data.obscureCurrentPin
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
      ),
    ];
  }

  static List<Widget> _newPinFields(
    AppLockPinManageState data,
    AppLockPinManageViewModel viewModel,
  ) {
    return [
      TextField(
        controller: viewModel.pinController,
        obscureText: data.obscurePin,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: '新密码',
          suffixIcon: IconButton(
            onPressed: viewModel.toggleObscurePin,
            icon: Icon(
              data.obscurePin
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: viewModel.confirmPinController,
        obscureText: data.obscureConfirmPin,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: '确认新密码',
          errorText: data.mode == AppLockPinManageMode.setup
              ? data.errorMessage
              : null,
          suffixIcon: IconButton(
            onPressed: viewModel.toggleObscureConfirmPin,
            icon: Icon(
              data.obscureConfirmPin
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
        onSubmitted: (_) {
          if (!data.isBusy) {
            if (data.mode == AppLockPinManageMode.setup) {
              viewModel.savePin();
            } else {
              viewModel.changePin();
            }
          }
        },
      ),
      if (data.mode == AppLockPinManageMode.change &&
          data.errorMessage != null) ...[
        const SizedBox(height: 8),
        Text(data.errorMessage!, style: const TextStyle(color: Colors.red)),
      ],
    ];
  }

  static Widget _actionChild(bool isBusy, String label) {
    if (isBusy) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Text(label);
  }
}

/// 兼容旧路由装配名称。
typedef AppLockPinSetupPage = AppLockPinManagePage;
