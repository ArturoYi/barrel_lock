import 'package:core/core.dart';

import '../../router/application/app_router.dart';

/// 客服反馈导航（MVVM-C 的 C 层）。
final class SupportFeedbackCoordinator {
  const SupportFeedbackCoordinator();

  void pop() => AppRouter.pop();
}

final supportFeedbackCoordinatorProvider = Provider<SupportFeedbackCoordinator>(
  (_) => const SupportFeedbackCoordinator(),
);
