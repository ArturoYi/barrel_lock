import 'app_database.dart';
import 'storage_config.dart';

/// 全局数据库单例入口，App 启动时初始化一次。
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await AppStorage.init(appNamespace: 'barrel_lock');
///   runApp(const ProviderScope(child: MyApp()));
/// }
///
/// // 业务层通过 AppStorage.database 访问 Drift 生成 API
/// final db = AppStorage.database;
/// ```
final class AppStorage {
  AppStorage._();

  static AppDatabase? _database;

  /// 初始化全局数据库单例。
  ///
  /// [appNamespace] 应用命名空间，与 SP 存储隔离策略一致
  /// [env] 环境标识（如 prod / test），用于数据库文件名隔离
  static Future<void> init({
    required String appNamespace,
    String env = 'prod',
  }) async {
    StorageConfig.init(appNamespace: appNamespace, env: env);
    _database = AppDatabase.defaults();
  }

  static AppDatabase get database {
    if (_database == null) {
      throw StateError('AppStorage 未初始化，请在 main 先执行 AppStorage.init()');
    }
    return _database!;
  }

  /// 关闭连接并释放单例，通常用于测试 teardown 或进程退出前。
  static Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  /// 测试专用：注入内存数据库，跳过 [driftDatabase] 平台路径。
  static Future<void> initForTesting({String env = 'test'}) async {
    StorageConfig.init(appNamespace: 'test_app', env: env);
    _database = AppDatabase.memory();
  }
}
