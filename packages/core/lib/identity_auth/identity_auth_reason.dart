/// 触发身份验证的业务场景。
enum IdentityAuthReason {
  /// 应用从后台恢复，需解锁。
  unlockOnResume,

  /// 访问敏感操作前的二次确认。
  confirmSensitiveAction,

  /// 首次设置或修改应用内密码。
  setupAppPin,
}

extension IdentityAuthReasonX on IdentityAuthReason {
  /// 默认提示文案；App 可在 [IdentityAuthUiDelegate] 中覆盖展示。
  String get defaultMessage => switch (this) {
    IdentityAuthReason.unlockOnResume => '请验证身份以继续',
    IdentityAuthReason.confirmSensitiveAction => '请验证身份以继续操作',
    IdentityAuthReason.setupAppPin => '请验证身份以设置应用密码',
  };
}
