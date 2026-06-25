/// Navigator 2.0 页面栈管理者（RouterDelegate，核心中的核心）。
///
/// 职责：
/// - 持有唯一可变源 [NavigationState]（通过不可变替换更新）
/// - `build()` 将 `matches` 映射为 `List<Page>` 驱动 [Navigator]
/// - 实现 `popRoute()` 兼容系统返回（物理键 / 手势 / Web 后退）
/// - `onPopPage` 与 `popRoute()` 共用同一 pop 逻辑，防 double-pop
/// - 混入 [PopNavigatorRouterDelegateMixin] 绑定 navigatorKey
/// - 提供 `setState()` 作为唯一写入口，变更后 `notifyListeners()`
///
/// 设计原则：
/// - 禁止绕过本类直接修改栈
/// - 所有栈操作经 Middleware 管道后再赋值
///
/// 依赖：domain 层、page 层
///
/// 状态：待实现（M1）
library;
