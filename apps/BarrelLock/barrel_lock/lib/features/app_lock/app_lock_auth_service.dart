import 'package:core/core.dart';

import 'app_lock_model.dart';
import 'barrel_lock_identity_auth_ui_delegate.dart';

/// 锁屏保护身份验证服务（M 层），封装 [AppIdentityAuth] 与偏好联动。
final class AppLockAuthService {
  const AppLockAuthService({required this.uiDelegate});

  final IdentityAuthUiDelegate uiDelegate;

  Future<BiometricAvailability> checkBiometricAvailability() {
    return AppIdentityAuth.checkBiometricAvailability();
  }

  Future<bool> hasAppPin() => AppIdentityAuth.hasAppPin();

  Future<void> setAppPin(String pin) => AppIdentityAuth.setAppPin(pin);

  Future<void> clearAppPin() => AppIdentityAuth.clearAppPin();

  /// 按当前锁屏偏好执行身份验证（调用方须确认 [AppLockPreferences.enabled]）。
  Future<IdentityAuthResult> authenticateForAppLock({
    required IdentityAuthReason reason,
    required AppLockPreferences preferences,
  }) {
    return AppIdentityAuth.authenticate(
      reason: reason,
      ui: uiDelegate,
      preferBiometric: preferences.useBiometricOnResume,
    );
  }

  /// 是否已具备至少一种解锁方式（生物识别或应用内 PIN）。
  Future<bool> hasAnyUnlockMethod() async {
    final availability = await checkBiometricAvailability();
    if (availability == BiometricAvailability.available) {
      return true;
    }
    return hasAppPin();
  }
}

final appLockAuthServiceProvider = Provider<AppLockAuthService>((ref) {
  return AppLockAuthService(
    uiDelegate: ref.watch(identityAuthUiDelegateProvider),
  );
});

/// 各平台可 override；默认使用 [BarrelLockIdentityAuthUiDelegate]。
final identityAuthUiDelegateProvider = Provider<IdentityAuthUiDelegate>(
  (ref) => BarrelLockIdentityAuthUiDelegate(ref),
);
