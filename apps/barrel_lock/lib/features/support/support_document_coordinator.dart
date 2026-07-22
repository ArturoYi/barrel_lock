import 'package:core/core.dart';

import '../../router/application/app_router.dart';

/// 服务支持文档导航（MVVM-C 的 C 层）。
final class SupportDocumentCoordinator {
  const SupportDocumentCoordinator();

  void pop() => AppRouter.pop();
}

final supportDocumentCoordinatorProvider = Provider<SupportDocumentCoordinator>(
  (_) => const SupportDocumentCoordinator(),
);
