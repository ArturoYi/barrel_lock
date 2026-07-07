/// 本次验证实际使用的手段。
enum IdentityAuthMethod {
  /// 系统生物识别（local_auth）。
  biometric,

  /// 应用内密码（PIN）。
  appPin,
}
