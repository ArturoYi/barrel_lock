import 'package:flutter/widgets.dart';

import '../core/dialog_manager.dart';

/// 监听 Navigator 路由生命周期，实现弹窗与页面栈的联动。
///
/// ## 职责
///
/// - **didPush**：将当前路由标识绑定到 [DialogManager]，后续 `show` 的弹窗归属该页面
/// - **didPop / didRemove / didReplace**：页面销毁时自动 [DialogManager.dismissByRoute]
///
/// ## 与 fast_navigator 集成
///
/// 通过 [FastRouterConfig.navigatorObservers] 注入，无需业务层手动 [FastDialog.bindRoute]：
///
/// ```dart
/// FastRouterConfig(
///   routes: [...],
///   navigatorObservers: [DialogRouteObserver.forManager()],
/// );
/// ```
final class DialogRouteObserver extends NavigatorObserver {
  DialogRouteObserver({this.onRoutePushed, this.onRouteRemoved});

  /// 预置工厂：与 [DialogManager] 联动（push 绑定 / pop 清理）。
  factory DialogRouteObserver.forManager([DialogManager? manager]) {
    final target = manager ?? DialogManager.instance;
    return DialogRouteObserver(
      onRoutePushed: target.bindRoute,
      onRouteRemoved: target.dismissByRoute,
    );
  }

  /// 新路由入栈时回调；通常用于 `bindRoute`。
  final void Function(Object? routeIdentity)? onRoutePushed;

  /// 路由被 pop / remove / replace 移除时回调；通常用于 `dismissByRoute`。
  final void Function(Object? routeIdentity)? onRouteRemoved;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onRoutePushed?.call(routeIdentityOf(route));
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _notifyRemoved(route);
    // pop 后栈顶变为 previousRoute，需重新绑定，否则新弹窗仍挂在已销毁页面上。
    onRoutePushed?.call(routeIdentityOf(previousRoute));
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _notifyRemoved(route);
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) {
      _notifyRemoved(oldRoute);
    }
    if (newRoute != null) {
      onRoutePushed?.call(routeIdentityOf(newRoute));
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void _notifyRemoved(Route<dynamic> route) {
    onRouteRemoved?.call(_routeIdentity(route));
  }

  /// 路由稳定标识：优先 [RouteSettings.name]（fast_navigator 的 Page.name），
  /// 否则回退到 settings 对象的 identityHashCode。
  static Object? routeIdentityOf(Route<dynamic>? route) {
    if (route == null) {
      return null;
    }
    return _routeIdentity(route);
  }

  static Object? _routeIdentity(Route<dynamic> route) {
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return identityHashCode(route.settings);
  }
}
