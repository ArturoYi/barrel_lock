/// 不可变导航状态（NavigationState，SSOT 唯一真相源）。
///
/// 职责：
/// - 持有 `List<RouteMatch> matches`（从底到顶的页面栈）
/// - 提供纯函数式栈操作，均返回新实例：
///   push / pop / replace / go / popUntil / pushAndPopUntil
/// - 暴露 `location` 供 Web URL 回写（通常为栈顶 URI）
///
/// 设计原则：
/// - @immutable，禁止直接 mutate matches 列表
/// - 所有变更必须新 List 拷贝，保证 Page Diff 机制生效
///
/// 状态：待实现（M1）
library;
