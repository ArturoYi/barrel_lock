/// 基础 CRUD 仓储契约。
///
/// 实现约定：
/// - 数据访问实现放 `storage/repositories/`，组合 [DriftCrudSupport] 实现各表仓储
/// - 业务层通过 [StorageRepositories] 聚合入口获取各表仓储
/// - 复杂查询（按 vault 过滤、软删除等）在对应 `XxxRepository` 上扩展，不污染本接口
abstract interface class CrudRepository<TEntity, TId> {
  Future<TEntity?> findById(TId id);

  Future<List<TEntity>> findAll();

  Stream<List<TEntity>> watchAll();

  Future<TId> insert(TEntity entity);

  Future<bool> update(TEntity entity);

  Future<int> delete(TId id);

  Future<int> deleteAll();
}
