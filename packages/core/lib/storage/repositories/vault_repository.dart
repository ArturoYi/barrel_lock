import '../app_database.dart';
import '../crud_repository.dart';
import 'drift_crud_support.dart';

/// [Vaults] 表仓储。
final class VaultRepository implements CrudRepository<Vault, String> {
  VaultRepository(AppDatabase database)
    : _database = database,
      _crud = DriftCrudSupport<Vault, String>(
        database: database,
        table: database.vaults,
        idEquals: (tbl, id) => (tbl as $VaultsTable).vaultUuid.equals(id),
        idOf: (entity) => entity.vaultUuid,
      );

  final AppDatabase _database;
  final DriftCrudSupport<Vault, String> _crud;

  /// 监听未移入回收站的保险库。
  Stream<List<Vault>> watchActive() {
    return (_database.select(
      _database.vaults,
    )..where((tbl) => tbl.isTrashed.equals(false))).watch();
  }

  @override
  Future<Vault?> findById(String id) => _crud.findById(id);

  @override
  Future<List<Vault>> findAll() => _crud.findAll();

  @override
  Stream<List<Vault>> watchAll() => _crud.watchAll();

  @override
  Future<String> insert(Vault entity) => _crud.insert(entity);

  @override
  Future<bool> update(Vault entity) => _crud.update(entity);

  @override
  Future<int> delete(String id) => _crud.delete(id);

  @override
  Future<int> deleteAll() => _crud.deleteAll();
}
