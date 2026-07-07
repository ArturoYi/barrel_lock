import 'package:core/core.dart';

import 'app_lock_coordinator.dart';
import 'app_lock_model.dart';

/// 锁屏保护页展示状态。
final class AppLockViewState {
  const AppLockViewState({required this.preferences, required this.isLoading});

  final AppLockPreferences preferences;
  final bool isLoading;
}

/// 锁屏保护页状态与业务编排（MVVM-C 的 VM 层）。
final class AppLockViewModel extends AsyncNotifier<AppLockViewState> {
  late final AppLockModel _model;
  late final AppLockCoordinator _coordinator;

  @override
  Future<AppLockViewState> build() async {
    _model = ref.read(appLockModelProvider);
    _coordinator = ref.read(appLockCoordinatorProvider);
    final preferences = await _model.load();
    return AppLockViewState(preferences: preferences, isLoading: false);
  }

  void onPop() => _coordinator.pop();

  Future<void> onEnabledChanged(bool enabled) async {
    final current = state.requireValue;
    final updated = current.preferences.copyWith(enabled: enabled);
    state = AsyncData(AppLockViewState(preferences: updated, isLoading: true));
    await _model.save(updated);
    state = AsyncData(AppLockViewState(preferences: updated, isLoading: false));
  }

  Future<void> onBiometricOnResumeChanged(bool value) async {
    final current = state.requireValue;
    final updated = current.preferences.copyWith(useBiometricOnResume: value);
    state = AsyncData(AppLockViewState(preferences: updated, isLoading: true));
    await _model.save(updated);
    state = AsyncData(AppLockViewState(preferences: updated, isLoading: false));
  }
}

final appLockViewModelProvider =
    AsyncNotifierProvider<AppLockViewModel, AppLockViewState>(
      AppLockViewModel.new,
    );
