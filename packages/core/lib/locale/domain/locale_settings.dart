import 'app_locale_preference.dart';

final class LocaleSettings {
  const LocaleSettings({required this.preference});

  final AppLocalePreference preference;

  LocaleSettings copyWith({AppLocalePreference? preference}) {
    return LocaleSettings(preference: preference ?? this.preference);
  }
}
