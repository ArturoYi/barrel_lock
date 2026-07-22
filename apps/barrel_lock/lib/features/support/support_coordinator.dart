import 'package:core/core.dart';

import '../../router/application/app_router.dart';
import '../../router/domain/app_routes.dart';

/// 服务支持导航（应用内文档页 / 反馈页）。
final class SupportCoordinator {
  const SupportCoordinator();

  void openItem(String itemId) {
    switch (itemId) {
      case 'feedback':
        AppRouter.push(AppRoutes.supportFeedback.path);
      case 'help_doc':
      case 'user_agreement':
      case 'privacy_policy':
      case 'encryption_doc':
        AppRouter.push(AppRoutes.supportDocument(docId: itemId));
      default:
        FastToast.show('暂不支持该入口');
    }
  }
}

final supportCoordinatorProvider = Provider<SupportCoordinator>(
  (_) => const SupportCoordinator(),
);
