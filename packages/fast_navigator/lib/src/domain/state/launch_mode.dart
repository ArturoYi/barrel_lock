/// 路由 Push 启动模式，用于处理相同路由重复入栈时的行为。
enum LaunchMode {
  /// 默认：栈内已存在目标路由（相同 name + path）时抛出 [DuplicateRouteException]。
  standard,

  /// 栈顶为目标路由时更新参数并终止 push；否则正常 push。
  singleTop,

  /// 栈内存在目标路由时弹出上层页面，复用原有实例并更新参数。
  singleTask,

  /// 栈内存在目标路由时作为新实例 push（生成唯一 Page Key）。
  multipleTop,
}
