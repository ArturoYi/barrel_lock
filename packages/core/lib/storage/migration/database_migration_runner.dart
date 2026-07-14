import 'package:drift/drift.dart';

import '../app_database.dart';

/// 单次 schema 升级步骤的抽象描述。
///
/// 每个版本对应一个 [MigrationStep]，便于阅读版本历史与单元测试。
abstract interface class MigrationStep {
  /// 升级完成后数据库应处于的目标版本。
  int get targetVersion;

  /// 一步升级逻辑；[Migrator] 由 Drift 在 [MigrationStrategy.onUpgrade] 中注入。
  Future<void> upgrade(Migrator migrator);
}

/// 按版本号顺序执行 schema 迁移。
///
/// 用法（已在 [AppDatabase.migration] 中接入）：
///
/// ```dart
/// onUpgrade: (m, from, to) => DatabaseMigrationRunner(db).run(m, from: from, to: to),
/// ```
final class DatabaseMigrationRunner {
  DatabaseMigrationRunner(AppDatabase db);

  /// 已注册的全部迁移步骤，**必须按 [MigrationStep.targetVersion] 升序排列**。
  static final List<MigrationStep> _steps = [_MigrationV2()];

  /// 从 [from] 逐步升级到 [to]（不含 [from]，含 [to]）。
  Future<void> run(
    Migrator migrator, {
    required int from,
    required int to,
  }) async {
    if (from >= to) return;

    for (final step in _steps) {
      if (step.targetVersion <= from || step.targetVersion > to) {
        continue;
      }
      await step.upgrade(migrator);
    }
  }
}

// ---------------------------------------------------------------------------
// 以下为各版本迁移实现；新增版本时在文件末尾追加 class，并登记到 [_steps]。
// ---------------------------------------------------------------------------

/// v2：移除 security_context 表。
final class _MigrationV2 implements MigrationStep {
  @override
  int get targetVersion => 2;

  @override
  Future<void> upgrade(Migrator migrator) async {
    await migrator.database.customStatement(
      'DROP TABLE IF EXISTS security_context',
    );
  }
}
