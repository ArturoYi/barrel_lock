import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('core public API', () {
    test('appName exposes the correct constant', () {
      expect(appName, 'Flutter Bazaar');
    });

    test('greeting joins appName into the welcome message', () {
      expect(greeting(), 'Welcome to Flutter Bazaar');
      expect(greeting(), contains(appName));
    });
  });
}