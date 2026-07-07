import 'package:core/core.dart';
import 'package:core/identity_auth/biometric/biometric_auth_adapter.dart';
import 'package:core/identity_auth/biometric/noop_biometric_auth_adapter.dart';
import 'package:core/identity_auth/pin/app_pin_hasher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _FakeBiometricAdapter implements BiometricAuthAdapter {
  _FakeBiometricAdapter({
    BiometricAvailability? availability,
    bool? authenticateResult,
  }) : availability = availability ?? BiometricAvailability.available,
       authenticateResult = authenticateResult ?? true;

  BiometricAvailability availability;
  bool authenticateResult;
  int authenticateCallCount = 0;
  int availabilityCallCount = 0;

  @override
  Future<BiometricAvailability> checkAvailability() async {
    availabilityCallCount++;
    return availability;
  }

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    authenticateCallCount++;
    return authenticateResult;
  }
}

final class _RecordingUiDelegate implements IdentityAuthUiDelegate {
  String? promptedPin;
  int promptCount = 0;
  int unavailableCount = 0;

  @override
  Future<String?> promptForAppPin({required IdentityAuthReason reason}) async {
    promptCount++;
    return promptedPin;
  }

  @override
  Future<void> onBiometricUnavailable({
    required IdentityAuthReason reason,
  }) async {
    unavailableCount++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  const config = IdentityAuthConfig(
    pinStorageKey: PreferenceKeys.identityAuthPin,
    preferBiometric: true,
    minPinLength: 4,
    maxPinLength: 8,
  );

  group('AppPinHasher', () {
    test('hash and verify roundtrip', () async {
      final record = await AppPinHasher.hashPin('1234');
      final valid = await AppPinHasher.verifyPin(pin: '1234', record: record);
      final invalid = await AppPinHasher.verifyPin(pin: '9999', record: record);

      expect(valid, isTrue);
      expect(invalid, isFalse);
    });
  });

  group('AppIdentityAuth', () {
    late _FakeBiometricAdapter biometric;
    late _RecordingUiDelegate ui;

    setUp(() async {
      AppIdentityAuth.reset();
      biometric = _FakeBiometricAdapter();
      ui = _RecordingUiDelegate();
      await SPStorage.init(
        appNamespace: 'core_test',
        env: 'test',
        managedKeys: PreferenceKeys.allKeys,
      );
      for (final key in PreferenceKeys.allKeys) {
        await SPStorage.remove(key);
      }
      AppIdentityAuth.init(config: config, biometricAdapter: biometric);
    });

    tearDown(() {
      AppIdentityAuth.reset();
    });

    test('throws when accessed before init', () {
      AppIdentityAuth.reset();
      expect(AppIdentityAuth.hasAppPin, throwsA(isA<StateError>()));
    });

    test('rejects duplicate init', () {
      expect(() => AppIdentityAuth.init(config: config), throwsStateError);
    });

    test('setAppPin enforces length', () {
      expect(() => AppIdentityAuth.setAppPin('12'), throwsArgumentError);
    });

    test('authenticate succeeds with biometric when available', () async {
      final result = await AppIdentityAuth.authenticate(
        reason: IdentityAuthReason.unlockOnResume,
        ui: ui,
      );

      expect(result.isSuccess, isTrue);
      expect(result.method, IdentityAuthMethod.biometric);
      expect(biometric.authenticateCallCount, 1);
      expect(ui.promptCount, 0);
    });

    test(
      'authenticate falls back to app pin when biometric unavailable',
      () async {
        biometric.availability = BiometricAvailability.notSupported;
        await AppIdentityAuth.setAppPin('1234');
        ui.promptedPin = '1234';

        final result = await AppIdentityAuth.authenticate(
          reason: IdentityAuthReason.unlockOnResume,
          ui: ui,
        );

        expect(result.isSuccess, isTrue);
        expect(result.method, IdentityAuthMethod.appPin);
        expect(ui.unavailableCount, 1);
        expect(biometric.authenticateCallCount, 0);
      },
    );

    test('authenticate returns failure for wrong app pin', () async {
      biometric.availability = BiometricAvailability.notEnrolled;
      await AppIdentityAuth.setAppPin('1234');
      ui.promptedPin = '9999';

      final result = await AppIdentityAuth.authenticate(
        reason: IdentityAuthReason.unlockOnResume,
        ui: ui,
      );

      expect(result.isFailure, isTrue);
      expect(result.message, '应用内密码错误');
    });

    test('authenticate returns unavailable when no methods exist', () async {
      biometric.availability = BiometricAvailability.notSupported;

      final result = await AppIdentityAuth.authenticate(
        reason: IdentityAuthReason.unlockOnResume,
        ui: ui,
      );

      expect(result.isUnavailable, isTrue);
    });

    test('authenticate falls back to app pin when biometric fails', () async {
      biometric.authenticateResult = false;
      await AppIdentityAuth.setAppPin('1234');
      ui.promptedPin = '1234';

      final result = await AppIdentityAuth.authenticate(
        reason: IdentityAuthReason.unlockOnResume,
        ui: ui,
      );

      expect(result.isSuccess, isTrue);
      expect(result.method, IdentityAuthMethod.appPin);
    });

    test(
      'authenticate returns unavailable when biometric fails without pin',
      () async {
        biometric.authenticateResult = false;

        final result = await AppIdentityAuth.authenticate(
          reason: IdentityAuthReason.unlockOnResume,
          ui: ui,
        );

        expect(result.isUnavailable, isTrue);
      },
    );

    test('noop biometric adapter reports not supported', () async {
      const adapter = NoopBiometricAuthAdapter();
      expect(
        await adapter.checkAvailability(),
        BiometricAvailability.notSupported,
      );
      expect(await adapter.authenticate(localizedReason: 'test'), isFalse);
    });
  });
}
