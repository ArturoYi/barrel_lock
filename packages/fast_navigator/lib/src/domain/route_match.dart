/// 单次路由匹配结果（RouteMatch，参数持久绑定单元）。
///
/// 职责：
/// - 绑定一次路由解析的全部上下文：path、routeName、pathParams、queryParams、extra
/// - 提供 `uri` 序列化与 `pageKey` 生成（Page Diff 关键）
///
/// Page Key 策略：
/// - 默认：`routeName:path`
/// - 同路由重复 push：加 stackIndex 或 uuid
/// - extra 不纳入 Key
///
/// 依赖：无（纯数据模型）
///
/// 状态：待实现（M1）
library;
