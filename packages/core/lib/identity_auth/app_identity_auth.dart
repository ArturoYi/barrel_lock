import 'package:flutter/foundation.dart';

import 'biometric/biometric_auth_adapter.dart';
import 'biometric/biometric_auth_adapter_factory.dart';
import 'biometric/biometric_availability.dart';
import 'identity_auth_config.dart';
import 'identity_auth_method.dart';
import 'identity_auth_reason.dart';
import 'identity_auth_result.dart';
import 'identity_auth_ui_delegate.dart';
import 'pin/app_pin_store.dart';

/// 用户身份验证门面：生物识别优先，不可用时回退应用内 PIN。
///
/// ## 职责边界
///
/// - core 封装 [local_auth] 与 PIN 哈希校验
/// - PIN 输入 UI 由 [IdentityAuthUiDelegate] 在各平台 App 实现
/// - 不替代系统锁屏；设备未设密码时 [checkBiometricAvailability] 返回
///   [BiometricAvailability.deviceNotSecure]
///
/// ## 初始化
///
/// ```dart
/// await SPStorage.init(
///   appNamespace: 'barrel_lock',
///   managedKeys: [...PreferenceKeys.allKeys, ...],
/// );
/// AppIdentityAuth.init(
///   config: IdentityAuthConfig(pinStorageKey: PreferenceKeys.identityAuthPin),
/// );
/// ```
///
/// ## 验证
///
/// ```dart
/// final result = await AppIdentityAuth.authenticate(
///   reason: IdentityAuthReason.unlockOnResume,
///   ui: myUiDelegate,
/// );
/// if (result.isSuccess) { /* 解锁 */ }
/// ```
final class AppIdentityAuth {
  AppIdentityAuth._();

  static IdentityAuthConfig? _config;
  static BiometricAuthAdapter? _biometric;
  static AppPinStore? _pinStore;

  /// 初始化；进程内仅允许调用一次。
  static void init({
    required IdentityAuthConfig config,
    BiometricAuthAdapter? biometricAdapter,
  }) {
    if (_config != null) {
      throw StateError('AppIdentityAuth 已初始化，不可重复调用 init()');
    }

    config.validate();
    _config = config;
    _biometric = biometricAdapter ?? createBiometricAuthAdapter();
    _pinStore = AppPinStore(storageKey: config.pinStorageKey);
  }

  /// 当前生物识别可用性。
  static Future<BiometricAvailability> checkBiometricAvailability() {
    return _requireBiometric().checkAvailability();
  }

  /// 是否已设置应用内 PIN。
  static Future<bool> hasAppPin() {
    return _requirePinStore().hasPin();
  }

  /// 设置或更新应用内 PIN（仅哈希落盘，不存明文）。
  static Future<void> setAppPin(String pin) {
    _validatePinLength(pin);
    return _requirePinStore().savePin(pin);
  }

  /// 校验应用内 PIN，不触发 UI。
  static Future<bool> verifyAppPin(String pin) {
    return _requirePinStore().verifyPin(pin);
  }

  /// 清除已保存的应用内 PIN。
  static Future<void> clearAppPin() {
    return _requirePinStore().clearPin();
  }

  /// 统一身份验证入口：生物识别 → 应用内 PIN → unavailable。
  ///
  /// [preferBiometric] 为 `null` 时使用 [IdentityAuthConfig.preferBiometric]。
  static Future<IdentityAuthResult> authenticate({
    required IdentityAuthReason reason,
    required IdentityAuthUiDelegate ui,
    bool? preferBiometric,
  }) async {
    final config = _requireConfig();
    final useBiometric = preferBiometric ?? config.preferBiometric;

    if (useBiometric) {
      final biometricResult = await _tryBiometric(
        reason: reason,
        config: config,
        ui: ui,
      );
      if (biometricResult != null) {
        return biometricResult;
      }
    }

    return _tryAppPin(reason: reason, ui: ui);
  }

  static Future<IdentityAuthResult?> _tryBiometric({
    required IdentityAuthReason reason,
    required IdentityAuthConfig config,
    required IdentityAuthUiDelegate ui,
  }) async {
    final availability = await _requireBiometric().checkAvailability();
    if (availability == BiometricAvailability.available) {
      final localizedReason =
          config.biometricLocalizedReason ?? reason.defaultMessage;
      final passed = await _requireBiometric().authenticate(
        localizedReason: localizedReason,
      );
      if (passed) {
        return IdentityAuthResult.success(method: IdentityAuthMethod.biometric);
      }
      // 等待系统 LocalAuthentication 弹窗完全关闭，再回退应用内 PIN。
      await _waitForBiometricUiDismissal();
      // 生物识别 / 设备密码均未通过时继续尝试应用内 PIN（若已配置）。
    } else if (availability == BiometricAvailability.notEnrolled ||
        availability == BiometricAvailability.deviceNotSecure ||
        availability == BiometricAvailability.notSupported) {
      await ui.onBiometricUnavailable(reason: reason);
    }

    return null;
  }

  static Future<IdentityAuthResult> _tryAppPin({
    required IdentityAuthReason reason,
    required IdentityAuthUiDelegate ui,
  }) async {
    if (!await _requirePinStore().hasPin()) {
      return IdentityAuthResult.unavailable(message: '生物识别不可用且未设置应用内密码');
    }

    final pin = await ui.promptForAppPin(reason: reason);
    if (pin == null) {
      return IdentityAuthResult.cancelled(message: '用户取消输入应用内密码');
    }

    final valid = await _requirePinStore().verifyPin(pin);
    if (valid) {
      return IdentityAuthResult.success(method: IdentityAuthMethod.appPin);
    }

    return IdentityAuthResult.failure(message: '密码错误，请重试');
  }

  static Future<void> _waitForBiometricUiDismissal() async {
    final delay = switch (defaultTargetPlatform) {
      TargetPlatform.iOS => const Duration(milliseconds: 500),
      TargetPlatform.android => const Duration(milliseconds: 400),
      _ => Duration.zero,
    };
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
  }

  static void _validatePinLength(String pin) {
    final config = _requireConfig();
    if (pin.length < config.minPinLength || pin.length > config.maxPinLength) {
      throw ArgumentError.value(
        pin,
        'pin',
        '长度须在 ${config.minPinLength}–${config.maxPinLength} 之间',
      );
    }
  }

  static IdentityAuthConfig _requireConfig() {
    final config = _config;
    if (config == null) {
      throw StateError(
        'AppIdentityAuth 未初始化，请在 main 先执行 AppIdentityAuth.init()',
      );
    }
    return config;
  }

  static BiometricAuthAdapter _requireBiometric() {
    final biometric = _biometric;
    if (biometric == null) {
      throw StateError(
        'AppIdentityAuth 未初始化，请在 main 先执行 AppIdentityAuth.init()',
      );
    }
    return biometric;
  }

  static AppPinStore _requirePinStore() {
    final pinStore = _pinStore;
    if (pinStore == null) {
      throw StateError(
        'AppIdentityAuth 未初始化，请在 main 先执行 AppIdentityAuth.init()',
      );
    }
    return pinStore;
  }

  /// 测试专用：释放单例状态。
  @visibleForTesting
  static void reset() {
    _config = null;
    _biometric = null;
    _pinStore = null;
  }
}
