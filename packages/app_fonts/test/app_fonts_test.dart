import 'package:app_fonts/app_fonts.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFontFamily', () {
    test('notoSansSC matches pubspec family name', () {
      expect(AppFontFamily.notoSansSC.familyName, 'NotoSansSC');
      expect(AppFonts.notoSansSC, AppFontFamily.notoSansSC.familyName);
    });
  });

  group('AppFontStyle', () {
    test('maps to Flutter FontStyle', () {
      expect(AppFontStyle.normal.value, FontStyle.normal);
      expect(AppFontStyle.italic.value, FontStyle.italic);
    });
  });

  group('AppFontWeight', () {
    test('maps to Flutter FontWeight', () {
      expect(AppFontWeight.regular.value, FontWeight.w400);
      expect(AppFontWeight.bold.value, FontWeight.w700);
    });
  });

  group('textStyle', () {
    test('extension builds TextStyle from enums', () {
      final style = AppFontFamily.notoSansSC.textStyle(
        weight: AppFontWeight.medium,
        style: AppFontStyle.normal,
        fontSize: 16,
      );

      expect(style.fontFamily, 'NotoSansSC');
      expect(style.fontWeight, FontWeight.w500);
      expect(style.fontStyle, FontStyle.normal);
      expect(style.fontSize, 16);
    });

    test('AppFonts.textStyle delegates to family extension', () {
      final style = AppFonts.textStyle(
        family: AppFontFamily.notoSansSC,
        weight: AppFontWeight.regular,
        style: AppFontStyle.normal,
      );

      expect(style.fontFamily, AppFonts.notoSansSC);
      expect(style.fontWeight, FontWeight.w400);
      expect(style.fontStyle, FontStyle.normal);
    });

    test('forwards remaining TextStyle parameters', () {
      final style = AppFontFamily.notoSansSC.textStyle(
        wordSpacing: 2,
        textBaseline: TextBaseline.ideographic,
        leadingDistribution: TextLeadingDistribution.even,
        decoration: TextDecoration.underline,
        package: 'app_fonts',
      );

      expect(style.wordSpacing, 2);
      expect(style.textBaseline, TextBaseline.ideographic);
      expect(style.leadingDistribution, TextLeadingDistribution.even);
      expect(style.decoration, TextDecoration.underline);
      expect(style.fontFamily, 'packages/app_fonts/NotoSansSC');
    });
  });
}
