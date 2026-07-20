import 'package:core/storage/app_database.dart';
import 'package:core/storage/repositories/storage_repositories.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late StorageRepositories repos;

  setUp(() async {
    db = AppDatabase.memory();
    repos = StorageRepositories(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('VaultRepository.watchActive', () {
    test('excludes trashed vaults', () async {
      final now = DateTime.utc(2026, 1, 1);

      await db
          .into(db.vaults)
          .insert(
            VaultsCompanion.insert(
              vaultUuid: 'vault-active',
              name: Uint8List.fromList([1]),
              syncRevision: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db
          .into(db.vaults)
          .insert(
            VaultsCompanion.insert(
              vaultUuid: 'vault-trashed',
              name: Uint8List.fromList([2]),
              isTrashed: const Value(true),
              syncRevision: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      final active = await repos.vaults.watchActive().first;

      expect(active.map((v) => v.vaultUuid), ['vault-active']);
    });
  });

  group('CipherEntryRepository', () {
    test('watchByVault excludes soft-deleted ciphers', () async {
      const vaultId = 'vault-1';
      final now = DateTime.utc(2026, 1, 1);

      await db
          .into(db.vaults)
          .insert(
            VaultsCompanion.insert(
              vaultUuid: vaultId,
              name: Uint8List.fromList([1]),
              syncRevision: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db
          .into(db.cipherEntries)
          .insert(
            CipherEntriesCompanion.insert(
              cipherUuid: 'cipher-active',
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
          .into(db.cipherEntries)
          .insert(
            CipherEntriesCompanion.insert(
              cipherUuid: 'cipher-deleted',
              vaultUuid: vaultId,
              type: 1,
              overviewBlob: Uint8List.fromList([11]),
              fullDataBlob: Uint8List.fromList([21]),
              deletedAt: Value(now),
              syncRevision: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      final rows = await repos.cipherEntries.watchByVault(vaultId).first;

      expect(rows.map((r) => r.cipherUuid), ['cipher-active']);
    });

    test('setFavorite updates isFavorite', () async {
      const vaultId = 'vault-1';
      const cipherId = 'cipher-1';
      final now = DateTime.utc(2026, 1, 1);

      await db
          .into(db.vaults)
          .insert(
            VaultsCompanion.insert(
              vaultUuid: vaultId,
              name: Uint8List.fromList([1]),
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

      expect(await repos.cipherEntries.setFavorite(cipherId, true), isTrue);

      final row = await repos.cipherEntries.findById(cipherId);
      expect(row?.isFavorite, isTrue);
    });
  });

  group('FolderRepository.watchByVault', () {
    test('excludes trashed folders', () async {
      const vaultId = 'vault-1';
      final now = DateTime.utc(2026, 1, 1);

      await db
          .into(db.vaults)
          .insert(
            VaultsCompanion.insert(
              vaultUuid: vaultId,
              name: Uint8List.fromList([1]),
              syncRevision: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              folderUuid: 'folder-active',
              vaultUuid: vaultId,
              name: Uint8List.fromList([1]),
              syncRevision: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db
          .into(db.folders)
          .insert(
            FoldersCompanion.insert(
              folderUuid: 'folder-trashed',
              vaultUuid: vaultId,
              name: Uint8List.fromList([2]),
              isTrashed: const Value(true),
              syncRevision: now,
              createdAt: now,
              updatedAt: now,
            ),
          );

      final folders = await repos.folders.watchByVault(vaultId).first;

      expect(folders.map((f) => f.folderUuid), ['folder-active']);
    });
  });
}
