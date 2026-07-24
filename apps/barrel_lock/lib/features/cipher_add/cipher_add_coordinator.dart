import 'package:core/core.dart';

import '../../l10n/overlay_l10n.dart';
import '../../router/application/app_router.dart';

/// 添加密码页导航网关（MVVM-C 的 C 层契约）。
abstract interface class CipherAddCoordinatorGateway {
  void pop();

  void finishAddSuccess();
}

/// 添加密码页导航协调器（MVVM-C 的 C 层）。
final class CipherAddCoordinator implements CipherAddCoordinatorGateway {
  const CipherAddCoordinator();

  @override
  void pop() => AppRouter.pop();

  @override
  void finishAddSuccess() {
    OverlayL10n.successToast((l) => l.cipher_addedToast);
    AppRouter.pop();
  }
}

final cipherAddCoordinatorProvider = Provider<CipherAddCoordinatorGateway>(
  (_) => const CipherAddCoordinator(),
);
