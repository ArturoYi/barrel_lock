/// Toast 挂载的 Overlay 层级。
enum ToastOverlayLayer {
  /// 默认层：与 [FastToastOverlay] 在 App 内容树中的挂载位置一致。
  normal,

  /// 高层：需额外挂载一个 [FastToastOverlay]（`layer: elevated`），
  /// 用于展示在 App 级遮罩（如锁屏）之上的 Toast。
  elevated,
}
