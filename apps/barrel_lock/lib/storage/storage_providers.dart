import 'package:core/core.dart';

/// 存储层聚合入口 Provider，供 feature Model 注入 [StorageRepositories]。
final storageRepositoriesProvider = Provider<StorageRepositories>(
  (_) => StorageRepositories.defaults(),
);
