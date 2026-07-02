import 'package:flutter/foundation.dart';

/// 多层路由参数模型（RouteParameters）。
///
/// 职责：
/// - 统一封装 pathParams（动态路径 :id）、queryParams（?key=val）、extra（内存附加）
/// - 提供解析 / 合并 / 序列化工具
/// - 区分可 URL 持久化参数 vs 不可序列化 extra
///
/// 参数层次：
/// ```
/// /user/42?tab=info
///  ──path──  query
///    :id
/// ```
///
/// 依赖：无（纯工具 / 值对象）
///
/// 状态：已实现（M2）
@immutable
class RouteParameters {
  /// 动态路径参数，例如 /user/:id 中的 { 'id': '42' }
  final Map<String, String> pathParams;

  /// URL 查询参数，例如 ?tab=info 中的 { 'tab': 'info' }
  final Map<String, String> queryParams;

  /// 内存附加对象，不支持序列化到 URL，适用于跨页面传递复杂对象
  final Object? extra;

  const RouteParameters({
    this.pathParams = const {},
    this.queryParams = const {},
    this.extra,
  });

  /// 创建一个空参数对象
  static const RouteParameters empty = RouteParameters();

  /// 复制当前参数对象，允许覆盖部分字段
  RouteParameters copyWith({
    Map<String, String>? pathParams,
    Map<String, String>? queryParams,
    Object? extra,
  }) {
    return RouteParameters(
      pathParams: pathParams ?? this.pathParams,
      queryParams: queryParams ?? this.queryParams,
      extra: extra ?? this.extra,
    );
  }

  /// 合并另一个 [RouteParameters] 对象
  RouteParameters merge(RouteParameters other) {
    return RouteParameters(
      pathParams: {...pathParams, ...other.pathParams},
      queryParams: {...queryParams, ...other.queryParams},
      extra: other.extra ?? extra,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RouteParameters &&
        mapEquals(other.pathParams, pathParams) &&
        mapEquals(other.queryParams, queryParams) &&
        other.extra == extra;
  }

  @override
  int get hashCode =>
      pathParams.hashCode ^ queryParams.hashCode ^ extra.hashCode;

  @override
  String toString() {
    return 'RouteParameters(pathParams: $pathParams, queryParams: $queryParams, extra: $extra)';
  }
}
