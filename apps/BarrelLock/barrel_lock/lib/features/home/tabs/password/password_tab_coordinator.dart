import 'package:core/core.dart';

/// 首页「密码」Tab 导航协调器（MVVM-C 的 C 层）。
final class PasswordTabCoordinator {
  const PasswordTabCoordinator();
}

final passwordTabCoordinatorProvider = Provider<PasswordTabCoordinator>(
  (_) => const PasswordTabCoordinator(),
);
