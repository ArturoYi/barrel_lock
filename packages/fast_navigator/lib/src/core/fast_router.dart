/// Navigator 2.0 顶层路由容器（Router 组装层）。
///
/// 职责：
/// - 组合 [FastRouterDelegate]、[FastRouteInformationParser]、[BackButtonDispatcher]
/// - 产出 `RouterConfig<NavigationState>` 供 `MaterialApp.router` 接入
/// - 初始化 [RouteRegistry] 并绑定 [FastNavigator] 门面
///
/// 设计原则：
/// - 本层只做组装，不持有业务状态
/// - 是 App 接入路由的唯一入口工厂
///
/// 依赖：domain 层、facade 层
///
/// 状态：待实现（M1）
library;
