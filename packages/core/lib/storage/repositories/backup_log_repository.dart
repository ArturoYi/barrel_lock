import '../app_database.dart';
import '../crud_repository.dart';
import 'drift_crud_support.dart';

/// [BackupLogs] 表仓储。
final class BackupLogRepository implements CrudRepository<BackupLog, String> {
  BackupLogRepository(AppDatabase database)
    : _crud = DriftCrudSupport<BackupLog, String>(
        database: database,
        table: database.backupLogs,
        idEquals: (tbl, id) => (tbl as $BackupLogsTable).logId.equals(id),
        idOf: (entity) => entity.logId,
      );

  final DriftCrudSupport<BackupLog, String> _crud;

  @override
  Future<BackupLog?> findById(String id) => _crud.findById(id);

  @override
  Future<List<BackupLog>> findAll() => _crud.findAll();

  @override
  Stream<List<BackupLog>> watchAll() => _crud.watchAll();

  @override
  Future<String> insert(BackupLog entity) => _crud.insert(entity);

  @override
  Future<bool> update(BackupLog entity) => _crud.update(entity);

  @override
  Future<int> delete(String id) => _crud.delete(id);

  @override
  Future<int> deleteAll() => _crud.deleteAll();
}
