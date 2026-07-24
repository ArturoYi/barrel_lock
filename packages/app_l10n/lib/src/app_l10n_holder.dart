import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

/// 无 [BuildContext] 的全局 [AppLocalizations] 访问（与 [LocaleNotifier] 同步）。
final class AppL10nHolder {
  AppL10nHolder._();

  static Locale _locale = const Locale('zh');
  static AppLocalizations _current = lookupAppLocalizations(_locale);

  static Locale get locale => _locale;

  static AppLocalizations get current => _current;

  static void update(Locale locale) {
    if (_sameLocale(_locale, locale)) return;
    _locale = locale;
    _current = lookupAppLocalizations(locale);
  }

  static bool _sameLocale(Locale a, Locale b) {
    return a.languageCode == b.languageCode &&
        a.countryCode == b.countryCode &&
        a.scriptCode == b.scriptCode;
  }
}
