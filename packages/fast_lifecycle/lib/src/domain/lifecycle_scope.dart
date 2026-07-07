/// 生命周期作用域 SSOT（与原生层 `extra.lifecycleScope` 一致）。
abstract final class LifecycleScope {
  static const process = 'process';
  static const activity = 'activity';
  static const application = 'application';
  static const window = 'window';
  static const browser = 'browser';
}
