import 'biometric_auth_adapter.dart';

import 'biometric_auth_adapter_stub.dart'
    if (dart.library.io) 'biometric_auth_adapter_io.dart';

/// 创建当前平台的 [BiometricAuthAdapter] 实例。
BiometricAuthAdapter createBiometricAuthAdapter() {
  return createPlatformBiometricAuthAdapter();
}
