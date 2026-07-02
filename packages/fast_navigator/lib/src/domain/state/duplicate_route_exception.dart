/// 当 [LaunchMode.standard] 下 push 已存在于栈中的路由时抛出。
class DuplicateRouteException implements Exception {
  /// 目标路由的逻辑身份（`routeName:path`）。
  final String identity;

  /// 目标路由在栈中的索引位置。
  final int index;

  const DuplicateRouteException({required this.identity, required this.index});

  @override
  String toString() {
    return 'DuplicateRouteException: route "$identity" already exists at stack index $index';
  }
}
