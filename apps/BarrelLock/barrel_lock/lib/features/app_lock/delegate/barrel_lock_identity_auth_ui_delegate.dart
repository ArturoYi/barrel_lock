import 'package:core/core.dart';

import '../view_model/app_lock_pin_prompt_view_model.dart';

/// BarrelLock 默认身份验证 UI 委托（桥接 core 与 app_lock PIN ViewModel）。
///
/// - PIN 输入 → [AppLockPinPromptViewModel.requestPin]
/// - 生物识别不可用 → Toast 提示
///
/// 各平台可 override [identityAuthUiDelegateProvider] 替换交互方式。
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
