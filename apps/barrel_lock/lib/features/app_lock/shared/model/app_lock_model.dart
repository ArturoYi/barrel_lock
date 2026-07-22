import 'dart:convert';

import 'package:core/core.dart';

import '../../../../crypto/barrel_lock_encrypted_storage.dart';
import '../../../../preference/barrel_lock_preference_keys.dart';

/// 锁屏保护偏好持久化（MVVM-C 的 M 层）。
///
/// 仅持久化 `enabled`；PIN 状态由 [AppIdentityAuth] 管理。
/// 业务层请通过 [AppLockPreferencesRepository] 读取完整 [AppLockPreferences]。
final class AppLockModel {
  const AppLockModel();

  /// 读取是否启用应用保护；无记录时返回 `false`。
  Future<bool> loadEnabled() async {
    final map = await _loadPreferencesMap();
    return map['enabled'] as bool? ?? false;
  }

  /// 读取忘记密码提示语；无记录时返回 `null`。
  Future<String?> loadFallbackPinHint() async {
    final map = await _loadPreferencesMap();
    return map['fallbackPinHint'] as String?;
  }

  /// 持久化是否启用应用保护。
  Future<void> saveEnabled(bool enabled) async {
    final map = await _loadPreferencesMap();
    map['enabled'] = enabled;
    await _savePreferencesMap(map);
  }

  /// 持久化忘记密码提示语。
  Future<void> saveFallbackPinHint(String hint) async {
    final map = await _loadPreferencesMap();
    map['fallbackPinHint'] = hint;
    await _savePreferencesMap(map);
  }

  Future<Map<String, dynamic>> _loadPreferencesMap() async {
    final raw = await BarrelLockEncryptedStorage.getString(
      BarrelLockPreferenceKeys.appLockPreferences,
    );
    if (raw == null) {
      return <String, dynamic>{};
    }

    return Map<String, dynamic>.from(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> _savePreferencesMap(Map<String, dynamic> map) async {
    final raw = jsonEncode(map);
    await BarrelLockEncryptedStorage.setString(
      BarrelLockPreferenceKeys.appLockPreferences,
      raw,
    );
  }
}

final appLockModelProvider = Provider<AppLockModel>(
  (_) => const AppLockModel(),
);
