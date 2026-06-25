/// 路由表注册与匹配引擎（RouteRegistry）。
///
/// 职责：
/// - 注册 / 查询 [RouteConfig] 路由定义
/// - `match(location)`：最长前缀匹配，支持 `:param` 动态路径段
/// - `unknown(location)`：404 兜底匹配，永不 throw
/// - `findByName(name)`：按路由名反查配置
///
/// 设计原则：
/// - 匹配逻辑与渲染、栈管理解耦
/// - 为 Parser（URL→State）和 FastNavigator（API→State）共用
///
/// 依赖：route_config、route_match
///
/// 状态：待实现（M1）
library;
