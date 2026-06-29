part of 'routes.dart';

/// 路由树节点基类（sealed）。
///
/// 所有路由定义（叶子页、Shell 等）均继承此类，共享：
/// - [name] 全局唯一路由名
/// - [path] 路径模板（如 `/user/:id`）
/// - [middlewares] 路由级拦截器
///
/// 子类型：
/// - [FastRoute]：叶子页，直接绑定 page builder
/// - [StatefulShellRoute]（M4）：Tab Shell，各 Branch 独立栈
@immutable
sealed class FastBaseRoute {
  const FastBaseRoute({
    required this.name,
    required this.path,
    this.middlewares = const [],
  });

  /// 路由名称（全局唯一，推荐使用命名跳转）
  final String name;

  /// 路由路径模板，支持动态参数（如 `/user/:id`）
  final String path;

  /// 单路由级拦截器，在 global middlewares 之后执行
  final List<RouteMiddleware> middlewares;

  /// 是否为根路径 `/`
  bool get isRoot => path == '/';

  @override
  String toString() => 'FastBaseRoute(name: $name, path: $path)';
}
