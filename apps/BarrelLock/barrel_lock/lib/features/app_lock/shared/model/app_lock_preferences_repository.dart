import 'package:core/core.dart';

import 'app_lock_auth_service.dart';
import 'app_lock_model.dart';
import 'app_lock_preferences.dart';

/// 应用保护偏好读写网关（MVVM-C 的 M 层）。
///
/// - **持久化 SSOT**：仅 [AppLockModel] 存储 `enabled`
/// - **PIN SSOT**：仅 [AppLockAuthService] / [AppIdentityAuth] 存储哈希
/// - **读时派生**：[AppLockPreferences.hasFallbackPin] 由 [AppLockAuthService.hasAppPin] 派生
final class AppLockPreferencesRepository {
  const AppLockPreferencesRepository({
    required this._model,
    required this._authService,
  });

  final AppLockModel _model;
  final AppLockAuthService _authService;

  /// 加载偏好；`hasFallbackPin` 始终从 Auth 层实时派生。
  Future<AppLockPreferences> load() async {
    final enabled = await _model.loadEnabled();
    final hasFallbackPin = await _authService.hasAppPin();
    final fallbackPinHint = await _model.loadFallbackPinHint();
    return AppLockPreferences(
      enabled: enabled,
      hasFallbackPin: hasFallbackPin,
      fallbackPinHint: fallbackPinHint,
    );
  }

  /// 仅更新「是否启用应用保护」。
  Future<void> setEnabled(bool enabled) => _model.saveEnabled(enabled);

  /// 落盘 PIN、提示语并开启应用保护（开启验证流程成功路径）。
  Future<void> enableWithFallbackPin(
    String pin, {
    required String fallbackPinHint,
  }) async {
    await _authService.setupFallbackPin(pin);
    await _model.saveFallbackPinHint(fallbackPinHint.trim());
    await setEnabled(true);
  }

  /// 落盘或更新 PIN（不改动 enabled）。
  Future<void> saveFallbackPin(String pin) =>
      _authService.setupFallbackPin(pin);

  /// 清除 PIN（不改动 enabled）。
  Future<void> clearFallbackPin() => _authService.clearAppPin();
}

final appLockPreferencesRepositoryProvider =
    Provider<AppLockPreferencesRepository>((ref) {
      return AppLockPreferencesRepository(
        model: ref.watch(appLockModelProvider),
        authService: ref.watch(appLockAuthServiceProvider),
      );
    });
