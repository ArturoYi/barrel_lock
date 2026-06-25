/// 全场景路由跳转门面 API（FastNavigator）。
///
/// 职责：
/// - 对外提供 push / pop / replace / go / popUntil / pushAndPopUntil
/// - 无 Context 全局调用（通过 bind 注入 RouterDelegate）
/// - 内部只做：registry.match → NavigationState 变换 → delegate.setState
///
/// 设计原则：
/// - 对内从不调用 Navigator.push 等 1.0 命令式 API
/// - 是业务侧主要跳转入口
///
/// 依赖：core 层、domain 层
///
/// 状态：待实现（M1 基础 API，M2 全量 API）
library;
