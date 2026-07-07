/// macOS NSNotification 名 SSOT（需求文档 §4.5）。
abstract final class MacosAppLifecycleState {
  // 单窗口事件（lifecycleScope = window）
  static const windowDidBecomeKey = 'NSWindowDidBecomeKeyNotification';
  static const windowDidResignKey = 'NSWindowDidResignKeyNotification';
  static const windowDidMiniaturize = 'NSWindowDidMiniaturizeNotification';
  static const windowDidDeminiaturize = 'NSWindowDidDeminiaturizeNotification';
  static const windowWillClose = 'NSWindowWillCloseNotification';

  // App 全局事件（lifecycleScope = application）
  static const applicationDidHide = 'NSApplicationDidHideNotification';
  static const applicationDidUnhide = 'NSApplicationDidUnhideNotification';
}
