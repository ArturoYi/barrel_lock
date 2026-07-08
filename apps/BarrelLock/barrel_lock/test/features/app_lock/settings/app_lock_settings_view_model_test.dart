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
            _QueueingUiDelegate([testAppLockPin]),
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
      expect(container.read(appLockSessionProvider).isLocked, isFalse);
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
  });
}
