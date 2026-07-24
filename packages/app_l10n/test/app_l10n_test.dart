import 'package:app_l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppL10n', () {
    test('supportedLocales includes four languages', () {
      expect(
        AppL10n.supportedLocales,
        containsAll([
          const Locale('zh'),
          const Locale('zh', 'TW'),
          const Locale('en'),
          const Locale('ar'),
        ]),
      );
    });

    test('resolveLocale maps zh_TW to traditional Chinese', () {
      expect(
        AppL10n.resolveLocale(
          const Locale('zh', 'TW'),
          AppL10n.supportedLocales,
        ),
        const Locale('zh', 'TW'),
      );
    });

    test('resolveLocale falls back to zh for unsupported locale', () {
      expect(
        AppL10n.resolveLocale(const Locale('fr'), AppL10n.supportedLocales),
        const Locale('zh'),
      );
    });

    test('lookupAppLocalizations returns English strings', () {
      final l10n = lookupAppLocalizations(const Locale('en'));
      expect(l10n.common_cancel, 'Cancel');
    });

    test('lookupAppLocalizations returns Arabic strings', () {
      final l10n = lookupAppLocalizations(const Locale('ar'));
      expect(l10n.common_cancel, 'إلغاء');
    });
  });

  testWidgets('Arabic locale uses RTL directionality in MaterialApp', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        localeResolutionCallback: AppL10n.resolveLocale,
        builder: (context, child) {
          final locale = Localizations.localeOf(context);
          return Directionality(
            textDirection: locale.languageCode == 'ar'
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: Builder(
          builder: (context) => Text(
            context.l10n.common_cancel,
            textDirection: Directionality.of(context),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('إلغاء'), findsOneWidget);
    final direction = tester.widget<Text>(find.text('إلغاء')).textDirection;
    expect(direction, TextDirection.rtl);
  });

  testWidgets('context.l10n renders localized cancel label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        localeResolutionCallback: AppL10n.resolveLocale,
        home: Builder(builder: (context) => Text(context.l10n.common_cancel)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cancel'), findsOneWidget);
  });
}
