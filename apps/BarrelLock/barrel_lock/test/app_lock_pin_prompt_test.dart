import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLockPinPromptViewModel', () {
    test('requestPin completes with submitted pin', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appLockPinPromptProvider.notifier);
      final future = notifier.requestPin(IdentityAuthReason.unlockOnResume);

      expect(container.read(appLockPinPromptProvider), isNotNull);
      notifier.submitPin('1234');

      expect(await future, '1234');
      expect(container.read(appLockPinPromptProvider)?.isSubmitting, isTrue);

      notifier.dismiss();
      expect(container.read(appLockPinPromptProvider), isNull);
    });

    test('requestPin completes with null on cancel', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appLockPinPromptProvider.notifier);
      final future = notifier.requestPin(IdentityAuthReason.unlockOnResume);

      notifier.cancel();

      expect(await future, isNull);
      expect(container.read(appLockPinPromptProvider), isNull);
    });

    test('submitPin rejects empty input without completing', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appLockPinPromptProvider.notifier);
      final future = notifier.requestPin(IdentityAuthReason.unlockOnResume);

      notifier.submitPin('   ');

      expect(container.read(appLockPinPromptProvider)?.errorMessage, '请输入密码');
      expect(container.read(appLockPinPromptProvider)?.isSubmitting, isFalse);

      notifier.submitPin('5678');
      expect(await future, '5678');
    });

    test('new requestPin cancels previous pending request', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(appLockPinPromptProvider.notifier);
      final first = notifier.requestPin(IdentityAuthReason.unlockOnResume);
      final second = notifier.requestPin(IdentityAuthReason.unlockOnResume);

      notifier.submitPin('9999');

      expect(await first, isNull);
      expect(await second, '9999');
    });
  });
}
