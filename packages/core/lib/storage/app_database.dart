import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'storage_config.dart';

part 'app_database.g.dart';

/// 应用顶层数据库：管理所有表、版本与迁移。
///
/// - Table：在 `lib/storage/tables/` 定义后登记到 [tables]
/// - 生成代码：运行 `dart run build_runner build` 产出 `app_database.g.dart`
/// - Stream：生成类提供 `select(table).watch()` 实时监听
/// - Migration：通过 [schemaVersion] 与 [migration] 处理版本升级
@DriftDatabase(
  tables: [
    // TODO: 实体表接入后在此登记，例如 TodoItems,
  ],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// 生产环境默认连接：全平台由 [driftDatabase] 自动选择实现。
  AppDatabase.defaults()
    : super(driftDatabase(name: StorageConfig.databaseFileName));

  /// 单元测试用内存库，不依赖 path_provider。
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // TODO: 按版本递增编写迁移，例如：
      // if (from < 2) await m.addColumn(todoItems, todoItems.priority);
    },
  );
}
