import 'package:flutter/foundation.dart';
import '../params/route_parameters.dart';
import 'route_config.dart';

/// 单次路由匹配结果（RouteMatch，参数持久绑定单元）。
///
/// 职责：
/// - 绑定一次路由解析的全部上下文：path、routeName、pathParams、queryParams、extra
/// - 提供 `uri` 序列化与 `pageKey` 生成（Page Diff 关键）
///
/// Page Key 策略：
/// - 默认：`routeName:path`
/// - 同路由重复 push：加 stackIndex 或 uuid
/// - extra 不纳入 Key
///
/// 依赖：无（纯数据模型）
///
/// 状态：已实现（M1）
@immutable
class RouteMatch {
  /// 匹配到的路由配置定义
  final RouteConfig route;

  /// 实际匹配的路径（带参数）
  final String path;

  /// 绑定的路由参数
  final RouteParameters parameters;

  /// 基于此匹配结果生成的全局唯一标识，供 Page 鉴别重用（Diff 机制）
  final String key;

  const RouteMatch({
    required this.route,
    required this.path,
    required this.parameters,
    required this.key,
  });

  /// 获取序列化后的 URI
  Uri get uri {
    return Uri(
      path: path,
      queryParameters: parameters.queryParams.isEmpty
          ? null
          : parameters.queryParams,
    );
  }

  /// 构建标准的 Page Key
  /// 例如：RouteMatch.generateKey('user_detail', '/user/42')
  static String generateKey(String name, String path, {String? uniqueId}) {
    return uniqueId != null ? '$name:$path[$uniqueId]' : '$name:$path';
  }

  RouteMatch copyWith({
    RouteConfig? route,
    String? path,
    RouteParameters? parameters,
    String? key,
  }) {
    return RouteMatch(
      route: route ?? this.route,
      path: path ?? this.path,
      parameters: parameters ?? this.parameters,
      key: key ?? this.key,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RouteMatch &&
        other.route == route &&
        other.path == path &&
        other.parameters == parameters &&
        other.key == key;
  }

  @override
  int get hashCode =>
      route.hashCode ^ path.hashCode ^ parameters.hashCode ^ key.hashCode;

  @override
  String toString() {
    return 'RouteMatch(route: $route.name, path: $path, key: $key, params: $parameters)';
  }
}
