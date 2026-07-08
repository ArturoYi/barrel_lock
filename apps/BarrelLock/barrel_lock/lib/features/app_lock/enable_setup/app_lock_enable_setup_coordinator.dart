import 'package:core/core.dart';

/// 开启验证流程结束时的副作用网关（MVVM-C 的 C 层契约）。
abstract interface class AppLockEnableSetupCoordinatorGateway {
  void onEnableSetupCompleted();

  void onEnableSetupCancelled();
}

/// 开启验证流程默认协调器（MVVM-C 的 C 层）。
final class AppLockEnableSetupCoordinator
    implements AppLockEnableSetupCoordinatorGateway {
  const AppLockEnableSetupCoordinator();

  @override
  void onEnableSetupCompleted() {
    FastToast.show('应用保护已开启');
  }

  @override
  void onEnableSetupCancelled() {}
}

final appLockEnableSetupCoordinatorProvider =
    Provider<AppLockEnableSetupCoordinatorGateway>(
      (_) => const AppLockEnableSetupCoordinator(),
    );
