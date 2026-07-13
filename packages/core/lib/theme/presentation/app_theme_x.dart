import 'package:flutter/material.dart';

import 'app_typography.dart';

/// [BuildContext] 上的主题快捷访问，避免重复 [Theme.of]。
extension AppThemeX on BuildContext {
  /// 完整 [ThemeData]；需要 brightness、platform 等时使用。
  ThemeData get theme => Theme.of(this);

  /// M3 颜色角色，替代 `Theme.of(context).colorScheme`。
  ColorScheme get colors => theme.colorScheme;

  /// Material 组件通道（Button、AppBar 等走 [DefaultTextStyle]）。
  TextTheme get textTheme => theme.textTheme;

  /// 业务语义排版（与 [AppTypography.toTextTheme] 同源）。
  AppTypography get typography {
    final extension = theme.extension<AppTypography>();
    assert(
      extension != null,
      'AppTypography is missing from ThemeData.extensions. '
      'Ensure AppTheme wires AppTypography.standard().',
    );
    return extension!;
  }
}
