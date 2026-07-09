import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_support.dart';

final class _RecordingAppLockCoordinator implements AppLockCoordinatorGateway {
  int openPinManageCount = 0;

  @override
  void pop() {}

  @override
  void openPinManage() => openPinManageCount++;
}

void main() {
  setUp(() async {
    await initAppLockTestEnvironment();
  });

  tearDown(resetAppLockTestEnvironment);

  group('AppLockSettingsViewModel', () {
    test('starts enable setup when enabling without pin', () async {
      final container = ProviderContainer(
        overrides: [
          appLockCoordinatorProvider.overrideWithValue(
            _RecordingAppLockCoordinator(),
          ),
          ...appLockEnableSetupTestOverrides(),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        appLockSettingsViewModelProvider.notifier,
      );
      await container.read(appLockSettingsViewModelProvider.future);

      await notifier.onEnabledChanged(true);

      final settings = container
          .read(appLockSettingsViewModelProvider)
          .requireValue;
      expect(settings.preferences.enabled, isFalse);
      expect(container.read(appLockEnableSetupProvider).isVisible, isTrue);
    });

    test('allows enabling lock when pin already exists', () async {
      await AppIdentityAuth.setAppPin(testAppLockPin);

      final container = ProviderContainer(
        overrides: [
          appLockCoordinatorProvider.overrideWithValue(
            _RecordingAppLockCoordinator(),
          ),
          identityAuthUiDelegateProvider.overrideWithValue(
            QueueingUiDelegate([testAppLockPin]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        appLockSettingsViewModelProvider.notifier,
      );
      await container.read(appLockSettingsViewModelProvider.future);
      container.read(appLockSessionProvider);

      await notifier.onEnabledChanged(true);

      final settings = container
          .read(appLockSettingsViewModelProvider)
          .requireValue;
      expect(settings.preferences.enabled, isTrue);
      expect(container.read(appLockEnableSetupProvider).isVisible, isFalse);
      expect(container.read(appLockSessionProvider).isLocked, isTrue);
    });

    test('onPop cancels enable setup flow', () async {
      final coordinator = _RecordingAppLockCoordinator();
      final container = ProviderContainer(
        overrides: [
          appLockCoordinatorProvider.overrideWithValue(coordinator),
          ...appLockEnableSetupTestOverrides(),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        appLockSettingsViewModelProvider.notifier,
      );
      await container.read(appLockSettingsViewModelProvider.future);

      container.read(appLockEnableSetupProvider.notifier).begin();
      expect(container.read(appLockEnableSetupProvider).isVisible, isTrue);

      notifier.onPop();

      expect(container.read(appLockEnableSetupProvider).isVisible, isFalse);
    });

    test('openPinManage navigates through coordinator', () async {
      final coordinator = _RecordingAppLockCoordinator();
      final container = ProviderContainer(
        overrides: [appLockCoordinatorProvider.overrideWithValue(coordinator)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(
        appLockSettingsViewModelProvider.notifier,
      );
      await container.read(appLockSettingsViewModelProvider.future);

      notifier.onOpenPinManage();

      expect(coordinator.openPinManageCount, 1);
    });

    test('derives hasFallbackPin from auth layer on load', () async {
      await AppIdentityAuth.setAppPin(testAppLockPin);
      await const AppLockModel().saveEnabled(false);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final settings = await container.read(
        appLockSettingsViewModelProvider.future,
      );

      expect(settings.preferences.enabled, isFalse);
      expect(settings.preferences.hasFallbackPin, isTrue);
    });
  });
}
