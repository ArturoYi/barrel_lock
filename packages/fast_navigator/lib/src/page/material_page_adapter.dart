import 'package:flutter/material.dart';

import '../domain/match/route_match.dart';

/// 将 [RouteMatch] 包装为 [MaterialPage] 的适配器。
abstract final class MaterialPageAdapter {
  static MaterialPage<void> build({
    required RouteMatch match,
    required Widget child,
  }) {
    return MaterialPage<void>(
      key: ValueKey(match.key),
      name: match.route.name,
      arguments: match.parameters,
      child: child,
    );
  }
}
