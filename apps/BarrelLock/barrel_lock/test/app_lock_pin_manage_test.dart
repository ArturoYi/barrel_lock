import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:core/identity_auth/biometric/noop_biometric_auth_adapter.dart';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class _RecordingAppLockCoordinator implements AppLockCoordinatorGateway {
  int popCount = 0;

  @override
  void pop() => popCount++;

  @override
  void openPinManage() {}
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

  group('AppLockPinManageViewModel', () {
    test('starts in setup mode when pin is missing', () async {
      final container = ProviderContainer(
        overrides: [
          appLockCoordinatorProvider.overrideWithValue(
            _RecordingAppLockCoordinator(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(
        appLockPinManageViewModelProvider.future,
      );

      expect(state.mode, AppLockPinManageMode.setup);
      expect(state.hasPin, isFalse);
    });

    test('starts in hub mode when pin exists', () async {
      await AppIdentityAuth.setAppPin('1234');

      final container = ProviderContainer(
        overrides: [
          appLockCoordinatorProvider.overrideWithValue(
            _RecordingAppLockCoordinator(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(
        appLockPinManageViewModelProvider.future,
      );

      expect(state.mode, AppLockPinManageMode.hub);
      expect(state.hasPin, isTrue);
    });

    test('changePin updates stored pin after verifying current pin', () async {
      await AppIdentityAuth.setAppPin('1234');

      final coordinator = _RecordingAppLockCoordinator();
      final container = ProviderContainer(
        overrides: [appLockCoordinatorProvider.overrideWithValue(coordinator)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        appLockPinManageViewModelProvider.notifier,
      );
      await container.read(appLockPinManageViewModelProvider.future);

      notifier.openChangeMode();
      notifier.currentPinController.text = '1234';
      notifier.pinController.text = '5678';
      notifier.confirmPinController.text = '5678';
      await notifier.changePin();

      expect(await AppIdentityAuth.verifyAppPin('5678'), isTrue);
      expect(await AppIdentityAuth.verifyAppPin('1234'), isFalse);
      expect(coordinator.popCount, 1);
    });

    test('clearPin removes stored pin and preference flag', () async {
      const model = AppLockModel();
      await AppIdentityAuth.setAppPin('1234');
      await model.save(
        const AppLockPreferences(
          enabled: false,
          useBiometricOnResume: true,
          hasFallbackPin: true,
        ),
      );

      final coordinator = _RecordingAppLockCoordinator();
      final container = ProviderContainer(
        overrides: [appLockCoordinatorProvider.overrideWithValue(coordinator)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        appLockPinManageViewModelProvider.notifier,
      );
      await container.read(appLockPinManageViewModelProvider.future);

      notifier.openClearMode();
      notifier.currentPinController.text = '1234';
      await notifier.clearPin();

      expect(await AppIdentityAuth.hasAppPin(), isFalse);
      final preferences = await model.load();
      expect(preferences.hasFallbackPin, isFalse);
      expect(coordinator.popCount, 1);
    });

    test('blocks clear when lock enabled without fallback biometric', () async {
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
          appLockCoordinatorProvider.overrideWithValue(
            _RecordingAppLockCoordinator(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = await container.read(
        appLockPinManageViewModelProvider.future,
      );

      expect(state.canClearPin, isFalse);
      expect(state.clearBlockedReason, isNotNull);
    });
  });
}
