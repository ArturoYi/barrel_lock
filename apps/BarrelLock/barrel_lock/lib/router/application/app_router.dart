import 'package:fast_dialog/fast_dialog.dart';
import 'package:fast_navigator/fast_navigator.dart';
import 'package:flutter/widgets.dart';

import '../domain/app_routes.dart';
import '../presentation/unknown_route_page.dart';
import 'app_route_builders.dart';

/// BarrelLock 应用路由单例。
final class AppRouter {
  AppRouter._();

  static final AppRouter instance = AppRouter._();
  static AppRouter get I => instance;

  AppRouteBuilders? _builders;
  FastRouterConfig? _fastRouterConfig;
  bool _initialized = false;

  static void configure(AppRouteBuilders builders) {
    instance._builders = builders;
    instance._initialized = false;
    instance._fastRouterConfig = null;
  }

  static RouterConfig<Object> get routerConfig {
    instance._ensureInitialized();
    return instance._fastRouterConfig!.routerConfig;
  }

  void _ensureInitialized() {
    final builders = _builders;
    if (builders == null) {
      throw StateError(
        'AppRouter.configure() must be called before accessing routerConfig.',
      );
    }
    if (_initialized) return;

    _fastRouterConfig = FastRouterConfig(
      initialLocation: AppRoutes.launchScreen.path,
      routes: _buildRoutes(builders),
      unknownRoute: FastRoute(
        name: 'unknown',
        path: '/404',
        builder: (context, match) => const UnknownRoutePage(),
      ),
      navigatorObservers: [DialogRouteObserver.forManager()],
    );
    _initialized = true;
  }

  static List<FastBaseRoute> _buildRoutes(AppRouteBuilders builders) {
    return [
      FastRoute(
        name: AppRoutes.launchScreen.name,
        path: AppRoutes.launchScreen.path,
        builder: builders.launchScreen,
      ),
      FastRoute(
        name: AppRoutes.home.name,
        path: AppRoutes.home.path,
        builder: builders.home,
        transition: const FadePageTransition(),
      ),
      FastRoute(
        name: AppRoutes.detail.name,
        path: AppRoutes.detail.path,
        builder: builders.detail,
      ),
      FastRoute(
        name: AppRoutes.cipherAdd.name,
        path: AppRoutes.cipherAdd.path,
        builder: builders.cipherAdd,
      ),
      FastRoute(
        name: AppRoutes.settings.name,
        path: AppRoutes.settings.path,
        builder: builders.settings,
      ),
      FastRoute(
        name: AppRoutes.dataMigration.name,
        path: AppRoutes.dataMigration.path,
        builder: builders.dataMigration,
      ),
      FastRoute(
        name: AppRoutes.appLock.name,
        path: AppRoutes.appLock.path,
        builder: builders.appLock,
      ),
      FastRoute(
        name: AppRoutes.appLockPinSetup.name,
        path: AppRoutes.appLockPinSetup.path,
        builder: builders.appLockPinSetup,
      ),
      FastRoute(
        name: AppRoutes.clearData.name,
        path: AppRoutes.clearData.path,
        builder: builders.clearData,
      ),
    ];
  }

  static void push(String location, {Object? extra}) =>
      FastNavigator.push(location, extra: extra);

  static void pushNamed(
    String name, {
    Map<String, String>? pathParams,
    Map<String, String>? queryParams,
    Object? extra,
  }) => FastNavigator.pushNamed(
    name,
    pathParams: pathParams,
    queryParams: queryParams,
    extra: extra,
  );

  static void pop() => FastNavigator.pop();

  static void replace(String location, {Object? extra}) =>
      FastNavigator.replace(location, extra: extra);

  static void go(String location, {Object? extra}) =>
      FastNavigator.go(location, extra: extra);

  static void popUntil(bool Function(String routeName) predicate) =>
      FastNavigator.popUntil(predicate);
}
