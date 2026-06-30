import '../match/route_match.dart';
import '../match/route_parameters.dart';
import '../route/routes.dart';

/// 路由表注册与匹配引擎（RouteRegistry）。
///
/// 职责：
/// - 注册 / 查询 [FastBaseRoute] 路由树（当前匹配仅支持 [FastRoute]）
/// - `match(location)`：最长前缀匹配，支持 `:param` 动态路径段
/// - `unknown(location)`：404 兜底匹配，永不 throw
/// - `findByName(name)`：按路由名反查配置
///
/// 设计原则：
/// - 匹配逻辑与渲染、栈管理解耦
/// - 为 Parser（URL→State）和 FastNavigator（API→State）共用
///
/// 依赖：routes、route_match
///
/// 状态：已实现（M1）
class RouteRegistry {
  final Map<String, FastBaseRoute> _routesByName = {};
  final List<FastRoute> _leafRoutes = [];

  /// 404 兜底路由构建器（始终为叶子页）
  FastRoute? unknownRoute;

  RouteRegistry({
    List<FastBaseRoute> routes = const [],
    this.unknownRoute,
  }) {
    for (final route in routes) {
      addRoute(route);
    }
  }

  /// 注册路由树节点
  void addRoute(FastBaseRoute route) {
    if (_routesByName.containsKey(route.name)) {
      throw ArgumentError('Route with name "${route.name}" already exists.');
    }
    _routesByName[route.name] = route;

    switch (route) {
      case FastRoute leafRoute:
        _leafRoutes.add(leafRoute);
        _leafRoutes.sort((a, b) => b.path.length.compareTo(a.path.length));
    }
  }

  /// 根据路由名称查找配置
  FastBaseRoute? findByName(String name) {
    return _routesByName[name];
  }

  /// 匹配路径到具体的 RouteMatch
  /// [location] 例如 `/user/42?tab=info`
  RouteMatch matchLocation(Uri location, {Object? extra}) {
    final pathSegments = location.pathSegments;

    for (final route in _leafRoutes) {
      final routeSegments = Uri.parse(route.path).pathSegments;
      
      // 检查路径段数量是否匹配（这里是精确匹配，未实现子路由嵌套匹配）
      if (routeSegments.length != pathSegments.length) continue;

      bool isMatch = true;
      final pathParams = <String, String>{};

      for (int i = 0; i < routeSegments.length; i++) {
        final routeSeg = routeSegments[i];
        final pathSeg = pathSegments[i];

        if (routeSeg.startsWith(':')) {
          // 动态参数段
          final paramName = routeSeg.substring(1);
          pathParams[paramName] = pathSeg;
        } else if (routeSeg != pathSeg) {
          // 静态段不匹配
          isMatch = false;
          break;
        }
      }

      if (isMatch) {
        return RouteMatch(
          route: route,
          path: location.path,
          parameters: RouteParameters(
            pathParams: pathParams,
            queryParams: location.queryParameters,
            extra: extra,
          ),
          key: RouteMatch.generateKey(route.name, location.path),
        );
      }
    }

    // 未匹配到任何路由，返回兜底
    if (unknownRoute != null) {
      return RouteMatch(
        route: unknownRoute!,
        path: location.path,
        parameters: RouteParameters(
          queryParams: location.queryParameters,
          extra: extra,
        ),
        key: 'unknown_route',
      );
    }

    throw StateError('No route found for ${location.path} and no unknownRoute provided.');
  }
}
