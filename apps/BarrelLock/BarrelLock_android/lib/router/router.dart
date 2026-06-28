import 'package:fast_navigator/fast_navigator.dart';
import 'package:flutter/widgets.dart';

import '../pages/home_page.dart';

/// 路由名称与路径常量，业务层统一引用。
abstract final class AppRoutes {
  static const home = 'home';
  static const homePath = '/';
}

/// 应用路由管理单例。
///
/// - 集中注册 [RouteConfig] 路由表
/// - 产出 [routerConfig] 供 [MaterialApp.router] 接入
/// - 初始化后可通过 [AppRouter.push] 等静态方法无 Context 跳转
class AppRouter {
  AppRouter._();

  static final AppRouter instance = AppRouter._();

  /// 简写访问单例实例（导航等场景如需扩展实例方法时使用）。
  static AppRouter get I => instance;

  /// MaterialApp.router 所需的 RouterConfig（静态便捷访问）。
  static RouterConfig<Object> get routerConfig {
    instance._ensureInitialized();
    return instance._fastRouterConfig.routerConfig;
  }

  late final FastRouterConfig _fastRouterConfig;

  bool _initialized = false;

  void _ensureInitialized() {
    if (_initialized) return;

    _fastRouterConfig = FastRouterConfig(
      initialLocation: AppRoutes.homePath,
      routes: _buildRoutes(),
      unknownRoute: RouteConfig(
        name: 'unknown',
        path: '/404',
        builder: (context, match) => const _UnknownRoutePage(),
      ),
    );
    _initialized = true;
  }

  List<RouteConfig> _buildRoutes() {
    return [
      RouteConfig(
        name: AppRoutes.home,
        path: AppRoutes.homePath,
        builder: (context, match) => const HomePage(),
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

class _UnknownRoutePage extends StatelessWidget {
  const _UnknownRoutePage();

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(child: Text('404 — Page not found')),
    );
  }
}
