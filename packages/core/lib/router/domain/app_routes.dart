import 'app_simple_route.dart';
import 'detail_route.dart';

/// BarrelLock 应用路由表（SSOT）。
///
/// 无参路由以属性暴露 [AppSimpleRoute]；带参路由以独立类 + [DetailRoute.call] 方法暴露。
/// 业务层（Coordinator / ViewModel / Page）统一引用此类，禁止硬编码路径字符串。
abstract final class AppRoutes {
  static const launchScreen = AppSimpleRoute(
    name: 'launchScreen',
    path: '/launch',
  );

  static const home = AppSimpleRoute(name: 'home', path: '/');

  static const detail = DetailRoute();

  static const settings = AppSimpleRoute(name: 'settings', path: '/settings');
}
