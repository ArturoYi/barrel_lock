import 'package:drift/drift.dart';

import 'cipher_entry.dart';

/// 密码条目附件（证件照、截图、pem、PDF 等），原始二进制加密存储。
@TableIndex(name: 'idx_attach_cipher', columns: {#cipherUuid})
class CipherAttachments extends Table {
  @override
  String get tableName => 'cipher_attachment';

  TextColumn get attachUuid => text()();
  TextColumn get cipherUuid => text().references(
    CipherEntries,
    #cipherUuid,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get ownerAccountId => text().nullable()();
  BlobColumn get fileName => blob()();
  BlobColumn get encryptedFile => blob()();
  IntColumn get fileSize => integer()();
  DateTimeColumn get syncRevision => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {attachUuid};
}
