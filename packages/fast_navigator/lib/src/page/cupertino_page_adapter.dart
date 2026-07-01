import 'package:flutter/cupertino.dart';

import '../domain/match/route_match.dart';

/// 将 [RouteMatch] 包装为 [CupertinoPage] 的适配器。
abstract final class CupertinoPageAdapter {
  static CupertinoPage<void> build({
    required RouteMatch match,
    required Widget child,
  }) {
    return CupertinoPage<void>(
      key: ValueKey(match.key),
      name: match.route.name,
      arguments: match.parameters,
      child: child,
    );
  }
}
