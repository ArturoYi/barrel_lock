import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:core/identity_auth/biometric/noop_biometric_auth_adapter.dart';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const testAppLockPin = '123456';
const testAppLockPinAlt = '567890';

Future<void> initAppLockTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  AppCrypto.reset();
  AppIdentityAuth.reset();
  await SPStorage.init(
    appNamespace: 'barrel_lock',
    env: 'test',
    managedKeys: [
      ...PreferenceKeys.allKeys,
      ...BarrelLockPreferenceKeys.allKeys,
    ],
  );
  await BarrelLockCrypto.init();
  Cryptography.instance = DartCryptography.defaultInstance.withRandom(
    SecureRandom.forTesting(seed: 42),
  );
  AppIdentityAuth.init(
    config: const IdentityAuthConfig(
      pinStorageKey: PreferenceKeys.identityAuthPin,
      minPinLength: AppLockPinPolicy.length,
      maxPinLength: AppLockPinPolicy.length,
    ),
    biometricAdapter: const NoopBiometricAuthAdapter(),
  );
}

void resetAppLockTestEnvironment() {
  AppCrypto.reset();
  AppIdentityAuth.reset();
}
