import 'preference_keys.dart';
import 'sp_storage.dart';

/// 应用全局偏好存储门面，业务层唯一调用入口
///
/// 所有页面 / Provider 只依赖此类，不直接接触 [SPStorage]
final class AppPreference {
  AppPreference._();

  static Future<void> setThemeMode(String mode) =>
      SPStorage.setString(PreferenceKeys.themeMode, mode);

  static String getThemeMode() =>
      SPStorage.getString(PreferenceKeys.themeMode) ?? 'system';

  static Future<void> setColorScheme(String scheme) =>
      SPStorage.setString(PreferenceKeys.colorScheme, scheme);

  static String? getColorScheme() =>
      SPStorage.getString(PreferenceKeys.colorScheme);

  static Future<void> markFirstLaunch() =>
      SPStorage.setBool(PreferenceKeys.isFirstLaunch, false);

  static bool isFirstLaunch() =>
      SPStorage.getBool(PreferenceKeys.isFirstLaunch, def: true);

  static Future<void> clearAllPreference() => SPStorage.clearAll();

  static Future<void> removeByKey(String rawKey) => SPStorage.remove(rawKey);

  static Map<String, Object> exportAll() => SPStorage.getAllAsMap();
}
