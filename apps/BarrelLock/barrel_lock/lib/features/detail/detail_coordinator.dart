import 'package:core/core.dart';

import '../../router/application/app_router.dart';

/// 详情页导航网关（MVVM-C 的 C 层契约）。
abstract interface class DetailCoordinatorGateway {
  void pop();
}

/// 详情页导航协调器（MVVM-C 的 C 层）。
final class DetailCoordinator implements DetailCoordinatorGateway {
  const DetailCoordinator();

  @override
  void pop() => AppRouter.pop();
}

final detailCoordinatorProvider = Provider<DetailCoordinatorGateway>(
  (_) => const DetailCoordinator(),
);
