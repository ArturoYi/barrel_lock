/// Navigator 2.0 URL / 路径解析器（RouteInformationParser）。
///
/// 职责：
/// - `parseRouteInformation`：URL / Deep Link → [NavigationState]
/// - `restoreRouteInformation`：[NavigationState] → URL（Web 前进 / 后退 / 地址栏同步）
/// - 委托 [RouteRegistry.match] 完成路径匹配与参数提取
/// - 匹配失败时走 404 兜底，不 throw
///
/// 设计原则：
/// - 只负责「翻译」，不持有栈状态（状态归 Delegate）
/// - Parser 与 Delegate 不可双写，避免竞态
///
/// 依赖：domain 层
///
/// 状态：待实现（M1）
library;
