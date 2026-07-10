import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_support.dart';

const testAppLockHint = '我的宠物叫小白';

final class _RecordingEnableSetupCoordinator
    implements AppLockEnableSetupCoordinatorGateway {
  int completedCount = 0;
  int cancelledCount = 0;

  @override
  void onEnableSetupCompleted() => completedCount++;

  @override
  void onEnableSetupCancelled() => cancelledCount++;
}

void main() {
  setUp(() async {
    await initAppLockTestEnvironment();
  });

  tearDown(resetAppLockTestEnvironment);

  group('AppLockEnableSetupViewModel', () {
    test('begin shows setup panel on pin step without enabling lock', () async {
      final container = ProviderContainer(
        overrides: appLockEnableSetupTestOverrides(
          coordinator: _RecordingEnableSetupCoordinator(),
        ),
      );
      addTearDown(container.dispose);
      final subscription = keepAppLockEnableSetupAlive(container);
      addTearDown(subscription.close);

      container.read(appLockEnableSetupProvider.notifier).begin();

      final setup = container.read(appLockEnableSetupProvider);
      expect(setup.isVisible, isTrue);
      expect(setup.phase, AppLockEnableSetupPhase.active);
      expect(setup.step, AppLockEnableSetupStep.pin);

      expect(await const AppLockModel().loadEnabled(), isFalse);
    });

    test('continueToHintStep advances to hint step after valid pin', () async {
      final container = ProviderContainer(
        overrides: appLockEnableSetupTestOverrides(
          coordinator: _RecordingEnableSetupCoordinator(),
        ),
      );
      addTearDown(container.dispose);
      final subscription = keepAppLockEnableSetupAlive(container);
      addTearDown(subscription.close);

      final notifier = container.read(appLockEnableSetupProvider.notifier);
      notifier.begin();
      notifier.continueToHintStep(
        pin: testAppLockPin,
        confirmPin: testAppLockPin,
      );

      final setup = container.read(appLockEnableSetupProvider);
      expect(setup.step, AppLockEnableSetupStep.hint);
      expect(setup.errorMessage, isNull);
      expect(await const AppLockModel().loadEnabled(), isFalse);
    });

    test('submitSetup enables lock after saving pin and hint', () async {
      final coordinator = _RecordingEnableSetupCoordinator();
      final container = ProviderContainer(
        overrides: appLockEnableSetupTestOverrides(coordinator: coordinator),
      );
      addTearDown(container.dispose);
      final subscription = keepAppLockEnableSetupAlive(container);
      addTearDown(subscription.close);

      await container.read(appLockSettingsViewModelProvider.future);
      container.read(appLockSessionProvider);
      final notifier = container.read(appLockEnableSetupProvider.notifier);
      notifier.begin();
      notifier.continueToHintStep(
        pin: testAppLockPin,
        confirmPin: testAppLockPin,
      );

      await notifier.submitSetup(
        pin: testAppLockPin,
        confirmPin: testAppLockPin,
        hint: testAppLockHint,
      );

      expect(container.read(appLockEnableSetupProvider).isVisible, isFalse);
      expect(coordinator.completedCount, 1);

      expect(await const AppLockModel().loadEnabled(), isTrue);
      expect(await AppIdentityAuth.hasAppPin(), isTrue);
      expect(await const AppLockModel().loadFallbackPinHint(), testAppLockHint);

      final preferences = await createTestPreferencesRepository().load();
      expect(preferences.hasFallbackPin, isTrue);
      expect(preferences.fallbackPinHint, testAppLockHint);
    });

    test('continueToHintStep rejects invalid confirmation', () async {
      final container = ProviderContainer(
        overrides: appLockEnableSetupTestOverrides(
          coordinator: _RecordingEnableSetupCoordinator(),
        ),
      );
      addTearDown(container.dispose);
      final subscription = keepAppLockEnableSetupAlive(container);
      addTearDown(subscription.close);

      final notifier = container.read(appLockEnableSetupProvider.notifier);
      notifier.begin();
      notifier.continueToHintStep(pin: testAppLockPin, confirmPin: '654321');

      final setup = container.read(appLockEnableSetupProvider);
      expect(setup.step, AppLockEnableSetupStep.pin);
      expect(setup.errorMessage, isNotNull);
    });

    test('submitSetup rejects empty hint', () async {
      final container = ProviderContainer(
        overrides: appLockEnableSetupTestOverrides(
          coordinator: _RecordingEnableSetupCoordinator(),
        ),
      );
      addTearDown(container.dispose);
      final subscription = keepAppLockEnableSetupAlive(container);
      addTearDown(subscription.close);

      final notifier = container.read(appLockEnableSetupProvider.notifier);
      notifier.begin();
      notifier.continueToHintStep(
        pin: testAppLockPin,
        confirmPin: testAppLockPin,
      );

      await notifier.submitSetup(
        pin: testAppLockPin,
        confirmPin: testAppLockPin,
        hint: '   ',
      );

      final setup = container.read(appLockEnableSetupProvider);
      expect(setup.step, AppLockEnableSetupStep.hint);
      expect(setup.errorMessage, isNotNull);
      expect(await const AppLockModel().loadEnabled(), isFalse);
    });

    test('backToPinStep returns from hint to pin step', () async {
      final container = ProviderContainer(
        overrides: appLockEnableSetupTestOverrides(
          coordinator: _RecordingEnableSetupCoordinator(),
        ),
      );
      addTearDown(container.dispose);
      final subscription = keepAppLockEnableSetupAlive(container);
      addTearDown(subscription.close);

      final notifier = container.read(appLockEnableSetupProvider.notifier);
      notifier.begin();
      notifier.continueToHintStep(
        pin: testAppLockPin,
        confirmPin: testAppLockPin,
      );
      notifier.backToPinStep();

      final setup = container.read(appLockEnableSetupProvider);
      expect(setup.step, AppLockEnableSetupStep.pin);
      expect(setup.errorMessage, isNull);
    });

    test('cancel returns to idle', () async {
      final coordinator = _RecordingEnableSetupCoordinator();
      final container = ProviderContainer(
        overrides: appLockEnableSetupTestOverrides(coordinator: coordinator),
      );
      addTearDown(container.dispose);
      final subscription = keepAppLockEnableSetupAlive(container);
      addTearDown(subscription.close);

      final notifier = container.read(appLockEnableSetupProvider.notifier);
      notifier.begin();
      notifier.cancel();

      expect(container.read(appLockEnableSetupProvider).isVisible, isFalse);
      expect(coordinator.cancelledCount, 1);
    });
  });
}
