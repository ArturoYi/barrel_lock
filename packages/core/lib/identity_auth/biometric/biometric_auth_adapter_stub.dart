import 'biometric_auth_adapter.dart';

import 'noop_biometric_auth_adapter.dart';

/// 非 IO / 非 Web 环境的默认回退。
BiometricAuthAdapter createPlatformBiometricAuthAdapter() {
  return const NoopBiometricAuthAdapter();
}
