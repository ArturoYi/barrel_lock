/// SP 基础设施层存储 Key 常量
final class PreferenceKeys {
  PreferenceKeys._();

  static const String themeMode = 'theme_mode';
  static const String colorScheme = 'color_scheme';
  static const String fontScale = 'font_scale';
  static const String localePreference = 'locale_preference';

  /// 应用内身份验证 PIN 哈希（[AppIdentityAuth]）。
  static const String identityAuthPin = 'identity_auth_pin';

  /// 基础设施层受管 key 白名单
  static const List<String> allKeys = [
    themeMode,
    colorScheme,
    fontScale,
    localePreference,
    identityAuthPin,
  ];
}
