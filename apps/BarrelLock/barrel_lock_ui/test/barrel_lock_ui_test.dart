import 'package:barrel_lock_ui/barrel_lock_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exports app shell entrypoints', () {
    expect(runBarrelLockApp, isNotNull);
    expect(BarrelLockApp.new, isNotNull);
  });
}
