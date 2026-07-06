/// 无参路由描述符：对外以 [name] / [path] 属性访问。
final class AppSimpleRoute {
  const AppSimpleRoute({required this.name, required this.path});

  final String name;
  final String path;
}
