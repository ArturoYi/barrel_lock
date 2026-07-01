import 'package:app_fonts/app_fonts.dart';
import 'package:flutter/material.dart';

import '../domain/app_color_scheme.dart';
import 'app_color_scheme_x.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static ThemeData light(AppColorScheme scheme) => _build(
    scheme: scheme,
    brightness: Brightness.light,
  );

  static ThemeData dark(AppColorScheme scheme) => _build(
    scheme: scheme,
    brightness: Brightness.dark,
  );

  static ThemeData _build({
    required AppColorScheme scheme,
    required Brightness brightness,
  }) {
    // 先构建 ColorScheme，再传入 AppTypography —— 颜色语义由 M3 规范驱动，
    // 避免在排版 factory 中硬编码 Colors.black87 / Colors.white。
    final colorScheme = ColorScheme.fromSeed(
      seedColor: scheme.seedColor,
      brightness: brightness,
    );
    final typography = AppTypography.standard(colorScheme: colorScheme);

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      fontFamily: AppFonts.notoSansSC,
      // textTheme 已由 material2021 + dense merge 注入 onSurface 颜色，无需二次 apply。
      textTheme: typography.toTextTheme(),
      extensions: [typography],
    );
  }
}
