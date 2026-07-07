/// 基础 CRUD 仓储契约（伪代码骨架，实体接入后由具体 Repository 实现）。
///
/// 典型实现方式：
/// ```dart
/// final class TodoRepository extends CrudRepository<TodoItem, int> {
///   TodoRepository(this._db);
///   final AppDatabase _db;
///
///   @override
///   Future<TodoItem?> findById(int id) =>
///       (_db.select(_db.todoItems)..where((t) => t.id.equals(id)))
///           .getSingleOrNull();
///
///   @override
///   Stream<List<TodoItem>> watchAll() =>
///       _db.select(_db.todoItems).watch();
///
///   @override
///   Future<int> insert(TodoItem entity) =>
///       _db.into(_db.todoItems).insert(entity);
/// }
/// ```
abstract interface class CrudRepository<TEntity, TId> {
  Future<TEntity?> findById(TId id);

  Future<List<TEntity>> findAll();

  Stream<List<TEntity>> watchAll();

  Future<TId> insert(TEntity entity);

  Future<bool> update(TEntity entity);

  Future<int> delete(TId id);

  Future<int> deleteAll();
}
