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
/// 状态：待实现（M3）
library;
