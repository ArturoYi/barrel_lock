import 'dart:async';

import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_support.dart';

void main() {
  setUp(() async {
    await initAppLockTestEnvironment();
  });

  tearDown(resetAppLockTestEnvironment);

  group('AppLockSessionViewModel', () {
    test('locks on cold start when enabled and unlocks with pin', () async {
      await seedEnabledAppLock();

      final container = ProviderContainer(
        overrides: [
          identityAuthUiDelegateProvider.overrideWithValue(
            QueueingUiDelegate([testAppLockPin]),
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

    test('shows background shield on pause and locks on resume', () async {
      await seedEnabledAppLock();

      final container = ProviderContainer(
        overrides: [
          identityAuthUiDelegateProvider.overrideWithValue(
            QueueingUiDelegate([testAppLockPin, testAppLockPin]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(appLockSessionProvider.notifier);
      container.read(appLockSessionProvider);
      await waitForColdStartAuth(container);

      notifier.showBackgroundShield();
      notifier.markPendingUnlockOnPause();
      expect(
        container.read(appLockSessionProvider).showBackgroundShield,
        isTrue,
      );

      notifier.hideBackgroundShield();
      await notifier.onAppResumed();
      await notifier.startAuthentication();

      final session = container.read(appLockSessionProvider);
      expect(session.isLocked, isFalse);
      expect(session.showBackgroundShield, isFalse);
    });

    test('retries pin prompt after wrong pin submission', () async {
      await seedEnabledAppLock();

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sessionNotifier = container.read(appLockSessionProvider.notifier);
      container.read(appLockSessionProvider);

      await pollUntil(
        condition: () {
          final session = container.read(appLockSessionProvider);
          return session.isLocked && session.isAuthenticating;
        },
      );

      final authFuture = sessionNotifier.startAuthentication();

      await waitForPinPrompt(container);
      final firstAttempt = container.read(appLockPinPromptProvider)!.attempt;

      container
          .read(appLockPinPromptProvider.notifier)
          .submitPin(testAppLockWrongPin);

      await pollUntil(
        condition: () {
          final prompt = container.read(appLockPinPromptProvider);
          return prompt != null && prompt.attempt > firstAttempt;
        },
      );

      final retryPrompt = container.read(appLockPinPromptProvider)!;
      expect(retryPrompt.errorMessage, '密码错误，请重试');
      expect(retryPrompt.headerMessage, '密码错误，请重试');

      container
          .read(appLockPinPromptProvider.notifier)
          .submitPin(testAppLockPin);

      await pollUntil(
        condition: () {
          return !container.read(appLockSessionProvider).isAuthenticating;
        },
      );

      expect(container.read(appLockSessionProvider).isLocked, isFalse);
      await authFuture;
    });

    test('keeps session locked when user cancels pin input', () async {
      await seedEnabledAppLock();

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final sessionNotifier = container.read(appLockSessionProvider.notifier);
      container.read(appLockSessionProvider);

      await pollUntil(
        condition: () {
          final session = container.read(appLockSessionProvider);
          return session.isLocked && session.isAuthenticating;
        },
      );

      unawaited(sessionNotifier.startAuthentication());
      await waitForPinPrompt(container);

      container.read(appLockPinPromptProvider.notifier).cancel();

      await Future<void>.delayed(const Duration(milliseconds: 200));

      expect(container.read(appLockSessionProvider).isLocked, isTrue);
      expect(container.read(appLockPinPromptProvider), isNotNull);

      container
          .read(appLockPinPromptProvider.notifier)
          .submitPin(testAppLockPin);

      await pollUntil(
        condition: () {
          return !container.read(appLockSessionProvider).isAuthenticating;
        },
      );
    });

    test(
      'retries authentication after pin cancellation via delegate',
      () async {
        await seedEnabledAppLock();

        final delegate = QueueingUiDelegate([null, testAppLockPin]);
        final container = ProviderContainer(
          overrides: [
            identityAuthUiDelegateProvider.overrideWithValue(delegate),
          ],
        );
        addTearDown(container.dispose);

        container.read(appLockSessionProvider);
        await waitForColdStartAuth(container);

        final session = container.read(appLockSessionProvider);
        expect(session.isLocked, isFalse);
        expect(delegate.callCount, 2);
      },
    );

    test('enters authentication when unlock is unavailable', () async {
      await const AppLockModel().saveEnabled(true);

      final delegate = QueueingUiDelegate([]);
      final container = ProviderContainer(
        overrides: [identityAuthUiDelegateProvider.overrideWithValue(delegate)],
      );
      addTearDown(container.dispose);

      container.read(appLockSessionProvider);

      await pollUntil(
        condition: () {
          return container.read(appLockSessionProvider).isAuthenticating;
        },
      );

      final session = container.read(appLockSessionProvider);
      expect(session.isLocked, isTrue);
      expect(delegate.callCount, 0);
    });

    test('locks after enabling without app restart', () async {
      await AppIdentityAuth.setAppPin(testAppLockPin);
      await const AppLockModel().saveEnabled(false);

      final delegate = QueueingUiDelegate([testAppLockPin]);
      final container = ProviderContainer(
        overrides: [identityAuthUiDelegateProvider.overrideWithValue(delegate)],
      );
      addTearDown(container.dispose);

      container.read(appLockSessionProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      await const AppLockModel().saveEnabled(true);
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
      await seedEnabledAppLock();

      final delegate = QueueingUiDelegate([testAppLockPin, testAppLockPin]);
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
