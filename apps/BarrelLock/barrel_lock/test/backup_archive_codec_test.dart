import 'dart:convert';
import 'dart:typed_data';

import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    Cryptography.instance = Cryptography.instance.withRandom(
      SecureRandom.forTesting(seed: 7),
    );
    AppCrypto.reset();
    AppCrypto.init(secretKeyBytes: List<int>.filled(32, 3));
  });

  tearDown(() {
    AppCrypto.reset();
  });

  BackupTableSnapshot sampleTables({Uint8List? attachmentBytes}) {
    final now = DateTime.utc(2026, 1, 1);
    final vaultUuid = 'vault-1';
    final cipherUuid = 'cipher-1';
    final nameBlob = Uint8List.fromList([9, 9, 9]);
    final overview = Uint8List.fromList([1, 2]);
    final fullData = Uint8List.fromList([3, 4]);
    final fileBytes = attachmentBytes ?? Uint8List.fromList([5, 6]);

    return BackupTableSnapshot(
      vaults: [
        Vault(
          vaultUuid: vaultUuid,
          name: nameBlob,
          isPersonal: true,
          isTrashed: false,
          syncRevision: now,
          localModified: true,
          createdAt: now,
          updatedAt: now,
        ),
      ],
      folders: const [],
      ciphers: [
        CipherEntry(
          cipherUuid: cipherUuid,
          vaultUuid: vaultUuid,
          type: 3,
          overviewBlob: overview,
          fullDataBlob: fullData,
          isFavorite: false,
          syncRevision: now,
          localModified: true,
          createdAt: now,
          updatedAt: now,
        ),
      ],
      attachments: [
        CipherAttachment(
          attachUuid: 'attach-1',
          cipherUuid: cipherUuid,
          fileName: Uint8List.fromList([7, 8]),
          encryptedFile: fileBytes,
          fileSize: fileBytes.length,
          syncRevision: now,
          createdAt: now,
        ),
      ],
    );
  }

  group('BackupArchiveCodec', () {
    test('round-trip preserves tables', () async {
      final tables = sampleTables();
      final snapshot = BackupArchiveCodec.snapshotFromTables(
        tables,
        exportedAt: DateTime.utc(2026, 2, 1),
      );

      final bytes = await BackupArchiveCodec.encode(snapshot);
      final decoded = await BackupArchiveCodec.decode(bytes);

      expect(decoded.tables.vaults, hasLength(1));
      expect(decoded.tables.ciphers, hasLength(1));
      expect(decoded.tables.attachments, hasLength(1));
      expect(decoded.tables.vaults.first.vaultUuid, 'vault-1');
      expect(
        decoded.tables.attachments.first.encryptedFile,
        tables.attachments.first.encryptedFile,
      );
    });

    test('empty database round-trip', () async {
      final snapshot = BackupArchiveCodec.snapshotFromTables(
        BackupTableSnapshot.empty,
        exportedAt: DateTime.utc(2026, 2, 1),
      );
      final bytes = await BackupArchiveCodec.encode(snapshot);
      final decoded = await BackupArchiveCodec.decode(bytes);
      expect(decoded.tables.vaults, isEmpty);
      expect(decoded.tables.attachments, isEmpty);
    });

    test('rejects tampered checksum', () async {
      final snapshot = BackupArchiveCodec.snapshotFromTables(
        sampleTables(),
        exportedAt: DateTime.utc(2026, 2, 1),
      );
      final bytes = await BackupArchiveCodec.encode(snapshot);
      bytes[bytes.length - 1] ^= 0xFF;

      expect(
        () => BackupArchiveCodec.decode(bytes),
        throwsA(isA<BackupArchiveException>()),
      );
    });

    test('rejects invalid magic', () async {
      final snapshot = BackupArchiveCodec.snapshotFromTables(
        sampleTables(),
        exportedAt: DateTime.utc(2026, 2, 1),
      );
      final bytes = await BackupArchiveCodec.encode(snapshot);
      bytes[0] = 0;

      expect(
        () => BackupArchiveCodec.decode(bytes),
        throwsA(isA<BackupArchiveException>()),
      );
    });

    test('rejects future app schema version', () async {
      final tables = sampleTables();
      final snapshot = BackupSnapshot(
        formatVersion: BackupArchiveCodec.formatVersion,
        appSchemaVersion: DatabaseSchemaVersion.current + 1,
        exportedAt: DateTime.utc(2026, 2, 1),
        tables: tables,
        checksum: '',
      );
      final tablesJson = jsonEncode(tables.toTablesJson());
      final checksum = sha256
          .convert(utf8.encode(tablesJson))
          .bytes
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join();
      final patched = BackupSnapshot(
        formatVersion: snapshot.formatVersion,
        appSchemaVersion: snapshot.appSchemaVersion,
        exportedAt: snapshot.exportedAt,
        tables: snapshot.tables,
        checksum: checksum,
      );
      final bytes = await BackupArchiveCodec.encode(patched);

      expect(
        () => BackupArchiveCodec.decode(bytes),
        throwsA(
          predicate<BackupArchiveException>(
            (error) => error.message.contains('更高版本'),
          ),
        ),
      );
    });
  });
}
