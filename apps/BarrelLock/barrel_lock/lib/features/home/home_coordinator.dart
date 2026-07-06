import 'package:core/core.dart';

/// 首页 Shell 导航协调器（MVVM-C 的 C 层）。
///
/// Tab 内跳转由各 Tab 的 Coordinator 负责；此处预留给 Shell 级导航。
final class HomeCoordinator {
  const HomeCoordinator();
}

final homeCoordinatorProvider = Provider<HomeCoordinator>(
  (_) => const HomeCoordinator(),
);
