import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTypography', () {
    test('tokens carry geometry without baked color', () {
      final scheme = ColorScheme.fromSeed(seedColor: Colors.blue);
      final typography = AppTypography.standard(colorScheme: scheme);

      expect(typography.bodyLarge.color, isNull);
      expect(typography.bodyLarge.fontSize, isNotNull);
      expect(typography.titleLarge.fontWeight, isNotNull);
    });
  });

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
