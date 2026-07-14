import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'migration/database_migration_runner.dart';
import 'migration/database_schema_version.dart';
import 'storage_config.dart';
import 'tables/tables.dart';

part 'app_database.g.dart';

/// 应用顶层数据库：管理所有表、版本与迁移。
///
/// - Table：在 `lib/storage/tables/` 定义后登记到 [tables]
/// - 生成代码：运行 `dart run build_runner build` 产出 `app_database.g.dart`
/// - Stream：生成类提供 `select(table).watch()` 实时监听
/// - Migration：通过 [schemaVersion] 与 [migration] 处理版本升级
@DriftDatabase(
  tables: [Vaults, Folders, CipherEntries, CipherAttachments, BackupLogs],
)
final class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// 生产环境默认连接：全平台由 [driftDatabase] 自动选择实现。
  AppDatabase.defaults()
    : super(driftDatabase(name: StorageConfig.databaseFileName));

  /// 单元测试用内存库，不依赖 path_provider。
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => DatabaseSchemaVersion.current;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      if (details.wasCreated) {
        // 新库已在 onCreate 中启用外键；此处确保升级路径同样生效。
      }
      await customStatement('PRAGMA foreign_keys = ON');
    },
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      await DatabaseMigrationRunner(this).run(m, from: from, to: to);
    },
  );
}
