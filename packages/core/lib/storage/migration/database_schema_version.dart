/// 数据库 schema 版本号与变更记录。
///
/// ## 版本历史
///
/// | 版本 | 变更 |
/// |:----:|------|
/// | 1 | 初始结构：security_context、vault、folder、cipher、cipher_attachment、backup_log |
/// | 2 | 移除 security_context（密钥改由 App 层 [AppCrypto] 固定注入，不入库） |
///
/// ## 如何新增迁移
///
/// 1. 在 `tables/` 修改或新增表定义
/// 2. 将 [current] 加 1
/// 3. 在 [DatabaseMigrationRunner] 的 `_steps` 末尾追加对应 [MigrationStep]
/// 4. 运行 `dart run build_runner build --delete-conflicting-outputs`
/// 5. 在 `test/storage/database_migration_test.dart` 补充升级用例
abstract final class DatabaseSchemaVersion {
  /// 当前线上 schema 版本，与 [AppDatabase.schemaVersion] 保持一致。
  static const int current = 1;

  /// 首个正式版本号。
  static const int initial = 1;
}
