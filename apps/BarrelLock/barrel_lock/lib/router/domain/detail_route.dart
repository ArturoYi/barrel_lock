/// 详情页路由描述符（含 path 参数 `:id`）。
final class DetailRoute {
  const DetailRoute();

  String get name => 'detail';
  String get path => '/detail/:id';

  String call({required String id}) => '/detail/$id';
}
