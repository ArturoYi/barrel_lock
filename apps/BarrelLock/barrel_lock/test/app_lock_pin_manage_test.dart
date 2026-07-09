import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'features/app_lock/test_support.dart';

final class _RecordingAppLockCoordinator implements AppLockCoordinatorGateway {
  int popCount = 0;

  @override
  void pop() => popCount++;

  @override
  void openPinManage() {}
}

void main() {
  setUp(() async {
    await initAppLockTestEnvironment();
  });

  tearDown(resetAppLockTestEnvironment);

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
      expect(state.hasFallbackPin, isFalse);
    });

    test('starts in hub mode when pin exists', () async {
      await AppIdentityAuth.setAppPin(testAppLockPin);

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
      expect(state.hasFallbackPin, isTrue);
    });

    test('changePin updates stored pin after verifying current pin', () async {
      await AppIdentityAuth.setAppPin(testAppLockPin);

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
      await notifier.changePin(
        currentPin: testAppLockPin,
        pin: testAppLockPinAlt,
        confirmPin: testAppLockPinAlt,
      );

      expect(await AppIdentityAuth.verifyAppPin(testAppLockPinAlt), isTrue);
      expect(await AppIdentityAuth.verifyAppPin(testAppLockPin), isFalse);
      expect(coordinator.popCount, 1);
    });

    test('clearPin removes stored pin and preference flag', () async {
      const model = AppLockModel();
      await AppIdentityAuth.setAppPin(testAppLockPin);
      await model.save(
        const AppLockPreferences(enabled: false, hasFallbackPin: true),
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
      await notifier.clearPin(currentPin: testAppLockPin);

      expect(await AppIdentityAuth.hasAppPin(), isFalse);
      final preferences = await model.load();
      expect(preferences.hasFallbackPin, isFalse);
      expect(coordinator.popCount, 1);
    });

    test('blocks clear when lock enabled without fallback biometric', () async {
      const model = AppLockModel();
      await AppIdentityAuth.setAppPin(testAppLockPin);
      await model.save(
        const AppLockPreferences(enabled: true, hasFallbackPin: true),
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
