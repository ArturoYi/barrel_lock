import 'package:drift/drift.dart';

import '../app_database.dart';

/// Drift CRUD 引擎：在构造点绑定表与主键，以组合方式复用增删改查逻辑。
///
/// 各 `XxxRepository` 持有本类实例并对外实现 [CrudRepository]，
/// 避免 Drift 生成类型在泛型继承链上的约束冲突。
final class DriftCrudSupport<TEntity extends DataClass, TId extends Object> {
  const DriftCrudSupport({
    required this._database,
    required this._table,
    required this._idEquals,
    required this._idOf,
  });

  final AppDatabase _database;
  final TableInfo _table;
  final Expression<bool> Function(dynamic tbl, TId id) _idEquals;
  final TId Function(TEntity entity) _idOf;

  Future<TEntity?> findById(TId id) async {
    final row = await (_database.select(
      _table,
    )..where((tbl) => _idEquals(tbl, id))).getSingleOrNull();
    return row as TEntity?;
  }

  Future<List<TEntity>> findAll() async {
    final rows = await _database.select(_table).get();
    return rows.cast<TEntity>();
  }

  Stream<List<TEntity>> watchAll() {
    return _database.select(_table).watch().map((rows) => rows.cast<TEntity>());
  }

  Future<TId> insert(TEntity entity) async {
    await _database.into(_table).insert(entity as Insertable<TEntity>);
    return _idOf(entity);
  }

  Future<bool> update(TEntity entity) async {
    return _database.update(_table).replace(entity as Insertable<TEntity>);
  }

  Future<int> delete(TId id) {
    return (_database.delete(_table)..where((tbl) => _idEquals(tbl, id))).go();
  }

  Future<int> deleteAll() => _database.delete(_table).go();
}
