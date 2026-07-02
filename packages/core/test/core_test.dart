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

    test('standard applies NotoSansSC to all M3 tokens', () {
      final typography = AppTypography.standard(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );

      for (final style in [
        typography.displayLarge,
        typography.displayMedium,
        typography.displaySmall,
        typography.headlineLarge,
        typography.headlineMedium,
        typography.headlineSmall,
        typography.titleLarge,
        typography.titleMedium,
        typography.titleSmall,
        typography.bodyLarge,
        typography.bodyMedium,
        typography.bodySmall,
        typography.labelLarge,
        typography.labelMedium,
        typography.labelSmall,
      ]) {
        expect(style.fontFamily, AppFonts.notoSansSC);
      }
    });
  });

  group('AppTheme', () {
    testWidgets('wires NotoSansSC on textTheme and AppTypography extension', (
      tester,
    ) async {
      late ThemeData theme;
      late AppTypography typography;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(AppColorScheme.deepPurple),
          home: Builder(
            builder: (context) {
              theme = Theme.of(context);
              typography = context.typography;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(theme.textTheme.bodyMedium?.fontFamily, AppFonts.notoSansSC);
      expect(typography.bodyMedium.fontFamily, AppFonts.notoSansSC);
    });
  });

  group('core public API', () {
    test('appName exposes the correct constant', () {
      expect(appName, 'Flutter Bazaar');
    });

    test('greeting joins appName into the welcome message', () {
      expect(greeting(), 'Hi! Welcome to Flutter Bazaar');
      expect(greeting(), contains(appName));
    });
  });
}
