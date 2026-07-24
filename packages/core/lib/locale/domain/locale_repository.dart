import 'app_locale_preference.dart';
import 'locale_settings.dart';

abstract interface class LocaleRepository {
  LocaleSettings load();

  Future<void> savePreference(AppLocalePreference preference);
}
