import 'package:flutter/widgets.dart';
import 'route_match.dart';
import 'route_middleware.dart';

/// 路由页面构建器签名
typedef RoutePageBuilder = Widget Function(BuildContext context, RouteMatch match);

/// 单条路由定义（RouteConfig）。
///
/// 职责：
/// - 声明路由 name、path 模板（如 `/user/:id`）
/// - 绑定 page builder：`Widget Function(BuildContext, RouteMatch)`
/// - 挂载路由级 [RouteMiddleware] 列表
/// - 预留 parent 字段，供 M4 Shell 嵌套扩展
///
/// 依赖：route_match、route_middleware
///
/// 状态：已实现（M1）
class RouteConfig {
  /// 路由名称（全局唯一，推荐使用）
  final String name;

  /// 路由路径模板，支持动态参数（如：/user/:id）
  final String path;

  /// 页面构建器
  final RoutePageBuilder builder;

  /// 单路由级拦截器
  final List<RouteMiddleware> middlewares;

  /// 嵌套路由的子路由（为未来扩展预留）
  final List<RouteConfig> children;

  const RouteConfig({
    required this.name,
    required this.path,
    required this.builder,
    this.middlewares = const [],
    this.children = const [],
  });

  /// 判断此路由是否为根路径
  bool get isRoot => path == '/';

  @override
  String toString() {
    return 'RouteConfig(name: $name, path: $path)';
  }
}
