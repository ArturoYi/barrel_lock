import '../../preference/app_preference.dart';
import '../domain/app_locale_preference.dart';
import '../domain/locale_repository.dart';
import '../domain/locale_settings.dart';

final class LocaleRepositoryImpl implements LocaleRepository {
  @override
  LocaleSettings load() {
    return LocaleSettings(
      preference: AppLocalePreference.fromStorage(
        AppPreference.getLocalePreference(),
      ),
    );
  }

  @override
  Future<void> savePreference(AppLocalePreference preference) =>
      AppPreference.setLocalePreference(preference.storageValue);
}
