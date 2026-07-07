import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import 'biometric_auth_adapter.dart';
import 'biometric_availability.dart';
import 'noop_biometric_auth_adapter.dart';

/// 按当前运行平台创建 [BiometricAuthAdapter]。
BiometricAuthAdapter createPlatformBiometricAuthAdapter() {
  if (kIsWeb) {
    return const NoopBiometricAuthAdapter();
  }

  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    return LocalAuthBiometricAuthAdapter(localAuth: LocalAuthentication());
  }

  // Windows / Linux 等：local_auth 能力不完整，统一回退 noop。
  return const NoopBiometricAuthAdapter();
}

/// 基于 [local_auth] 的移动 / 桌面生物识别实现。
final class LocalAuthBiometricAuthAdapter implements BiometricAuthAdapter {
  LocalAuthBiometricAuthAdapter({required this.localAuth});

  final LocalAuthentication localAuth;

  @override
  Future<BiometricAvailability> checkAvailability() async {
    try {
      final isSupported = await localAuth.isDeviceSupported();
      if (!isSupported) {
        return BiometricAvailability.notSupported;
      }

      final canCheck = await localAuth.canCheckBiometrics;
      if (!canCheck) {
        return BiometricAvailability.deviceNotSecure;
      }

      final biometrics = await localAuth.getAvailableBiometrics();
      if (biometrics.isEmpty) {
        return BiometricAvailability.notEnrolled;
      }

      return BiometricAvailability.available;
    } on PlatformException {
      return BiometricAvailability.notSupported;
    }
  }

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    try {
      return await localAuth.authenticate(
        localizedReason: localizedReason,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(signInTitle: '身份验证', cancelButton: '取消'),
          IOSAuthMessages(cancelButton: '取消'),
        ],
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
