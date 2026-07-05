/// 弹窗模态类型。
enum DialogMode {
  /// 模态：默认拦截遮罩以下点击（可配合 [DialogShowConfig.usePenetrate] 穿透）。
  modal,

  /// 非模态：不渲染遮罩，仅展示内容面板，底层页面仍可交互。
  nonModal,
}
