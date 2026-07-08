import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLockPinPolicy', () {
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
  });
}
