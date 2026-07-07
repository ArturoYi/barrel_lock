import 'package:app_fonts/app_fonts.dart';
import 'package:flutter/material.dart';

import '../domain/app_color_scheme.dart';
import 'app_color_scheme_x.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData light(AppColorScheme scheme) =>
      _build(scheme: scheme, brightness: Brightness.light);

  static ThemeData dark(AppColorScheme scheme) =>
      _build(scheme: scheme, brightness: Brightness.dark);

  static ThemeData _build({
    required AppColorScheme scheme,
    required Brightness brightness,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: scheme.seedColor,
      brightness: brightness,
    );
    final typography = AppTypography.standard(colorScheme: colorScheme);

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: AppFonts.notoSansSC,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      // textTheme 仅含 M3 几何；文字色由 colorScheme 与组件主题 / DefaultTextStyle 注入。
      textTheme: typography.toTextTheme(),
      extensions: [typography],
    );
  }
}
