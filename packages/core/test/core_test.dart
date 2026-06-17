import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('greeting includes app name', () {
    expect(greeting(), 'Welcome to Flutter Bazaar');
    expect(appName, 'Flutter Bazaar');
  });
}
