part of 'routes.dart';

/// 路由页面构建器签名
typedef RoutePageBuilder = Widget Function(BuildContext context, RouteMatch match);

/// 叶子页路由（FastRoute）。
///
/// 职责：
/// - 声明可直达的页面路由 name、path
/// - 绑定 [builder] 产出页面 Widget
/// - 挂载路由级 [RouteMiddleware]
///
/// Shell 内各 Branch 的子路由亦使用此类型。
final class FastRoute extends FastBaseRoute {
  /// 页面构建器
  final RoutePageBuilder builder;

  const FastRoute({
    required super.name,
    required super.path,
    required this.builder,
    super.middlewares = const [],
  });

  @override
  String toString() => 'FastRoute(name: $name, path: $path)';
}
