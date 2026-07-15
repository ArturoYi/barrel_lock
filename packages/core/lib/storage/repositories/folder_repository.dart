import '../app_database.dart';
import '../crud_repository.dart';
import 'drift_crud_support.dart';

/// [Folders] 表仓储。
final class FolderRepository implements CrudRepository<Folder, String> {
  FolderRepository(AppDatabase database)
    : _crud = DriftCrudSupport<Folder, String>(
        database: database,
        table: database.folders,
        idEquals: (tbl, id) => (tbl as $FoldersTable).folderUuid.equals(id),
        idOf: (entity) => entity.folderUuid,
      );

  final DriftCrudSupport<Folder, String> _crud;

  @override
  Future<Folder?> findById(String id) => _crud.findById(id);

  @override
  Future<List<Folder>> findAll() => _crud.findAll();

  @override
  Stream<List<Folder>> watchAll() => _crud.watchAll();

  @override
  Future<String> insert(Folder entity) => _crud.insert(entity);

  @override
  Future<bool> update(Folder entity) => _crud.update(entity);

  @override
  Future<int> delete(String id) => _crud.delete(id);

  @override
  Future<int> deleteAll() => _crud.deleteAll();
}
