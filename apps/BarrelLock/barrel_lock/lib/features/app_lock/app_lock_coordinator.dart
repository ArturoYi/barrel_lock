import 'package:core/core.dart';

import '../../router/domain/app_routes.dart';
import '../../router/application/app_router.dart';

/// 锁屏保护导航协调器（MVVM-C 的 C 层）。
abstract interface class AppLockCoordinatorGateway {
  void pop();

  void openPinManage();
}

final class AppLockCoordinator implements AppLockCoordinatorGateway {
  const AppLockCoordinator();

  @override
  void pop() => AppRouter.pop();

  @override
  void openPinManage() => AppRouter.push(AppRoutes.appLockPinSetup.path);
}

final appLockCoordinatorProvider = Provider<AppLockCoordinatorGateway>(
  (_) => const AppLockCoordinator(),
);
