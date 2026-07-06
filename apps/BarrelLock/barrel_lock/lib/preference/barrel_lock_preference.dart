import 'package:core/core.dart';

import 'barrel_lock_preference_keys.dart';

/// BarrelLock 产品偏好存储门面。
final class BarrelLockPreference {
  BarrelLockPreference._();

  static Future<void> markFirstLaunch() =>
      SPStorage.setBool(BarrelLockPreferenceKeys.isFirstLaunch, false);

  static bool isFirstLaunch() =>
      SPStorage.getBool(BarrelLockPreferenceKeys.isFirstLaunch, def: true);
}
