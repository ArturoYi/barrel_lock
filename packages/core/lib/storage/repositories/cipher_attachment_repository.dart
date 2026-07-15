import '../app_database.dart';
import '../crud_repository.dart';
import 'drift_crud_support.dart';

/// [CipherAttachments] 表仓储。
final class CipherAttachmentRepository
    implements CrudRepository<CipherAttachment, String> {
  CipherAttachmentRepository(AppDatabase database)
    : _crud = DriftCrudSupport<CipherAttachment, String>(
        database: database,
        table: database.cipherAttachments,
        idEquals: (tbl, id) =>
            (tbl as $CipherAttachmentsTable).attachUuid.equals(id),
        idOf: (entity) => entity.attachUuid,
      );

  final DriftCrudSupport<CipherAttachment, String> _crud;

  @override
  Future<CipherAttachment?> findById(String id) => _crud.findById(id);

  @override
  Future<List<CipherAttachment>> findAll() => _crud.findAll();

  @override
  Stream<List<CipherAttachment>> watchAll() => _crud.watchAll();

  @override
  Future<String> insert(CipherAttachment entity) => _crud.insert(entity);

  @override
  Future<bool> update(CipherAttachment entity) => _crud.update(entity);

  @override
  Future<int> delete(String id) => _crud.delete(id);

  @override
  Future<int> deleteAll() => _crud.deleteAll();
}
