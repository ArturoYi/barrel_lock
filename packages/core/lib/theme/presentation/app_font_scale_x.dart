import '../domain/app_font_scale.dart';

extension AppFontScaleX on AppFontScale {
  String get displayName => switch (this) {
    AppFontScale.small => '小',
    AppFontScale.standard => '标准',
    AppFontScale.large => '大',
    AppFontScale.extraLarge => '特大',
  };
}
