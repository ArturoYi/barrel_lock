import 'identity_auth_reason.dart';

/// 应用内密码验证 UI 委托，由各平台 App 实现。
///
/// core 只负责校验逻辑；PIN 输入界面、错误提示样式由外部提供。
abstract interface class IdentityAuthUiDelegate {
  /// 弹出应用内密码输入 UI，返回用户输入的 PIN。
  ///
  /// 用户取消时返回 `null`。
  Future<String?> promptForAppPin({required IdentityAuthReason reason});

  /// 生物识别不可用时的可选提示（如引导用户设置 PIN）。
  ///
  /// 默认实现为空操作，平台可按需覆盖。
  Future<void> onBiometricUnavailable({
    required IdentityAuthReason reason,
  }) async {}
}
