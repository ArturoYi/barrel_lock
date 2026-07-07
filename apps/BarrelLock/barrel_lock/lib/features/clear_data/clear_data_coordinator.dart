import 'package:core/core.dart';

import '../../router/application/app_router.dart';
import '../../router/domain/app_routes.dart';

/// 清除数据导航协调器（MVVM-C 的 C 层）。
final class ClearDataCoordinator {
  const ClearDataCoordinator();

  void pop() => AppRouter.pop();

  void popToHome() => AppRouter.go(AppRoutes.home.path);
}

final clearDataCoordinatorProvider = Provider<ClearDataCoordinator>(
  (_) => const ClearDataCoordinator(),
);
