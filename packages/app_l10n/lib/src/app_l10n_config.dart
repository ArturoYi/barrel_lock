import 'package:flutter/widgets.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import '../l10n/app_localizations.dart';
import 'app_l10n_holder.dart';

export 'app_l10n_holder.dart';

/// BarrelLock 本地化接线与 locale 解析。
final class AppL10n {
  AppL10n._();

  static AppLocalizations get current => AppL10nHolder.current;

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  static const List<Locale> supportedLocales =
      AppLocalizations.supportedLocales;

  /// 解析设备 locale 到支持列表；不支持时回退简体中文。
  static Locale resolveLocale(
    Locale? locale,
    Iterable<Locale> supportedLocales,
  ) {
    final resolved = locale == null
        ? null
        : _matchSupported(locale, supportedLocales);
    return resolved ?? const Locale('zh');
  }

  /// 将 [AppLocalePreference.fixedLocale] 或系统 locale 解析为支持列表中的 [Locale]。
  static Locale resolveActiveLocale({
    required Locale? fixedLocale,
    required Locale deviceLocale,
    Iterable<Locale>? supportedLocales,
  }) {
    final supported = supportedLocales ?? AppLocalizations.supportedLocales;
    if (fixedLocale != null) {
      return _matchSupported(fixedLocale, supported) ?? const Locale('zh');
    }
    return resolveLocale(deviceLocale, supported);
  }

  static Locale? _matchSupported(
    Locale locale,
    Iterable<Locale> supportedLocales,
  ) {
    for (final supported in supportedLocales) {
      if (_sameLocale(supported, locale)) {
        return supported;
      }
    }

    if (locale.languageCode == 'zh') {
      final isTraditional =
          locale.countryCode == 'TW' ||
          locale.scriptCode == 'Hant' ||
          locale.toLanguageTag().toLowerCase().contains('hant');
      for (final supported in supportedLocales) {
        if (supported.languageCode != 'zh') continue;
        final supportedTraditional =
            supported.countryCode == 'TW' || supported.scriptCode == 'Hant';
        if (isTraditional == supportedTraditional) {
          return supported;
        }
      }
      return isTraditional ? const Locale('zh', 'TW') : const Locale('zh');
    }

    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return supported;
      }
    }
    return null;
  }

  static bool _sameLocale(Locale a, Locale b) {
    if (a.languageCode != b.languageCode) return false;
    if (a.countryCode != null &&
        b.countryCode != null &&
        a.countryCode != b.countryCode) {
      return false;
    }
    if (a.scriptCode != null &&
        b.scriptCode != null &&
        a.scriptCode != b.scriptCode) {
      return false;
    }
    return true;
  }
}
