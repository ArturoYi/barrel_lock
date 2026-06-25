/// 单条路由定义（RouteConfig）。
///
/// 职责：
/// - 声明路由 name、path 模板（如 `/user/:id`）
/// - 绑定 page builder：`Widget Function(BuildContext, RouteMatch)`
/// - 挂载路由级 [RouteMiddleware] 列表
/// - 预留 parent 字段，供 M4 Shell 嵌套扩展
///
/// 依赖：route_match、route_middleware
///
/// 状态：待实现（M1）
library;
