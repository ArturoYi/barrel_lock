import 'app_color_scheme.dart';
import 'app_theme_mode.dart';

final class ThemeSettings {
  const ThemeSettings({required this.mode, required this.colorScheme});

  final AppThemeMode mode;
  final AppColorScheme colorScheme;

  ThemeSettings copyWith({AppThemeMode? mode, AppColorScheme? colorScheme}) {
    return ThemeSettings(
      mode: mode ?? this.mode,
      colorScheme: colorScheme ?? this.colorScheme,
    );
  }
}
