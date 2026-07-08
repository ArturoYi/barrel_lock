import 'package:core/core.dart';

import '../enable_setup/app_lock_enable_setup_view_model.dart';
import '../session/app_lock_session_view_model.dart';
import '../shared/coordinator/app_lock_coordinator.dart';
import '../shared/model/app_lock_auth_service.dart';
import '../shared/model/app_lock_model.dart';
import '../shared/model/app_lock_preferences.dart';

/// 应用保护设置页展示状态（MVVM-C 的 VM 层输出）。
final class AppLockSettingsViewState {
  const AppLockSettingsViewState({
    required this.preferences,
    required this.isLoading,
    required this.biometricAvailability,
    this.statusMessage,
  });

  final AppLockPreferences preferences;
  final bool isLoading;
  final BiometricAvailability biometricAvailability;
  final String? statusMessage;

  AppLockSettingsViewState copyWith({
    AppLockPreferences? preferences,
    bool? isLoading,
    BiometricAvailability? biometricAvailability,
    String? statusMessage,
    bool clearStatusMessage = false,
  }) {
    return AppLockSettingsViewState(
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      biometricAvailability:
          biometricAvailability ?? this.biometricAvailability,
      statusMessage: clearStatusMessage
          ? null
          : (statusMessage ?? this.statusMessage),
    );
  }
}

/// 应用保护设置页 ViewModel（MVVM-C 的 VM 层）。
final class AppLockSettingsViewModel
    extends AsyncNotifier<AppLockSettingsViewState> {
  late final AppLockModel _model;
  late final AppLockCoordinatorGateway _coordinator;
  late final AppLockAuthService _authService;

  @override
  Future<AppLockSettingsViewState> build() async {
    _model = ref.read(appLockModelProvider);
    _coordinator = ref.read(appLockCoordinatorProvider);
    _authService = ref.read(appLockAuthServiceProvider);

    final biometricAvailability = await _authService
        .checkBiometricAvailability();
    var preferences = await _model.load();

    final hasPin = await _authService.hasAppPin();
    if (preferences.hasFallbackPin != hasPin) {
      preferences = preferences.copyWith(hasFallbackPin: hasPin);
      await _model.save(preferences);
    }

    return AppLockSettingsViewState(
      preferences: preferences,
      isLoading: false,
      biometricAvailability: biometricAvailability,
    );
  }

  void onPop() {
    ref.read(appLockEnableSetupProvider.notifier).cancel();
    _coordinator.pop();
  }

  void onOpenPinManage() => _coordinator.openPinManage();

  /// 切换「启用应用保护」。
  ///
  /// 规则 A：无 PIN 时委托 [AppLockEnableSetupViewModel.begin]，不直接写入 enabled。
  Future<void> onEnabledChanged(bool enabled) async {
    if (!enabled) {
      ref.read(appLockEnableSetupProvider.notifier).cancel();
      await _persistEnabled(false);
      return;
    }

    if (!await _authService.hasAppPin()) {
      ref.read(appLockEnableSetupProvider.notifier).begin();
      return;
    }

    await _persistEnabled(true);
    await ref.read(appLockSessionProvider.notifier).lockAfterEnabled();
  }

  Future<void> onBiometricOnResumeChanged(bool value) async {
    final current = state.requireValue;
    final updated = current.preferences.copyWith(useBiometricOnResume: value);
    state = AsyncData(current.copyWith(preferences: updated, isLoading: true));
    await _model.save(updated);
    state = AsyncData(current.copyWith(preferences: updated, isLoading: false));
  }

  Future<void> _persistEnabled(bool enabled) async {
    final current = state.requireValue;
    final updated = current.preferences.copyWith(enabled: enabled);
    state = AsyncData(
      current.copyWith(
        preferences: updated,
        isLoading: true,
        clearStatusMessage: true,
      ),
    );
    await _model.save(updated);
    state = AsyncData(current.copyWith(preferences: updated, isLoading: false));
  }
}

final appLockSettingsViewModelProvider =
    AsyncNotifierProvider<AppLockSettingsViewModel, AppLockSettingsViewState>(
      AppLockSettingsViewModel.new,
    );

/// 兼容旧名称。
typedef AppLockViewState = AppLockSettingsViewState;

typedef AppLockViewModel = AppLockSettingsViewModel;

final appLockViewModelProvider = appLockSettingsViewModelProvider;
