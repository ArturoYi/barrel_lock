import 'package:drift/drift.dart';

import 'folder.dart';
import 'vault.dart';

/// 密码条目主表（网站登录、银行卡、证件、笔记、SSH 密钥）。
@DataClassName('CipherEntry')
@TableIndex(name: 'idx_cipher_vault', columns: {#vaultUuid})
@TableIndex(name: 'idx_cipher_revision', columns: {#syncRevision})
@TableIndex(name: 'idx_cipher_deleted', columns: {#deletedAt})
class CipherEntries extends Table {
  @override
  String get tableName => 'cipher';

  TextColumn get cipherUuid => text()();
  TextColumn get vaultUuid =>
      text().references(Vaults, #vaultUuid, onDelete: KeyAction.cascade)();
  TextColumn get folderUuid => text().nullable().references(
    Folders,
    #folderUuid,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get ownerAccountId => text().nullable()();
  IntColumn get type => integer()();
  BlobColumn get overviewBlob => blob()();
  BlobColumn get fullDataBlob => blob()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get syncRevision => dateTime()();
  BoolColumn get localModified => boolean().withDefault(const Constant(true))();
  TextColumn get remoteId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {cipherUuid};
}
