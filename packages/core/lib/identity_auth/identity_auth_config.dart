/// [AppIdentityAuth] 初始化配置。
final class IdentityAuthConfig {
  const IdentityAuthConfig({
    required this.pinStorageKey,
    this.preferBiometric = true,
    this.biometricLocalizedReason,
    this.minPinLength = 4,
    this.maxPinLength = 32,
  });

  /// 应用内 PIN 哈希在 [SPStorage] 中的 rawKey，须已登记到受管白名单。
  final String pinStorageKey;

  /// 优先尝试生物识别；不可用时自动回退应用内 PIN。
  final bool preferBiometric;

  /// 传给 local_auth 的系统弹窗文案；为空时使用 [IdentityAuthReason.defaultMessage]。
  final String? biometricLocalizedReason;

  /// 设置 PIN 时的最小长度（仅 [AppIdentityAuth.setAppPin] 校验）。
  final int minPinLength;

  /// 设置 PIN 时的最大长度。
  final int maxPinLength;

  void validate() {
    if (pinStorageKey.isEmpty) {
      throw ArgumentError.value(pinStorageKey, 'pinStorageKey', '不能为空');
    }
    if (minPinLength < 1) {
      throw ArgumentError.value(minPinLength, 'minPinLength', '必须 >= 1');
    }
    if (maxPinLength < minPinLength) {
      throw ArgumentError.value(
        maxPinLength,
        'maxPinLength',
        '不能小于 minPinLength',
      );
    }
  }
}
