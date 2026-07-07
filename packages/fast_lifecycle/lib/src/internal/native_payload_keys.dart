/// EventChannel 跨端载荷字段名 SSOT（Dart / Kotlin / Swift / C++ 必须保持一致）。
///
/// 标准载荷结构：
/// ```json
/// {
///   "source": "android | ios | macos | windows | linux | web",
///   "rawState": "<系统原生原始字符串，禁止翻译>",
///   "extra": {
///     "lifecycleScope": "<可选，process | activity | application | window>",
///     "windowId": "<可选，桌面多窗口溯源>",
///     "isMainWindow": true,
///     "metadata": {}
///   }
/// }
/// ```
abstract final class NativePayloadKeys {
  static const source = 'source';
  static const rawState = 'rawState';
  static const extra = 'extra';
  static const lifecycleScope = 'lifecycleScope';
  static const windowId = 'windowId';
  static const isMainWindow = 'isMainWindow';
  static const metadata = 'metadata';
}
