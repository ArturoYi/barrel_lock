import 'package:core/core.dart';

import '../../runtime_auth/barrel_lock_identity_auth_ui_delegate.dart';
import 'app_lock_preferences.dart';

/// 锁屏保护身份验证服务（MVVM-C 的 M 层）。
///
/// 封装 [AppIdentityAuth] 与 [AppLockPreferences] 的联动，供各 ViewModel 复用。
/// PIN 输入 UI 通过 [IdentityAuthUiDelegate] 委托给平台（默认 [BarrelLockIdentityAuthUiDelegate]）。
final class AppLockAuthService {
  const AppLockAuthService({required this.uiDelegate});

  final IdentityAuthUiDelegate uiDelegate;

  /// 查询当前设备生物识别可用性（设置页展示用）。
  Future<BiometricAvailability> checkBiometricAvailability() {
    return AppIdentityAuth.checkBiometricAvailability();
  }

  /// 是否已设置应用内 PIN。
  Future<bool> hasAppPin() => AppIdentityAuth.hasAppPin();

  /// 保存应用内 PIN（仅哈希落盘）。
  Future<void> setAppPin(String pin) => AppIdentityAuth.setAppPin(pin);

  /// 设置备用 PIN（开启保护 / PIN 管理共用）。
  Future<void> setupFallbackPin(String pin) => setAppPin(pin);

  /// 清除应用内 PIN。
  Future<void> clearAppPin() => AppIdentityAuth.clearAppPin();

  /// 校验 PIN，不触发 UI（PIN 管理页的「验证当前密码」场景）。
  Future<bool> verifyAppPin(String pin) => AppIdentityAuth.verifyAppPin(pin);

  /// 按当前锁屏偏好执行身份验证。
  ///
  /// 调用方须先确认 [AppLockPreferences.enabled]；内部根据 [preferBiometric] 决定验证顺序。
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

  /// 是否已具备至少一种解锁方式（生物识别可用 **或** 已设应用内 PIN）。
  ///
  /// PIN 管理页清除策略等场景使用；**开启保护**改由 [AppLockEnableSetupViewModel] 门禁。
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

/// 各平台可在 [ProviderScope] 中 override；默认走全局 PIN 遮罩 + Toast。
final identityAuthUiDelegateProvider = Provider<IdentityAuthUiDelegate>(
  (ref) => BarrelLockIdentityAuthUiDelegate(ref),
);
