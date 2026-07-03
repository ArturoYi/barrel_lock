/// Toast 展示优先级。
enum ToastPriority {
  /// 默认：按 FIFO 入队，受队列容量限制。
  normal,

  /// 高优：立即关闭当前 Toast，插队到队列首位并马上展示。
  high,
}
