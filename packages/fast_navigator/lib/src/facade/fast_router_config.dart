/// MaterialApp.router 一键接入配置（FastRouterConfig）。
///
/// 职责：
/// - 封装 [FastRouter.config] 的便捷构造
/// - 统一 initialLocation、middlewares、routes 等接入参数
/// - 可选：主题、title、locale 等与路由无关的 App 级配置桥接
///
/// 设计原则：
/// - 薄封装，不隐藏 Navigator 2.0 原理
/// - 降低 App 层 boilerplate
///
/// 依赖：core 层
///
/// 状态：待实现（M1）
library;
