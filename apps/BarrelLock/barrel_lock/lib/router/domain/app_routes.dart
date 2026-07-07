import 'app_simple_route.dart';
import 'detail_route.dart';

/// BarrelLock 应用路由表（SSOT）。
abstract final class AppRoutes {
  static const launchScreen = AppSimpleRoute(
    name: 'launchScreen',
    path: '/launch',
  );

  static const home = AppSimpleRoute(name: 'home', path: '/');

  static const detail = DetailRoute();

  static const settings = AppSimpleRoute(name: 'settings', path: '/settings');

  static const dataMigration = AppSimpleRoute(
    name: 'dataMigration',
    path: '/settings/data-migration',
  );

  static const appLock = AppSimpleRoute(
    name: 'appLock',
    path: '/settings/app-lock',
  );

  static const clearData = AppSimpleRoute(
    name: 'clearData',
    path: '/settings/clear-data',
  );
}
