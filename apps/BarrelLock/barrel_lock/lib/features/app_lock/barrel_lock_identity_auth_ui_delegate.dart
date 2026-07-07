import 'package:core/core.dart';

import 'app_lock_pin_prompt.dart';

/// BarrelLock 默认身份验证 UI 委托：PIN 走全局遮罩，提示走 Toast。
final class BarrelLockIdentityAuthUiDelegate implements IdentityAuthUiDelegate {
  BarrelLockIdentityAuthUiDelegate(this._ref);

  final Ref _ref;

  @override
  Future<String?> promptForAppPin({required IdentityAuthReason reason}) {
    return _ref.read(appLockPinPromptProvider.notifier).requestPin(reason);
  }

  @override
  Future<void> onBiometricUnavailable({
    required IdentityAuthReason reason,
  }) async {
    FastToast.show('生物识别不可用，请使用应用内密码');
  }
}
