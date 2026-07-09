import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'features/app_lock/test_support.dart';

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

/// 等待冷启动锁屏请求并完成验证（单测无 Overlay 层，需手动调用 [startAuthentication]）。
Future<void> waitForColdStartAuth(ProviderContainer container) async {
  const timeout = Duration(seconds: 2);
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    final session = container.read(appLockSessionProvider);
    if (session.isLocked && session.isAuthenticating) {
      break;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  await container.read(appLockSessionProvider.notifier).startAuthentication();

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
    await initAppLockTestEnvironment();
  });

  tearDown(resetAppLockTestEnvironment);

  group('AppLockSessionViewModel', () {
    test('locks on cold start when enabled and unlocks with pin', () async {
      const model = AppLockModel();
      await AppIdentityAuth.setAppPin(testAppLockPin);
      await model.save(
        const AppLockPreferences(enabled: true, hasFallbackPin: true),
      );

      final container = ProviderContainer(
        overrides: [
          identityAuthUiDelegateProvider.overrideWithValue(
            _QueueingUiDelegate([testAppLockPin]),
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
      await AppIdentityAuth.setAppPin(testAppLockPin);
      await model.save(
        const AppLockPreferences(enabled: true, hasFallbackPin: true),
      );

      final delegate = _QueueingUiDelegate([null, testAppLockPin]);
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
        const AppLockPreferences(enabled: true, hasFallbackPin: false),
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

    test('locks after enabling without app restart', () async {
      const model = AppLockModel();
      await AppIdentityAuth.setAppPin(testAppLockPin);
      await model.save(
        const AppLockPreferences(enabled: false, hasFallbackPin: true),
      );

      final delegate = _QueueingUiDelegate([testAppLockPin]);
      final container = ProviderContainer(
        overrides: [identityAuthUiDelegateProvider.overrideWithValue(delegate)],
      );
      addTearDown(container.dispose);

      container.read(appLockSessionProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await model.save(
        const AppLockPreferences(enabled: true, hasFallbackPin: true),
      );

      await container.read(appLockSessionProvider.notifier).lockAfterEnabled();
      await container
          .read(appLockSessionProvider.notifier)
          .startAuthentication();

      final session = container.read(appLockSessionProvider);
      expect(session.isLocked, isFalse);
      expect(session.isAuthenticating, isFalse);
      expect(delegate.callCount, 1);
    });

    test('locks again after returning from background', () async {
      const model = AppLockModel();
      await AppIdentityAuth.setAppPin(testAppLockPin);
      await model.save(
        const AppLockPreferences(enabled: true, hasFallbackPin: true),
      );

      final delegate = _QueueingUiDelegate([testAppLockPin, testAppLockPin]);
      final container = ProviderContainer(
        overrides: [identityAuthUiDelegateProvider.overrideWithValue(delegate)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(appLockSessionProvider.notifier);
      container.read(appLockSessionProvider);
      await waitForColdStartAuth(container);

      await notifier.onAppPaused();
      await notifier.onAppResumed();
      await notifier.startAuthentication();

      final session = container.read(appLockSessionProvider);
      expect(session.isLocked, isFalse);
      expect(delegate.callCount, 2);
    });
  });
}
