import 'package:app_l10n/app_l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/locale_repository_impl.dart';
import '../domain/app_locale_preference.dart';
import '../domain/locale_repository.dart';
import '../domain/locale_settings.dart';

final localeRepositoryProvider = Provider<LocaleRepository>(
  (_) => LocaleRepositoryImpl(),
);

class LocaleNotifier extends Notifier<LocaleSettings> {
  late final LocaleRepository _repository;

  @override
  LocaleSettings build() {
    _repository = ref.read(localeRepositoryProvider);
    final settings = _repository.load();
    _syncHolder(settings.preference);
    return settings;
  }

  Future<void> setPreference(AppLocalePreference preference) async {
    if (state.preference == preference) return;
    state = state.copyWith(preference: preference);
    await _repository.savePreference(preference);
    _syncHolder(preference);
  }

  void _syncHolder(AppLocalePreference preference) {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    AppL10nHolder.update(
      AppL10n.resolveActiveLocale(
        fixedLocale: preference.fixedLocale,
        deviceLocale: deviceLocale,
      ),
    );
  }
}

final localeSettingsProvider = NotifierProvider<LocaleNotifier, LocaleSettings>(
  LocaleNotifier.new,
);
