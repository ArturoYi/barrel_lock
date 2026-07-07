/// [RawLifeCycleManager.initialize] 初始化参数。
///
/// 桌面多窗口场景必须传入唯一 [windowId] 与 [isMainWindow]。
final class LifeCycleInitOptions {
  const LifeCycleInitOptions({this.windowId, this.isMainWindow = true});

  final String? windowId;
  final bool isMainWindow;
}
