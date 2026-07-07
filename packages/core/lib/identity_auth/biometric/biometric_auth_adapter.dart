import 'biometric_availability.dart';

/// 生物识别底层适配器抽象。
abstract interface class BiometricAuthAdapter {
  /// 探测当前环境是否可发起生物识别。
  Future<BiometricAvailability> checkAvailability();

  /// 拉起系统生物识别弹窗。
  ///
  /// 返回 `true` 表示验证通过；`false` 表示失败或用户取消。
  Future<bool> authenticate({required String localizedReason});
}
