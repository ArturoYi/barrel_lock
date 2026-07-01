import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/theme_repository_impl.dart';
import '../domain/app_color_scheme.dart';
import '../domain/app_theme_mode.dart';
import '../domain/theme_repository.dart';
import '../domain/theme_settings.dart';

final themeRepositoryProvider = Provider<ThemeRepository>(
  (_) => ThemeRepositoryImpl(),
);

class ThemeNotifier extends Notifier<ThemeSettings> {
  late final ThemeRepository _repository;

  @override
  ThemeSettings build() {
    _repository = ref.read(themeRepositoryProvider);
    return _repository.load();
  }

  Future<void> setMode(AppThemeMode mode) async {
    if (state.mode == mode) return;
    state = state.copyWith(mode: mode);
    await _repository.saveMode(mode);
  }

  Future<void> setColorScheme(AppColorScheme colorScheme) async {
    if (state.colorScheme == colorScheme) return;
    state = state.copyWith(colorScheme: colorScheme);
    await _repository.saveColorScheme(colorScheme);
  }
}

final themeSettingsProvider = NotifierProvider<ThemeNotifier, ThemeSettings>(
  ThemeNotifier.new,
);
