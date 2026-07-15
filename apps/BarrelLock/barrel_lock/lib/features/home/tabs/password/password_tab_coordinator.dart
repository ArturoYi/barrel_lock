import 'package:core/core.dart';

import '../../../../router/application/app_router.dart';
import '../../../../router/domain/app_routes.dart';

/// 首页「密码」Tab 导航协调器（MVVM-C 的 C 层）。
final class PasswordTabCoordinator {
  const PasswordTabCoordinator();

  void openCipherDetail(String cipherId) {
    AppRouter.push(AppRoutes.detail(id: cipherId));
  }
}

final passwordTabCoordinatorProvider = Provider<PasswordTabCoordinator>(
  (_) => const PasswordTabCoordinator(),
);
