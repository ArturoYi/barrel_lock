import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_support.dart';

final class _RecordingEnableSetupCoordinator
    implements AppLockEnableSetupCoordinatorGateway {
  int completedCount = 0;
  int cancelledCount = 0;

  @override
  void onEnableSetupCompleted() => completedCount++;

  @override
  void onEnableSetupCancelled() => cancelledCount++;
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

  group('AppLockEnableSetupViewModel', () {
    test('begin shows setup panel without enabling lock', () async {
      final container = ProviderContainer(
        overrides: [
          appLockEnableSetupCoordinatorProvider.overrideWithValue(
            _RecordingEnableSetupCoordinator(),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(appLockEnableSetupProvider.notifier).begin();

      final setup = container.read(appLockEnableSetupProvider);
      expect(setup.isVisible, isTrue);
      expect(setup.phase, AppLockEnableSetupPhase.active);

      const model = AppLockModel();
      final preferences = await model.load();
      expect(preferences.enabled, isFalse);
    });

    test('submitPin enables lock after saving six digit pin', () async {
      final coordinator = _RecordingEnableSetupCoordinator();
      final container = ProviderContainer(
        overrides: [
          appLockEnableSetupCoordinatorProvider.overrideWithValue(coordinator),
          identityAuthUiDelegateProvider.overrideWithValue(
            _QueueingUiDelegate([testAppLockPin]),
          ),
        ],
      );
      addTearDown(container.dispose);

      // 设置页已挂载时 submitPin 会 invalidate 设置 VM，须能安全重建。
      await container.read(appLockSettingsViewModelProvider.future);
      container.read(appLockSessionProvider);
      final notifier = container.read(appLockEnableSetupProvider.notifier);
      notifier.begin();

      await notifier.submitPin(pin: testAppLockPin, confirmPin: testAppLockPin);

      expect(container.read(appLockEnableSetupProvider).isVisible, isFalse);
      expect(coordinator.completedCount, 1);

      const model = AppLockModel();
      final preferences = await model.load();
      expect(preferences.enabled, isTrue);
      expect(preferences.hasFallbackPin, isTrue);
      expect(await AppIdentityAuth.hasAppPin(), isTrue);
    });

    test('submitPin rejects invalid confirmation', () async {
      final container = ProviderContainer(
        overrides: [
          appLockEnableSetupCoordinatorProvider.overrideWithValue(
            _RecordingEnableSetupCoordinator(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(appLockEnableSetupProvider.notifier);
      notifier.begin();
      await notifier.submitPin(pin: testAppLockPin, confirmPin: '654321');

      final setup = container.read(appLockEnableSetupProvider);
      expect(setup.phase, AppLockEnableSetupPhase.active);
      expect(setup.errorMessage, isNotNull);
    });

    test('cancel returns to idle', () async {
      final coordinator = _RecordingEnableSetupCoordinator();
      final container = ProviderContainer(
        overrides: [
          appLockEnableSetupCoordinatorProvider.overrideWithValue(coordinator),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(appLockEnableSetupProvider.notifier);
      notifier.begin();
      notifier.cancel();

      expect(container.read(appLockEnableSetupProvider).isVisible, isFalse);
      expect(coordinator.cancelledCount, 1);
    });
  });
}
