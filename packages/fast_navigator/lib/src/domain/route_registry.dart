import '../params/route_parameters.dart';
import 'route_config.dart';
import 'route_match.dart';

/// 路由表注册与匹配引擎（RouteRegistry）。
///
/// 职责：
/// - 注册 / 查询 [RouteConfig] 路由定义
/// - `match(location)`：最长前缀匹配，支持 `:param` 动态路径段
/// - `unknown(location)`：404 兜底匹配，永不 throw
/// - `findByName(name)`：按路由名反查配置
///
/// 设计原则：
/// - 匹配逻辑与渲染、栈管理解耦
/// - 为 Parser（URL→State）和 FastNavigator（API→State）共用
///
/// 依赖：route_config、route_match
///
/// 状态：已实现（M1）
class RouteRegistry {
  final Map<String, RouteConfig> _routesByName = {};
  final List<RouteConfig> _routes = [];

  /// 404 兜底路由构建器
  RouteConfig? unknownRoute;

  RouteRegistry({
    List<RouteConfig> routes = const [],
    this.unknownRoute,
  }) {
    routes.forEach(addRoute);
  }

  /// 注册新路由
  void addRoute(RouteConfig route) {
    if (_routesByName.containsKey(route.name)) {
      throw ArgumentError('Route with name "${route.name}" already exists.');
    }
    _routesByName[route.name] = route;
    _routes.add(route);
    // 可选：在这里如果需要按长路径优先排序以支持更准确匹配
    _routes.sort((a, b) => b.path.length.compareTo(a.path.length));
  }

  /// 根据路由名称查找配置
  RouteConfig? findByName(String name) {
    return _routesByName[name];
  }

  /// 匹配路径到具体的 RouteMatch
  /// [location] 例如 `/user/42?tab=info`
  RouteMatch matchLocation(Uri location, {Object? extra}) {
    final pathSegments = location.pathSegments;

    for (final route in _routes) {
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
