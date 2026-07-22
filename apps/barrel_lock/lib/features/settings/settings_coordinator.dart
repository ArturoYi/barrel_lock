import 'package:core/core.dart';

import '../../router/application/app_router.dart';

/// 设置页导航协调器（MVVM-C 的 C 层）。
final class SettingsCoordinator {
  const SettingsCoordinator();

  void pop() => AppRouter.pop();
}

final settingsCoordinatorProvider = Provider<SettingsCoordinator>(
  (_) => const SettingsCoordinator(),
);
