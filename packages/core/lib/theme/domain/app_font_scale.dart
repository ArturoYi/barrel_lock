/// 应用级字体缩放档位（相对 M3 标准几何的倍率）。
enum AppFontScale {
  small,
  standard,
  large,
  extraLarge;

  static const AppFontScale defaultScale = AppFontScale.standard;

  /// 相对标准字号的线性倍率，供 [TextScaler.linear] 使用。
  double get scaleFactor => switch (this) {
    AppFontScale.small => 0.85,
    AppFontScale.standard => 1.0,
    AppFontScale.large => 1.15,
    AppFontScale.extraLarge => 1.3,
  };

  String get storageValue => name;

  static AppFontScale fromStorage(String? raw) {
    if (raw == null || raw.isEmpty) {
      return defaultScale;
    }
    for (final scale in AppFontScale.values) {
      if (scale.name == raw) {
        return scale;
      }
    }
    return defaultScale;
  }
}
