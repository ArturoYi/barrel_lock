import 'package:flutter/material.dart';

import 'app_typography.dart';

extension AppTypographyX on BuildContext {
  AppTypography get typography {
    final extension = Theme.of(this).extension<AppTypography>();
    assert(
      extension != null,
      'AppTypography is missing from ThemeData.extensions. '
      'Ensure AppTheme wires AppTypography.standard().',
    );
    return extension!;
  }
}
