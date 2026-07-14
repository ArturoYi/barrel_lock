import 'package:drift/drift.dart';

/// 顶层保险库，支持多库隔离（个人 / 工作 / 家庭）。
@TableIndex(name: 'idx_vault_owner', columns: {#ownerAccountId})
class Vaults extends Table {
  @override
  String get tableName => 'vault';

  TextColumn get vaultUuid => text()();
  TextColumn get ownerAccountId => text().nullable()();
  BlobColumn get name => blob()();
  TextColumn get iconName => text().nullable()();
  TextColumn get colorHex => text().nullable()();
  BoolColumn get isPersonal => boolean().withDefault(const Constant(true))();
  BoolColumn get isTrashed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncRevision => dateTime()();
  BoolColumn get localModified => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {vaultUuid};
}
