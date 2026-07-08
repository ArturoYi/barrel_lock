import 'dart:convert';

import 'package:core/core.dart';

import '../../../../crypto/barrel_lock_encrypted_storage.dart';
import '../../../../preference/barrel_lock_preference_keys.dart';
import 'app_lock_preferences.dart';

/// 锁屏保护偏好持久化（MVVM-C 的 M 层）。
///
/// 职责：
/// - 从加密存储读写 [AppLockPreferences]
/// - 不包含身份验证、导航或 UI 逻辑
///
/// ViewModel 通过 [appLockModelProvider] 注入；测试可直接 `const AppLockModel()` 实例化。
final class AppLockModel {
  const AppLockModel();

  /// 读取偏好；无记录时返回安全默认值（全部关闭）。
  Future<AppLockPreferences> load() async {
    final raw = await BarrelLockEncryptedStorage.getString(
      BarrelLockPreferenceKeys.appLockPreferences,
    );
    if (raw == null) {
      return const AppLockPreferences(
        enabled: false,
        useBiometricOnResume: true,
        hasFallbackPin: false,
      );
    }

    final map = jsonDecode(raw) as Map<String, dynamic>;
    return AppLockPreferences(
      enabled: map['enabled'] as bool? ?? false,
      useBiometricOnResume: map['useBiometricOnResume'] as bool? ?? true,
      hasFallbackPin: map['hasFallbackPin'] as bool? ?? false,
    );
  }

  /// 持久化偏好；调用方负责业务校验（如启用前须有解锁方式）。
  Future<void> save(AppLockPreferences preferences) async {
    final raw = jsonEncode({
      'enabled': preferences.enabled,
      'useBiometricOnResume': preferences.useBiometricOnResume,
      'hasFallbackPin': preferences.hasFallbackPin,
    });
    await BarrelLockEncryptedStorage.setString(
      BarrelLockPreferenceKeys.appLockPreferences,
      raw,
    );
  }
}

final appLockModelProvider = Provider<AppLockModel>(
  (_) => const AppLockModel(),
);
