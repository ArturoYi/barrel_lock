import 'package:core/core.dart';

/// 详情页业务数据（MVVM-C 的 M 层）。
final class DetailModel {
  const DetailModel(this.id);

  final String id;
}

final detailModelProvider = Provider.family<DetailModel, String>(
  (_, id) => DetailModel(id),
);
