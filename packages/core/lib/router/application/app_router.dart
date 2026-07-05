import 'package:fast_navigator/fast_navigator.dart';
import 'package:flutter/widgets.dart';

import '../domain/app_routes.dart';
import '../presentation/unknown_route_page.dart';
import 'app_route_builders.dart';

/// BarrelLock 应用路由单例。
///
/// ## 职责
///
/// - 持有 [FastRouterConfig]，产出 [routerConfig] 供 [MaterialApp.router] 接入
/// - 委托 [FastNavigator] 提供无 Context 导航 API
/// - 通过 [configure] 接收各平台注入的 [AppRouteBuilders]
///
/// ## 初始化
///
/// 平台 app 必须在 [runApp] 之前调用 [configure]：
///
/// ```dart
/// void main() {
///   configureBarrelLockRouter(); // 见各平台 lib/router/app_router_config.dart
///   runApp(...);
/// }
/// ```
final class AppRouter {
  AppRouter._();

  static final AppRouter instance = AppRouter._();

  /// 简写访问单例实例。
  static AppRouter get I => instance;

  AppRouteBuilders? _builders;
  FastRouterConfig? _fastRouterConfig;
  bool _initialized = false;

  /// 注入各平台页面构建器（[runApp] 前调用，通常仅一次）。
  static void configure(AppRouteBuilders builders) {
    instance._builders = builders;
    instance._initialized = false;
    instance._fastRouterConfig = null;
  }

  /// [MaterialApp.router] 所需的 [RouterConfig]。
  static RouterConfig<Object> get routerConfig {
    instance._ensureInitialized();
    return instance._fastRouterConfig!.routerConfig;
  }

  void _ensureInitialized() {
    final builders = _builders;
    if (builders == null) {
      throw StateError(
        'AppRouter.configure() must be called before accessing routerConfig. '
        'See lib/router/app_router_config.dart in your platform app.',
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
        name: AppRoutes.settings.name,
        path: AppRoutes.settings.path,
        builder: builders.settings,
      ),
    ];
  }

  // ── 导航门面（委托 FastNavigator）────────────────────────────

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
