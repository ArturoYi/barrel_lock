/// Linux GTK 窗口事件 SSOT（需求文档 §4.4）。
abstract final class LinuxAppLifecycleState {
  static const windowMinimize = 'window_minimize';
  static const windowRestore = 'window_restore';
  static const windowFocus = 'window_focus';
  static const windowBlur = 'window_blur';
  static const windowClose = 'window_close';
}
