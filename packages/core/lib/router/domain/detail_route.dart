/// 详情页路由描述符（含 path 参数 `:id`）。
///
/// - 注册：使用 [path]（`/detail/:id`）
/// - 跳转：使用方法式调用 [call]，如 `AppRoutes.detail(id: '42')`
final class DetailRoute {
  const DetailRoute();

  String get name => 'detail';

  /// 路由注册用模板路径（含动态段）。
  String get path => '/detail/:id';

  /// 生成带 [id] 的目标地址。
  ///
  /// ```dart
  /// AppRouter.push(AppRoutes.detail(id: '42'));
  /// ```
  String call({required String id}) => '/detail/$id';
}
