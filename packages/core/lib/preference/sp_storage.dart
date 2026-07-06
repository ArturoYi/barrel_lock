import 'package:shared_preferences/shared_preferences.dart';

import 'preference_config.dart';

/// 底层 SP 存储核心类，只封装原生能力，不掺杂业务
final class SPStorage {
  SPStorage._();

  static SharedPreferences? _instance;

  /// 初始化，App 启动时执行一次
  ///
  /// [appNamespace] 应用命名空间（如 `barrel_lock`），与 [env] 组合隔离 key
  /// [managedKeys] 受管 rawKey 白名单，clearAll / exportAll 仅操作这些 key
  static Future<void> init({
    required String appNamespace,
    String env = 'prod',
    required List<String> managedKeys,
  }) async {
    PreferenceConfig.init(
      appNamespace: appNamespace,
      env: env,
      managedKeys: managedKeys,
    );
    _instance = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _sp {
    if (_instance == null) {
      throw StateError('SPStorage 未初始化，请在 main 先执行 SPStorage.init()');
    }
    return _instance!;
  }

  // ===================== 基础读写封装（自动拼接命名空间前缀） =====================

  static Future<bool> setString(String rawKey, String value) {
    final key = PreferenceConfig.getRealKey(rawKey);
    return _sp.setString(key, value);
  }

  static String? getString(String rawKey) {
    final key = PreferenceConfig.getRealKey(rawKey);
    return _sp.getString(key);
  }

  static Future<bool> setBool(String rawKey, bool value) {
    final key = PreferenceConfig.getRealKey(rawKey);
    return _sp.setBool(key, value);
  }

  static bool getBool(String rawKey, {bool def = false}) {
    final key = PreferenceConfig.getRealKey(rawKey);
    return _sp.getBool(key) ?? def;
  }

  static Future<bool> setInt(String rawKey, int value) {
    final key = PreferenceConfig.getRealKey(rawKey);
    return _sp.setInt(key, value);
  }

  static int getInt(String rawKey, {int def = 0}) {
    final key = PreferenceConfig.getRealKey(rawKey);
    return _sp.getInt(key) ?? def;
  }

  static Future<bool> setDouble(String rawKey, double value) {
    final key = PreferenceConfig.getRealKey(rawKey);
    return _sp.setDouble(key, value);
  }

  static double getDouble(String rawKey, {double def = 0}) {
    final key = PreferenceConfig.getRealKey(rawKey);
    return _sp.getDouble(key) ?? def;
  }

  static Future<bool> setStringList(String rawKey, List<String> list) {
    final key = PreferenceConfig.getRealKey(rawKey);
    return _sp.setStringList(key, list);
  }

  static List<String> getStringList(String rawKey) {
    final key = PreferenceConfig.getRealKey(rawKey);
    return _sp.getStringList(key) ?? const [];
  }

  // ===================== 删除/清空 =====================

  static Future<bool> remove(String rawKey) {
    final key = PreferenceConfig.getRealKey(rawKey);
    return _sp.remove(key);
  }

  /// 仅清除受管 key 白名单内的数据，避免误删其他插件写入的数据
  static Future<void> clearAll() async {
    for (final rawKey in PreferenceConfig.managedKeys) {
      await remove(rawKey);
    }
  }

  /// 获取受管 key 白名单内的偏好数据，供导出使用
  static Map<String, Object> getAllAsMap() {
    final result = <String, Object>{};
    for (final rawKey in PreferenceConfig.managedKeys) {
      final storageKey = PreferenceConfig.getRealKey(rawKey);
      final value = _readValue(storageKey);
      if (value != null) {
        result[rawKey] = value;
      }
    }
    return result;
  }

  static Object? _readValue(String storageKey) {
    final string = _sp.getString(storageKey);
    if (string != null) {
      return string;
    }

    final boolValue = _sp.getBool(storageKey);
    if (boolValue != null) {
      return boolValue;
    }

    final intValue = _sp.getInt(storageKey);
    if (intValue != null) {
      return intValue;
    }

    final doubleValue = _sp.getDouble(storageKey);
    if (doubleValue != null) {
      return doubleValue;
    }

    final stringList = _sp.getStringList(storageKey);
    if (stringList != null) {
      return List<String>.from(stringList);
    }

    return null;
  }
}
