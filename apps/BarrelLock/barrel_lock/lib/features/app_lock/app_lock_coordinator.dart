import 'package:core/core.dart';

import '../../router/application/app_router.dart';

/// 锁屏保护导航协调器（MVVM-C 的 C 层）。
final class AppLockCoordinator {
  const AppLockCoordinator();

  void pop() => AppRouter.pop();
}

final appLockCoordinatorProvider = Provider<AppLockCoordinator>(
  (_) => const AppLockCoordinator(),
);
