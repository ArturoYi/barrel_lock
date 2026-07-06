import 'package:core/core.dart';

import '../../router/application/app_router.dart';

/// 详情页导航协调器（MVVM-C 的 C 层）。
final class DetailCoordinator {
  const DetailCoordinator();

  void pop() => AppRouter.pop();
}

final detailCoordinatorProvider = Provider<DetailCoordinator>(
  (_) => const DetailCoordinator(),
);
