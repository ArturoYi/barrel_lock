import 'package:core/core.dart';

/// 锁屏保护页业务数据（MVVM-C 的 M 层）。
final class AppLockModel {
  const AppLockModel();

  Future<AppLockPreferences> load() async {
    // 后续接入加密存储；当前返回默认值。
    return const AppLockPreferences(
      enabled: false,
      useBiometricOnResume: true,
      hasFallbackPin: false,
    );
  }

  Future<void> save(AppLockPreferences preferences) async {}
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
}

final appLockModelProvider = Provider<AppLockModel>(
  (_) => const AppLockModel(),
);
