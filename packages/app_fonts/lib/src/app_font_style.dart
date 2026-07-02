import 'package:flutter/painting.dart';

/// 字体样式语义，映射至 Flutter [FontStyle]。
enum AppFontStyle {
  normal(FontStyle.normal),
  italic(FontStyle.italic);

  const AppFontStyle(this.value);

  final FontStyle value;
}
