import 'package:flutter/painting.dart';

import 'app_font_family.dart';
import 'app_font_style.dart';
import 'app_font_weight.dart';

/// [AppFontFamily] 的排版构建扩展。
extension AppFontFamilyTextStyle on AppFontFamily {
  /// 基于字体族枚举组装 [TextStyle]，参数与 [TextStyle.new] 对齐。
  ///
  /// 新增字体时只需扩展 [AppFontFamily]；样式与字重通过
  /// [AppFontStyle]、[AppFontWeight] 选择，避免散落 magic string。
  TextStyle textStyle({
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
      familyName: familyName,
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

/// 共享 [TextStyle] 构建逻辑，供 [AppFontFamily.textStyle] 与 [AppFonts.textStyle] 使用。
TextStyle buildAppFontTextStyle({
  required String familyName,
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
  return TextStyle(
    inherit: inherit,
    color: color,
    backgroundColor: backgroundColor,
    fontSize: fontSize,
    fontWeight: weight.value,
    fontStyle: style.value,
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
    fontFamily: familyName,
    fontFamilyFallback: fontFamilyFallback,
    package: package,
    overflow: overflow,
  );
}
