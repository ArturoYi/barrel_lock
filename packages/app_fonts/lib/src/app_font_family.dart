/// 应用注册的字体族，与 [pubspec.yaml] 中 `family` 字段一一对应。
enum AppFontFamily {
  notoSansSC('NotoSansSC');

  const AppFontFamily(this.familyName);

  final String familyName;
}
