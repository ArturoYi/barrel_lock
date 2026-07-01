part of 'routes.dart';

/// 路由页面构建器签名
typedef RoutePageBuilder = Widget Function(BuildContext context, RouteMatch match);

/// 叶子页路由（FastRoute）。
///
/// 职责：
/// - 声明可直达的页面路由 name、path
/// - 绑定 [builder] 产出页面 Widget
/// - 可选 [transition] 覆盖过渡策略（默认由 [PageFactory] 全局策略决定）
/// - 挂载路由级 [RouteMiddleware]
///
/// Shell 内各 Branch 的子路由亦使用此类型。
final class FastRoute extends FastBaseRoute {
  /// 页面构建器
  final RoutePageBuilder builder;

  /// 路由级过渡策略；为 null 时使用 [PageFactory.defaultTransition]。
  final PageTransition? transition;

  const FastRoute({
    required super.name,
    required super.path,
    required this.builder,
    this.transition,
    super.middlewares = const [],
  });

  @override
  String toString() => 'FastRoute(name: $name, path: $path)';
}
