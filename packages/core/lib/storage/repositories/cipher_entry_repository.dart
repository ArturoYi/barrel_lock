import 'package:drift/drift.dart';

import '../app_database.dart';
import '../crud_repository.dart';
import 'drift_crud_support.dart';

/// [CipherEntries] 表仓储。
final class CipherEntryRepository
    implements CrudRepository<CipherEntry, String> {
  CipherEntryRepository(AppDatabase database)
    : _database = database,
      _crud = DriftCrudSupport<CipherEntry, String>(
        database: database,
        table: database.cipherEntries,
        idEquals: (tbl, id) =>
            (tbl as $CipherEntriesTable).cipherUuid.equals(id),
        idOf: (entity) => entity.cipherUuid,
      );

  final AppDatabase _database;
  final DriftCrudSupport<CipherEntry, String> _crud;

  /// 监听指定保险库下未软删除的密码条目。
  Stream<List<CipherEntry>> watchByVault(String vaultUuid) {
    return (_database.select(_database.cipherEntries)..where(
          (tbl) => tbl.vaultUuid.equals(vaultUuid) & tbl.deletedAt.isNull(),
        ))
        .watch();
  }

  /// 监听单条密码条目（含已软删除行，由调用方过滤）。
  Stream<CipherEntry?> watchById(String cipherUuid) {
    return (_database.select(
      _database.cipherEntries,
    )..where((tbl) => tbl.cipherUuid.equals(cipherUuid))).watchSingleOrNull();
  }

  /// 软删除密码条目。
  Future<bool> softDelete(String cipherUuid) async {
    final now = DateTime.now().toUtc();
    final count =
        await (_database.update(
          _database.cipherEntries,
        )..where((tbl) => tbl.cipherUuid.equals(cipherUuid))).write(
          CipherEntriesCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            localModified: const Value(true),
          ),
        );
    return count > 0;
  }

  /// 更新所属文件夹（NULL 表示未分组）。
  Future<bool> updateFolderUuid(String cipherUuid, String? folderUuid) async {
    final now = DateTime.now().toUtc();
    final count =
        await (_database.update(
          _database.cipherEntries,
        )..where((tbl) => tbl.cipherUuid.equals(cipherUuid))).write(
          CipherEntriesCompanion(
            folderUuid: folderUuid == null
                ? const Value(null)
                : Value(folderUuid),
            updatedAt: Value(now),
            localModified: const Value(true),
          ),
        );
    return count > 0;
  }

  /// 更新收藏状态并刷新 [updatedAt]。
  Future<bool> setFavorite(String cipherUuid, bool isFavorite) async {
    final now = DateTime.now().toUtc();
    final count =
        await (_database.update(
          _database.cipherEntries,
        )..where((tbl) => tbl.cipherUuid.equals(cipherUuid))).write(
          CipherEntriesCompanion(
            isFavorite: Value(isFavorite),
            updatedAt: Value(now),
            localModified: const Value(true),
          ),
        );
    return count > 0;
  }

  @override
  Future<CipherEntry?> findById(String id) => _crud.findById(id);

  @override
  Future<List<CipherEntry>> findAll() => _crud.findAll();

  @override
  Stream<List<CipherEntry>> watchAll() => _crud.watchAll();

  @override
  Future<String> insert(CipherEntry entity) => _crud.insert(entity);

  @override
  Future<bool> update(CipherEntry entity) => _crud.update(entity);

  @override
  Future<int> delete(String id) => _crud.delete(id);

  @override
  Future<int> deleteAll() => _crud.deleteAll();
}
