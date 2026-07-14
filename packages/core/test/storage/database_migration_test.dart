import 'dart:typed_data';

import 'package:core/storage/app_database.dart';
import 'package:core/storage/migration/database_schema_version.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase schema v${DatabaseSchemaVersion.current}', () {
    test('onCreate 创建全部 5 张业务表', () async {
      final tables = await db
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' "
            "AND name NOT LIKE 'sqlite_%' ORDER BY name",
          )
          .get();

      expect(tables.map((r) => r.read<String>('name')).toList(), [
        'backup_log',
        'cipher',
        'cipher_attachment',
        'folder',
        'vault',
      ]);
    });

    test('外键约束生效：删除 cipher 级联删除 attachment', () async {
      const vaultId = 'vault-1';
      const cipherId = 'cipher-1';
      const attachId = 'attach-1';
      final now = DateTime.utc(2026, 1, 1);

      await db
          .into(db.vaults)
          .insert(
            VaultsCompanion.insert(
              vaultUuid: vaultId,
              name: Uint8List.fromList([1, 2, 3]),
              syncRevision: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db
          .into(db.cipherEntries)
          .insert(
            CipherEntriesCompanion.insert(
              cipherUuid: cipherId,
              vaultUuid: vaultId,
              type: 1,
              overviewBlob: Uint8List.fromList([10]),
              fullDataBlob: Uint8List.fromList([20]),
              syncRevision: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db
          .into(db.cipherAttachments)
          .insert(
            CipherAttachmentsCompanion.insert(
              attachUuid: attachId,
              cipherUuid: cipherId,
              fileName: Uint8List.fromList([30]),
              encryptedFile: Uint8List.fromList([40]),
              fileSize: 1,
              syncRevision: now,
              createdAt: now,
            ),
          );

      await (db.delete(
        db.cipherEntries,
      )..where((t) => t.cipherUuid.equals(cipherId))).go();

      final remaining = await db.select(db.cipherAttachments).get();
      expect(remaining, isEmpty);
    });
  });
}
