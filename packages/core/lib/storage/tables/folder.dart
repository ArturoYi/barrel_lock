import 'package:drift/drift.dart';

import 'vault.dart';

/// 保险库内自定义文件夹分类。
@TableIndex(name: 'idx_folder_vault', columns: {#vaultUuid})
class Folders extends Table {
  @override
  String get tableName => 'folder';

  TextColumn get folderUuid => text()();
  TextColumn get vaultUuid =>
      text().references(Vaults, #vaultUuid, onDelete: KeyAction.cascade)();
  TextColumn get ownerAccountId => text().nullable()();
  BlobColumn get name => blob()();
  BoolColumn get isTrashed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncRevision => dateTime()();
  BoolColumn get localModified => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {folderUuid};
}
