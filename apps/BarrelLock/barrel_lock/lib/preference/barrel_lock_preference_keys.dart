/// BarrelLock 产品层 SP Key 常量
final class BarrelLockPreferenceKeys {
  BarrelLockPreferenceKeys._();

  static const String isFirstLaunch = 'is_first_launch';

  /// 锁屏偏好（加密 JSON）。
  static const String appLockPreferences = 'app_lock_preferences';

  static const List<String> allKeys = [isFirstLaunch, appLockPreferences];
}
