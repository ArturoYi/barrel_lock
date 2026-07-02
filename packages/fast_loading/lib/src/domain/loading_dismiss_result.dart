/// [FastLoading.dismiss] 关闭时的结果态。
enum LoadingDismissResult {
  /// 直接关闭，不展示结果 Widget。
  none,

  /// 成功结果态；优先 [LoadingStyle.successWidget] / dismiss 的 [resultWidget]，否则内置 icon。
  success,

  /// 失败结果态；优先 [LoadingStyle.errorWidget] / dismiss 的 [resultWidget]，否则内置 icon。
  error,
}
