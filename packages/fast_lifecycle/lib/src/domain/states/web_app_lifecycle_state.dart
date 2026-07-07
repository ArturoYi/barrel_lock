/// Web 浏览器事件 SSOT（需求文档 §4.3 + Page Lifecycle 补充）。
abstract final class WebAppLifecycleState {
  /// `document.visibilityState` 变为 hidden。
  static const visibilityChangeHidden = 'visibilitychange_hidden';

  /// `document.visibilityState` 变为 visible。
  static const visibilityChangeVisible = 'visibilitychange_visible';

  /// 当前标签页获得焦点。
  static const windowFocus = 'window_focus';

  /// 当前标签页失去焦点（仍可能 visible）。
  static const windowBlur = 'window_blur';

  /// `pagehide`：页面被卸载或进入 BFCache。
  static const pageHide = 'pagehide';

  /// `pageshow`：页面恢复显示（含 BFCache 恢复）。
  static const pageShow = 'pageshow';

  /// Page Lifecycle API `freeze`：页面被冻结以节能。
  static const pageFreeze = 'page_freeze';

  /// Page Lifecycle API `resume`：页面从冻结恢复。
  static const pageResume = 'page_resume';

  /// `beforeunload`：页面即将卸载。
  static const beforeUnload = 'beforeunload';
}
