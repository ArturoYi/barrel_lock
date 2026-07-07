import 'package:core/core.dart';

import '../../../../router/application/app_router.dart';
import '../../../../router/domain/app_routes.dart';
import '../../../support/support_coordinator.dart';

/// 首页「设置」Tab 导航协调器（MVVM-C 的 C 层）。
final class SettingsTabCoordinator {
  SettingsTabCoordinator(this._supportCoordinator);

  final SupportCoordinator _supportCoordinator;

  void openDataMigration() => AppRouter.push(AppRoutes.dataMigration.path);

  void openAppLock() => AppRouter.push(AppRoutes.appLock.path);

  void openClearData() => AppRouter.push(AppRoutes.clearData.path);

  Future<void> openSupportItem(String itemId) =>
      _supportCoordinator.openItem(itemId);

  void openThemeSettings() {}
}

final settingsTabCoordinatorProvider = Provider<SettingsTabCoordinator>((ref) {
  return SettingsTabCoordinator(ref.read(supportCoordinatorProvider));
});
