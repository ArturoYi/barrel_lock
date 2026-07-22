import 'package:core/core.dart';

/// 开启验证流程结束时的副作用网关（MVVM-C 的 C 层契约）。
abstract interface class AppLockEnableSetupCoordinatorGateway {
  /// 开启验证成功并完成落盘后的回调。
  void onEnableSetupCompleted();

  /// 用户取消开启验证流程时的回调。
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

/// 开启验证流程协调器；默认实现弹 Toast，平台可通过 override 定制副作用。
final appLockEnableSetupCoordinatorProvider =
    Provider<AppLockEnableSetupCoordinatorGateway>(
      (_) => const AppLockEnableSetupCoordinator(),
    );
