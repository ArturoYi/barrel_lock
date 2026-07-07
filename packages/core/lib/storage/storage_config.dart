/// 数据库存储配置，与 [SPStorage] 的命名空间策略对齐。
final class StorageConfig {
  StorageConfig._();

  static String? _appNamespace;
  static String _env = 'prod';

  /// 初始化存储命名空间，[AppStorage.init] 启动时执行一次。
  static void init({required String appNamespace, String env = 'prod'}) {
    _appNamespace = appNamespace;
    _env = env;
  }

  static String get appNamespace {
    if (_appNamespace == null) {
      throw StateError('StorageConfig 未初始化，请在 main 先执行 AppStorage.init()');
    }
    return _appNamespace!;
  }

  static String get env => _env;

  /// SQLite 文件名（不含路径），实际路径由 [drift_flutter] 按平台解析。
  ///
  /// 格式：`{namespace}_{env}.sqlite`
  static String get databaseFileName => '${appNamespace}_$_env';

  /// Web 端需在各平台 app 的 `web/` 目录放置 `sqlite3.wasm` 与 `drift_worker.js`。
  /// 参见 https://drift.simonbinder.eu/platforms/web/
  static const bool requiresWebAssets = true;
}
