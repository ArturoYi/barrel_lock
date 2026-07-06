import 'package:core/core.dart';

/// 首页「设置」Tab 导航协调器（MVVM-C 的 C 层）。
final class SettingsTabCoordinator {
  const SettingsTabCoordinator();
}

final settingsTabCoordinatorProvider = Provider<SettingsTabCoordinator>(
  (_) => const SettingsTabCoordinator(),
);
