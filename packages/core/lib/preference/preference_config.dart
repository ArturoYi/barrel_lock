/// SP 全局配置（架构常量层）
final class PreferenceConfig {
  PreferenceConfig._();

  static String _appNamespace = '';
  static String _envPrefix = '';
  static List<String> _managedKeys = const [];

  /// 完整 key 前缀，形如 `barrel_lock_prod_` 或 `barrel_lock_`
  static String get namespacePrefix {
    if (_appNamespace.isEmpty) {
      throw StateError(
        'PreferenceConfig 未初始化，请在 SPStorage.init 中传入 appNamespace',
      );
    }
    return _envPrefix.isEmpty
        ? '${_appNamespace}_'
        : '${_appNamespace}_$_envPrefix';
  }

  /// 受管 key 白名单，供 clearAll / exportAll 使用
  static List<String> get managedKeys => _managedKeys;

  /// 初始化命名空间与受管 key 白名单
  static void init({
    required String appNamespace,
    String env = 'prod',
    required List<String> managedKeys,
  }) {
    _appNamespace = appNamespace;
    _envPrefix = env.isEmpty ? '' : '${env}_';
    _managedKeys = List.unmodifiable(managedKeys);
  }

  /// 拼接带命名空间隔离的真实 key
  static String getRealKey(String rawKey) => '$namespacePrefix$rawKey';
}
