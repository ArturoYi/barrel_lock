import 'package:flutter/painting.dart';

/// 字重语义，映射至 Flutter [FontWeight]。
enum AppFontWeight {
  thin(FontWeight.w100),
  extraLight(FontWeight.w200),
  light(FontWeight.w300),
  regular(FontWeight.w400),
  medium(FontWeight.w500),
  semiBold(FontWeight.w600),
  bold(FontWeight.w700),
  extraBold(FontWeight.w800),
  black(FontWeight.w900);

  const AppFontWeight(this.value);

  final FontWeight value;
}
