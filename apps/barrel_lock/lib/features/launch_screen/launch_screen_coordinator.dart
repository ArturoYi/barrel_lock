import 'package:core/core.dart';

import '../../router/application/app_router.dart';
import '../../router/domain/app_routes.dart';

/// 启动页导航协调器（MVVM-C 的 C 层）。
final class LaunchScreenCoordinator {
  const LaunchScreenCoordinator();

  void goToHome() => AppRouter.go(AppRoutes.home.path);
}

final launchScreenCoordinatorProvider = Provider<LaunchScreenCoordinator>(
  (_) => const LaunchScreenCoordinator(),
);
