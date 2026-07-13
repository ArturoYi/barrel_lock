import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLockPinPolicy', () {
    test('accepts six digit pin', () {
      expect(AppLockPinPolicy.validatePin('123456'), isNull);
    });

    test('rejects non six digit pin', () {
      expect(AppLockPinPolicy.validatePin('12345'), isNotNull);
    });

    test('accepts matching six digit pin', () {
      expect(
        AppLockPinPolicy.validateSetup(pin: '123456', confirmPin: '123456'),
        isNull,
      );
    });

    test('rejects non six digit pin', () {
      expect(
        AppLockPinPolicy.validateSetup(pin: '12345', confirmPin: '12345'),
        isNotNull,
      );
    });

    test('rejects mismatched confirmation', () {
      expect(
        AppLockPinPolicy.validateSetup(pin: '123456', confirmPin: '654321'),
        '两次输入不一致',
      );
    });

    test('validateChange rejects same current and new pin', () {
      expect(
        AppLockPinPolicy.validateChange(
          currentPin: '123456',
          pin: '123456',
          confirmPin: '123456',
        ),
        '新密码不能与当前密码相同',
      );
    });

    test('validateCurrentPin rejects empty input', () {
      expect(AppLockPinPolicy.validateCurrentPin('  '), '请输入当前密码');
    });

    test('validateHint accepts non-empty trimmed hint', () {
      expect(AppLockPinPolicy.validateHint(' 我的宠物 '), isNull);
    });

    test('validateHint rejects empty hint', () {
      expect(AppLockPinPolicy.validateHint('   '), '请输入提示语');
    });

    test('validateHint rejects overly long hint', () {
      expect(
        AppLockPinPolicy.validateHint(
          'a' * (AppLockPinPolicy.hintMaxLength + 1),
        ),
        isNotNull,
      );
    });
  });
}
