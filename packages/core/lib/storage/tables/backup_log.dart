import 'package:drift/drift.dart';

/// 本地加密备份导出日志。
class BackupLogs extends Table {
  @override
  String get tableName => 'backup_log';

  TextColumn get logId => text()();
  DateTimeColumn get backupTime => dateTime()();
  TextColumn get backupPath => text().nullable()();
  BlobColumn get backupPasswordSalt => blob()();
  IntColumn get vaultVersion => integer()();
  BoolColumn get isEncrypted => boolean().withDefault(const Constant(true))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {logId};
}
