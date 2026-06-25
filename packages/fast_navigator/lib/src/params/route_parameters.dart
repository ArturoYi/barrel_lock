/// 多层路由参数模型（RouteParameters）。
///
/// 职责：
/// - 统一封装 pathParams（动态路径 :id）、queryParams（?key=val）、extra（内存附加）
/// - 提供解析 / 合并 / 序列化工具
/// - 区分可 URL 持久化参数 vs 不可序列化 extra
///
/// 参数层次：
/// ```
/// /user/42?tab=info
///  ──path──  query
///    :id
/// ```
///
/// 依赖：无（纯工具 / 值对象）
///
/// 状态：待实现（M2）
library;
