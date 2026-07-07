import 'biometric_auth_adapter.dart';
import 'biometric_availability.dart';

/// 不支持生物识别的平台回退实现。
final class NoopBiometricAuthAdapter implements BiometricAuthAdapter {
  const NoopBiometricAuthAdapter();

  @override
  Future<BiometricAvailability> checkAvailability() async {
    return BiometricAvailability.notSupported;
  }

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    return false;
  }
}
