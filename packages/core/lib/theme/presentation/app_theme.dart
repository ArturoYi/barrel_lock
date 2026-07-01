import 'package:flutter/material.dart';

import '../domain/app_color_scheme.dart';
import 'app_color_scheme_x.dart';

abstract final class AppTheme {
  static ThemeData light(AppColorScheme scheme) => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: scheme.seedColor),
    useMaterial3: true,
  );

  static ThemeData dark(AppColorScheme scheme) => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: scheme.seedColor,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
  );
}
