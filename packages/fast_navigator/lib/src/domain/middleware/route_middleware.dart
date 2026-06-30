import 'dart:async';
import '../state/navigation_state.dart';

/// 路由拦截结果，可定义更复杂的行为。通常我们使用新 State 表示重定向，null 表示放行。
typedef MiddlewareResult = FutureOr<NavigationState?>;

/// 路由拦截 / 中间件机制（RouteMiddleware）。
///
/// 职责：
/// - 定义 `handle(from, to) → NavigationState?` 拦截协议
/// - 返回 null：放行；返回新 State：redirect 短路（如登录校验、权限拦截）
/// - 支持全局 middleware（Router 级）与单路由 middleware（RouteConfig 级）
///
/// 执行顺序：
/// globalMiddlewares → route.middlewares → delegate.setState
///
/// 注意：
/// - 需 redirectLimit 防死循环（建议默认 5 次，M3 实现）
///
/// 状态：已实现（M3）
abstract class RouteMiddleware {
  /// 处理路由跳转事件
  ///
  /// [currentState] 跳转前的导航状态
  /// [targetState] 目标导航状态（意图跳转的 state）
  /// 
  /// 返回：
  /// - `null`：允许当前跳转继续（放行）
  /// - `NavigationState`：中断当前跳转，重定向到新的状态
  MiddlewareResult handle(NavigationState currentState, NavigationState targetState);
}

/// 简易闭包风格中间件
class FunctionalRouteMiddleware extends RouteMiddleware {
  final MiddlewareResult Function(NavigationState current, NavigationState target) _handler;

  FunctionalRouteMiddleware(this._handler);

  @override
  MiddlewareResult handle(NavigationState currentState, NavigationState targetState) {
    return _handler(currentState, targetState);
  }
}
