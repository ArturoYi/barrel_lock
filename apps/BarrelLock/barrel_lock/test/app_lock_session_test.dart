import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:core/identity_auth/biometric/noop_biometric_auth_adapter.dart';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _QueueingUiDelegate implements IdentityAuthUiDelegate {
  _QueueingUiDelegate(this.responses);

  final List<String?> responses;
  var callCount = 0;

  @override
  Future<String?> promptForAppPin({required IdentityAuthReason reason}) async {
    final index = callCount++;
    if (index >= responses.length) {
      return responses.last;
    }
    return responses[index];
  }

  @override
  Future<void> onBiometricUnavailable({
    required IdentityAuthReason reason,
  }) async {}
}

Future<void> waitForColdStartAuth(ProviderContainer container) async {
  const timeout = Duration(seconds: 2);
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    final session = container.read(appLockSessionProvider);
    if (session.isAuthenticating || session.isLocked) {
      break;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  while (DateTime.now().isBefore(deadline)) {
    final session = container.read(appLockSessionProvider);
    if (!session.isAuthenticating) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  fail('timed out waiting for app lock cold start authentication');
}

void main() {
  setUp(() async {
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
      ),
      biometricAdapter: const NoopBiometricAuthAdapter(),
    );
  });

  tearDown(() {
    AppCrypto.reset();
    AppIdentityAuth.reset();
  });

  group('AppLockSessionViewModel', () {
    test('locks on cold start when enabled and unlocks with pin', () async {
      const model = AppLockModel();
      await AppIdentityAuth.setAppPin('1234');
      await model.save(
        const AppLockPreferences(
          enabled: true,
          useBiometricOnResume: true,
          hasFallbackPin: true,
        ),
      );

      final container = ProviderContainer(
        overrides: [
          identityAuthUiDelegateProvider.overrideWithValue(
            _QueueingUiDelegate(['1234']),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(appLockSessionProvider);
      await waitForColdStartAuth(container);

      final session = container.read(appLockSessionProvider);
      expect(session.isLocked, isFalse);
      expect(session.isAuthenticating, isFalse);
    });

    test('retries authentication after pin cancellation', () async {
      const model = AppLockModel();
      await AppIdentityAuth.setAppPin('1234');
      await model.save(
        const AppLockPreferences(
          enabled: true,
          useBiometricOnResume: true,
          hasFallbackPin: true,
        ),
      );

      final delegate = _QueueingUiDelegate([null, '1234']);
      final container = ProviderContainer(
        overrides: [identityAuthUiDelegateProvider.overrideWithValue(delegate)],
      );
      addTearDown(container.dispose);

      container.read(appLockSessionProvider);
      await waitForColdStartAuth(container);

      final session = container.read(appLockSessionProvider);
      expect(session.isLocked, isFalse);
      expect(delegate.callCount, 2);
    });

    test('enters authentication when unlock is unavailable', () async {
      const model = AppLockModel();
      await model.save(
        const AppLockPreferences(
          enabled: true,
          useBiometricOnResume: true,
          hasFallbackPin: false,
        ),
      );

      final delegate = _QueueingUiDelegate([]);
      final container = ProviderContainer(
        overrides: [identityAuthUiDelegateProvider.overrideWithValue(delegate)],
      );

      container.read(appLockSessionProvider);

      const timeout = Duration(seconds: 2);
      final deadline = DateTime.now().add(timeout);
      while (DateTime.now().isBefore(deadline)) {
        final session = container.read(appLockSessionProvider);
        if (session.isAuthenticating) {
          expect(session.isLocked, isTrue);
          expect(delegate.callCount, 0);
          container.dispose();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return;
        }
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      container.dispose();
      fail('never started authenticating');
    });

    test('locks again after returning from background', () async {
      const model = AppLockModel();
      await AppIdentityAuth.setAppPin('1234');
      await model.save(
        const AppLockPreferences(
          enabled: true,
          useBiometricOnResume: true,
          hasFallbackPin: true,
        ),
      );

      final delegate = _QueueingUiDelegate(['1234', '1234']);
      final container = ProviderContainer(
        overrides: [identityAuthUiDelegateProvider.overrideWithValue(delegate)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(appLockSessionProvider.notifier);
      container.read(appLockSessionProvider);
      await waitForColdStartAuth(container);

      await notifier.onAppPaused();
      await notifier.onAppResumed();

      final session = container.read(appLockSessionProvider);
      expect(session.isLocked, isFalse);
      expect(delegate.callCount, 2);
    });
  });
}
