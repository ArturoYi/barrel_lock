import 'app_color_scheme.dart';
import 'app_font_scale.dart';
import 'app_theme_mode.dart';
import 'theme_settings.dart';

abstract interface class ThemeRepository {
  ThemeSettings load();

  Future<void> saveMode(AppThemeMode mode);

  Future<void> saveColorScheme(AppColorScheme colorScheme);

  Future<void> saveFontScale(AppFontScale fontScale);
}
