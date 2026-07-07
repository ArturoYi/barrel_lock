import 'app_color_scheme.dart';
import 'app_font_scale.dart';
import 'app_theme_mode.dart';

final class ThemeSettings {
  const ThemeSettings({
    required this.mode,
    required this.colorScheme,
    required this.fontScale,
  });

  final AppThemeMode mode;
  final AppColorScheme colorScheme;
  final AppFontScale fontScale;

  ThemeSettings copyWith({
    AppThemeMode? mode,
    AppColorScheme? colorScheme,
    AppFontScale? fontScale,
  }) {
    return ThemeSettings(
      mode: mode ?? this.mode,
      colorScheme: colorScheme ?? this.colorScheme,
      fontScale: fontScale ?? this.fontScale,
    );
  }
}
