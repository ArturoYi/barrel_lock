/// Navigator 2.0 最小页面单元（FastPage，替代 Route）。
///
/// 职责：
/// - 继承 [Page]，从 [RouteMatch] + [RouteRegistry] 工厂构造
/// - 规范 Key 策略，保证 Page Diff 复用 / 销毁精准
/// - `createRoute()` 创建 MaterialPageRoute（或通过 RouteConfig 自定义）
///
/// 设计原则：
/// - Key 由 RouteMatch.pageKey 决定，extra 不参与
/// - 是 Delegate.build 中 pages 列表的唯一元素类型
///
/// 依赖：domain 层
///
/// 状态：待实现（M1）
library;
