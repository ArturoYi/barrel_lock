import 'package:core/core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'support_urls.dart';

/// 服务支持导航（打开外链 / 邮件）。
final class SupportCoordinator {
  const SupportCoordinator();

  Future<bool> openItem(String itemId) async {
    final url = SupportUrls.urlForItem(itemId);
    if (url == null) {
      return false;
    }
    final uri = Uri.parse(url);
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

final supportCoordinatorProvider = Provider<SupportCoordinator>(
  (_) => const SupportCoordinator(),
);
