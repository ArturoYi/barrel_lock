import 'package:flutter/painting.dart';

import 'app_font_family.dart';
import 'app_font_style.dart';
import 'app_font_text_style.dart';
import 'app_font_weight.dart';

/// 全局字体入口：族名常量与 [TextStyle] 工厂。
abstract final class AppFonts {
  /// Noto Sans SC 族名；须与 [AppFontFamily.notoSansSC] 保持一致。
  static const String notoSansSC = 'NotoSansSC';

  /// 通过枚举组装 [TextStyle]；等价于 [AppFontFamily.textStyle]。
  static TextStyle textStyle({
    AppFontFamily family = AppFontFamily.notoSansSC,
    AppFontWeight weight = AppFontWeight.regular,
    AppFontStyle style = AppFontStyle.normal,
    bool inherit = true,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    double? letterSpacing,
    double? wordSpacing,
    TextBaseline? textBaseline,
    double? height,
    TextLeadingDistribution? leadingDistribution,
    Locale? locale,
    Paint? foreground,
    Paint? background,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    List<FontVariation>? fontVariations,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? debugLabel,
    List<String>? fontFamilyFallback,
    String? package,
    TextOverflow? overflow,
  }) {
    return buildAppFontTextStyle(
      familyName: family.familyName,
      weight: weight,
      style: style,
      inherit: inherit,
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      leadingDistribution: leadingDistribution,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      fontVariations: fontVariations,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      debugLabel: debugLabel,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      overflow: overflow,
    );
  }
}
