/// SP 基础设施层存储 Key 常量
final class PreferenceKeys {
  PreferenceKeys._();

  static const String themeMode = 'theme_mode';
  static const String colorScheme = 'color_scheme';
  static const String fontScale = 'font_scale';

  /// 基础设施层受管 key 白名单
  static const List<String> allKeys = [themeMode, colorScheme, fontScale];
}
