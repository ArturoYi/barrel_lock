import 'package:core/core.dart';

import 'app_lock_auth_service.dart';
import 'app_lock_coordinator.dart';
import 'app_lock_model.dart';

/// 锁屏保护页展示状态。
final class AppLockViewState {
  const AppLockViewState({
    required this.preferences,
    required this.isLoading,
    required this.biometricAvailability,
    this.statusMessage,
  });

  final AppLockPreferences preferences;
  final bool isLoading;
  final BiometricAvailability biometricAvailability;
  final String? statusMessage;

  AppLockViewState copyWith({
    AppLockPreferences? preferences,
    bool? isLoading,
    BiometricAvailability? biometricAvailability,
    String? statusMessage,
    bool clearStatusMessage = false,
  }) {
    return AppLockViewState(
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

/// 锁屏保护页状态与业务编排（MVVM-C 的 VM 层）。
final class AppLockViewModel extends AsyncNotifier<AppLockViewState> {
  late final AppLockModel _model;
  late final AppLockCoordinatorGateway _coordinator;
  late final AppLockAuthService _authService;

  @override
  Future<AppLockViewState> build() async {
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

    if (!preferences.enabled &&
        preferences.useBiometricOnResume &&
        biometricAvailability != BiometricAvailability.available &&
        !hasPin) {
      // 无可用解锁方式时保持默认偏好即可。
    }

    return AppLockViewState(
      preferences: preferences,
      isLoading: false,
      biometricAvailability: biometricAvailability,
    );
  }

  void onPop() => _coordinator.pop();

  void onOpenPinManage() => _coordinator.openPinManage();

  Future<void> onEnabledChanged(bool enabled) async {
    final current = state.requireValue;
    if (enabled) {
      final canUnlock = await _authService.hasAnyUnlockMethod();
      if (!canUnlock) {
        state = AsyncData(
          current.copyWith(statusMessage: '请先设置备用密码，或在支持生物识别的设备上录入指纹/面容'),
        );
        return;
      }
    }

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

  Future<void> onBiometricOnResumeChanged(bool value) async {
    final current = state.requireValue;
    final updated = current.preferences.copyWith(useBiometricOnResume: value);
    state = AsyncData(current.copyWith(preferences: updated, isLoading: true));
    await _model.save(updated);
    state = AsyncData(current.copyWith(preferences: updated, isLoading: false));
  }
}

final appLockViewModelProvider =
    AsyncNotifierProvider<AppLockViewModel, AppLockViewState>(
      AppLockViewModel.new,
    );
