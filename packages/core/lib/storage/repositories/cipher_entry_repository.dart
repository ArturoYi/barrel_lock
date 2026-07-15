import '../app_database.dart';
import '../crud_repository.dart';
import 'drift_crud_support.dart';

/// [CipherEntries] 表仓储。
final class CipherEntryRepository
    implements CrudRepository<CipherEntry, String> {
  CipherEntryRepository(AppDatabase database)
    : _crud = DriftCrudSupport<CipherEntry, String>(
        database: database,
        table: database.cipherEntries,
        idEquals: (tbl, id) =>
            (tbl as $CipherEntriesTable).cipherUuid.equals(id),
        idOf: (entity) => entity.cipherUuid,
      );

  final DriftCrudSupport<CipherEntry, String> _crud;

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
