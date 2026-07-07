import 'package:core/core.dart';

import '../../router/application/app_router.dart';

/// 数据迁移导航协调器（MVVM-C 的 C 层）。
final class DataMigrationCoordinator {
  const DataMigrationCoordinator();

  void pop() => AppRouter.pop();
}

final dataMigrationCoordinatorProvider = Provider<DataMigrationCoordinator>(
  (_) => const DataMigrationCoordinator(),
);
