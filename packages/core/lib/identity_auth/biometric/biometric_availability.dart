/// 生物识别可用性状态。
enum BiometricAvailability {
  /// 可发起生物识别。
  available,

  /// 当前平台或插件不支持。
  notSupported,

  /// 设备未设置锁屏密码/图案，无法使用生物识别。
  deviceNotSecure,

  /// 设备支持但未录入指纹/面容等。
  notEnrolled,
}
