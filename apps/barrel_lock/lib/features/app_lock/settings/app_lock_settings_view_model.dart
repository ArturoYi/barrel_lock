import 'package:core/core.dart';

import '../enable_setup/app_lock_enable_setup_view_model.dart';
import '../session/app_lock_session_view_model.dart';
import '../shared/coordinator/app_lock_coordinator.dart';
import '../shared/model/app_lock_auth_service.dart';
import '../shared/model/app_lock_preferences.dart';
import '../shared/model/app_lock_preferences_repository.dart';

/// 应用保护设置页展示状态（MVVM-C 的 VM 层输出）。
final class AppLockSettingsViewState {
  const AppLockSettingsViewState({
    required this.preferences,
    required this.isLoading,
    this.statusMessage,
  });

  final AppLockPreferences preferences;
  final bool isLoading;
  final String? statusMessage;

  AppLockSettingsViewState copyWith({
    AppLockPreferences? preferences,
    bool? isLoading,
    String? statusMessage,
    bool clearStatusMessage = false,
  }) {
    return AppLockSettingsViewState(
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      statusMessage: clearStatusMessage
          ? null
          : (statusMessage ?? this.statusMessage),
    );
  }
}

/// 应用保护设置页 ViewModel（MVVM-C 的 VM 层）。
final class AppLockSettingsViewModel
    extends AsyncNotifier<AppLockSettingsViewState> {
  AppLockPreferencesRepository get _preferencesRepository =>
      ref.read(appLockPreferencesRepositoryProvider);

  AppLockCoordinatorGateway get _coordinator =>
      ref.read(appLockCoordinatorProvider);

  AppLockAuthService get _authService => ref.read(appLockAuthServiceProvider);

  @override
  Future<AppLockSettingsViewState> build() async {
    final preferences = await _preferencesRepository.load();
    return AppLockSettingsViewState(preferences: preferences, isLoading: false);
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
    await _preferencesRepository.setEnabled(enabled);
    state = AsyncData(current.copyWith(preferences: updated, isLoading: false));
  }
}

final appLockSettingsViewModelProvider =
    AsyncNotifierProvider<AppLockSettingsViewModel, AppLockSettingsViewState>(
      AppLockSettingsViewModel.new,
    );
