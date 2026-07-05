import 'package:fast_navigator/fast_navigator.dart';
import 'package:flutter/widgets.dart';

/// 单个页面的 Widget 构建签名。
///
/// [match] 携带 path / query / extra 参数，供带参路由解析后传入 Page。
typedef AppRouteBuilder =
    Widget Function(BuildContext context, RouteMatch match);

/// 平台 app 向 [AppRouter] 注入的页面构建器集合。
///
/// 各平台在 `lib/router/app_router_config.dart` 中提供实现，
/// 将本地 `pages/` Widget 装配进共享路由表，实现「路由统一、页面分平台」。
final class AppRouteBuilders {
  const AppRouteBuilders({
    required this.launchScreen,
    required this.home,
    required this.detail,
    required this.settings,
  });

  final AppRouteBuilder launchScreen;
  final AppRouteBuilder home;
  final AppRouteBuilder detail;
  final AppRouteBuilder settings;
}
