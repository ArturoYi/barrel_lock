import 'package:flutter/material.dart';
import '../domain/match/route_match.dart';

/// Navigator 2.0 最小页面单元（FastPage，替代 Route）。
///
/// 职责：
/// - 继承 [Page]，从 [RouteMatch] 构造
/// - 规范 Key 策略，保证 Page Diff 复用 / 销毁精准
/// - `createRoute()` 创建 MaterialPageRoute
///
/// 设计原则：
/// - Key 由 RouteMatch.key 决定
/// - 是 Delegate.build 中 pages 列表的唯一元素类型
///
/// 依赖：domain 层
///
/// 状态：已实现（M1）
class FastPage extends Page<dynamic> {
  final RouteMatch match;

  FastPage({required this.match})
      : super(
          key: ValueKey(match.key),
          name: match.route.name,
          arguments: match.parameters,
        );

  @override
  Route<dynamic> createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (ctx) => match.route.builder(ctx, match),
    );
  }
}
