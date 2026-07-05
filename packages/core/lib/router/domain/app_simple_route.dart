/// 无参路由描述符：对外以 [name] / [path] 属性访问。
///
/// 用于路由表注册（[AppRouter]）与无参跳转（`AppRouter.go(route.path)`）。
final class AppSimpleRoute {
  const AppSimpleRoute({required this.name, required this.path});

  /// fast_navigator 路由名，供 [AppRouter.pushNamed] 使用。
  final String name;

  /// URL 路径，供路由注册与 [AppRouter.push] / [AppRouter.go] 使用。
  final String path;
}
