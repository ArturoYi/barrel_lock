import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:core/identity_auth/biometric/noop_biometric_auth_adapter.dart';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _RecordingAppLockCoordinator implements AppLockCoordinatorGateway {
  int openPinManageCount = 0;

  @override
  void pop() {}

  @override
  void openPinManage() => openPinManageCount++;
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

  group('AppLockViewModel', () {
    test('rejects enabling lock without unlock method', () async {
      final container = ProviderContainer(
        overrides: [
          appLockCoordinatorProvider.overrideWithValue(
            _RecordingAppLockCoordinator(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(appLockViewModelProvider.notifier);
      await container.read(appLockViewModelProvider.future);

      await notifier.onEnabledChanged(true);

      final state = container.read(appLockViewModelProvider).requireValue;
      expect(state.preferences.enabled, isFalse);
      expect(state.statusMessage, isNotNull);
    });

    test('allows enabling lock after fallback pin is configured', () async {
      await AppIdentityAuth.setAppPin('1234');

      final container = ProviderContainer(
        overrides: [
          appLockCoordinatorProvider.overrideWithValue(
            _RecordingAppLockCoordinator(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(appLockViewModelProvider.notifier);
      await container.read(appLockViewModelProvider.future);

      await notifier.onEnabledChanged(true);

      final state = container.read(appLockViewModelProvider).requireValue;
      expect(state.preferences.enabled, isTrue);
      expect(state.statusMessage, isNull);
    });

    test('openPinManage navigates through coordinator', () async {
      final coordinator = _RecordingAppLockCoordinator();
      final container = ProviderContainer(
        overrides: [appLockCoordinatorProvider.overrideWithValue(coordinator)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(appLockViewModelProvider.notifier);
      await container.read(appLockViewModelProvider.future);

      notifier.onOpenPinManage();

      expect(coordinator.openPinManageCount, 1);
    });
  });
}
