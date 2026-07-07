import '../../preference/app_preference.dart';
import '../domain/app_color_scheme.dart';
import '../domain/app_font_scale.dart';
import '../domain/app_theme_mode.dart';
import '../domain/theme_repository.dart';
import '../domain/theme_settings.dart';

final class ThemeRepositoryImpl implements ThemeRepository {
  @override
  ThemeSettings load() {
    return ThemeSettings(
      mode: AppThemeMode.fromStorage(AppPreference.getThemeMode()),
      colorScheme: AppColorScheme.fromStorage(AppPreference.getColorScheme()),
      fontScale: AppFontScale.fromStorage(AppPreference.getFontScale()),
    );
  }

  @override
  Future<void> saveMode(AppThemeMode mode) =>
      AppPreference.setThemeMode(mode.storageValue);

  @override
  Future<void> saveColorScheme(AppColorScheme colorScheme) =>
      AppPreference.setColorScheme(colorScheme.storageValue);

  @override
  Future<void> saveFontScale(AppFontScale fontScale) =>
      AppPreference.setFontScale(fontScale.storageValue);
}
