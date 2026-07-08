import 'package:core/core.dart';

import '../coordinator/app_lock_coordinator.dart';
import '../model/app_lock_auth_service.dart';
import '../model/app_lock_model.dart';

/// 锁屏保护设置页展示状态（MVVM-C 的 VM 层输出）。
///
/// View 通过 [appLockViewModelProvider] 监听此状态并渲染；用户操作转发给 [AppLockViewModel] 命令方法。
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

  /// 业务提示（如启用失败原因）；`null` 表示无提示。
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

/// 锁屏保护设置页 ViewModel（MVVM-C 的 VM 层）。
///
/// ## View 接入示例
///
/// ```dart
/// final state = ref.watch(appLockViewModelProvider);
/// final vm = ref.read(appLockViewModelProvider.notifier);
///
/// state.when(
///   loading: () => /* 加载中 */,
///   error: (e, _) => /* 错误 */,
///   data: (data) => Switch(
///     value: data.preferences.enabled,
///     onChanged: data.isLoading ? null : vm.onEnabledChanged,
///   ),
/// );
/// ```
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

    // 与 AppIdentityAuth 同步 hasFallbackPin 标记，修复外部清除 PIN 后的脏数据。
    final hasPin = await _authService.hasAppPin();
    if (preferences.hasFallbackPin != hasPin) {
      preferences = preferences.copyWith(hasFallbackPin: hasPin);
      await _model.save(preferences);
    }

    return AppLockViewState(
      preferences: preferences,
      isLoading: false,
      biometricAvailability: biometricAvailability,
    );
  }

  /// 返回上一页 → Coordinator.pop()
  void onPop() => _coordinator.pop();

  /// 进入备用密码管理 → Coordinator.openPinManage()
  void onOpenPinManage() => _coordinator.openPinManage();

  /// 切换「启用锁屏保护」。
  ///
  /// 开启前校验 [AppLockAuthService.hasAnyUnlockMethod]；失败时写入 [AppLockViewState.statusMessage]。
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

  /// 切换「回到前台时使用生物识别」。
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
