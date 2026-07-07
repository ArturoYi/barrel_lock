import 'dart:convert';

import 'package:core/core.dart';

import '../../crypto/barrel_lock_encrypted_storage.dart';
import '../../preference/barrel_lock_preference_keys.dart';

/// 锁屏保护页业务数据（MVVM-C 的 M 层）。
final class AppLockModel {
  const AppLockModel();

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

final class AppLockPreferences {
  const AppLockPreferences({
    required this.enabled,
    required this.useBiometricOnResume,
    required this.hasFallbackPin,
  });

  final bool enabled;
  final bool useBiometricOnResume;
  final bool hasFallbackPin;

  AppLockPreferences copyWith({
    bool? enabled,
    bool? useBiometricOnResume,
    bool? hasFallbackPin,
  }) {
    return AppLockPreferences(
      enabled: enabled ?? this.enabled,
      useBiometricOnResume: useBiometricOnResume ?? this.useBiometricOnResume,
      hasFallbackPin: hasFallbackPin ?? this.hasFallbackPin,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AppLockPreferences &&
        other.enabled == enabled &&
        other.useBiometricOnResume == useBiometricOnResume &&
        other.hasFallbackPin == hasFallbackPin;
  }

  @override
  int get hashCode =>
      Object.hash(enabled, useBiometricOnResume, hasFallbackPin);
}

final appLockModelProvider = Provider<AppLockModel>(
  (_) => const AppLockModel(),
);
