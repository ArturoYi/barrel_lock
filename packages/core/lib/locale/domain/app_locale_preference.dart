import 'package:flutter/material.dart';

/// 用户语言偏好：跟随系统或固定 locale。
enum AppLocalePreference {
  system,
  zhHans,
  zhHant,
  en,
  ar;

  String get storageValue => switch (this) {
    AppLocalePreference.system => 'system',
    AppLocalePreference.zhHans => 'zh_hans',
    AppLocalePreference.zhHant => 'zh_hant',
    AppLocalePreference.en => 'en',
    AppLocalePreference.ar => 'ar',
  };

  static AppLocalePreference fromStorage(String raw) => switch (raw) {
    'zh_hans' || 'zh' => AppLocalePreference.zhHans,
    'zh_hant' => AppLocalePreference.zhHant,
    'en' => AppLocalePreference.en,
    'ar' => AppLocalePreference.ar,
    _ => AppLocalePreference.system,
  };

  /// 固定语言时返回对应 [Locale]；跟随系统时返回 `null`。
  Locale? get fixedLocale => switch (this) {
    AppLocalePreference.system => null,
    AppLocalePreference.zhHans => const Locale('zh'),
    AppLocalePreference.zhHant => const Locale('zh', 'TW'),
    AppLocalePreference.en => const Locale('en'),
    AppLocalePreference.ar => const Locale('ar'),
  };

  /// 设置页摘要（语言自称；跟随系统走 l10n key）。
  String get displayName => switch (this) {
    AppLocalePreference.system => '',
    AppLocalePreference.zhHans => '简体中文',
    AppLocalePreference.zhHant => '繁體中文',
    AppLocalePreference.en => 'English',
    AppLocalePreference.ar => 'العربية',
  };
}
