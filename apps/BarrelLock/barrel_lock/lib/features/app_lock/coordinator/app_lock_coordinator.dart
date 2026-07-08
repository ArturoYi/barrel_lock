import 'package:core/core.dart';

import '../../../router/domain/app_routes.dart';
import '../../../router/application/app_router.dart';

/// 锁屏保护模块导航网关（MVVM-C 的 C 层契约）。
///
/// 抽象接口便于单元测试注入假实现；生产环境使用 [AppLockCoordinator]。
///
/// ## 职责边界
///
/// - **允许**：`AppRouter.push` / `pop` 等路由跳转
/// - **禁止**：读写偏好、身份验证、构建 Widget
abstract interface class AppLockCoordinatorGateway {
  /// 返回上一页（设置页 / PIN 管理子流程）。
  void pop();

  /// 进入备用密码管理页。
  void openPinManage();
}

/// 锁屏保护导航协调器（MVVM-C 的 C 层默认实现）。
final class AppLockCoordinator implements AppLockCoordinatorGateway {
  const AppLockCoordinator();

  @override
  void pop() => AppRouter.pop();

  @override
  void openPinManage() => AppRouter.push(AppRoutes.appLockPinSetup.path);
}

final appLockCoordinatorProvider = Provider<AppLockCoordinatorGateway>(
  (_) => const AppLockCoordinator(),
);
