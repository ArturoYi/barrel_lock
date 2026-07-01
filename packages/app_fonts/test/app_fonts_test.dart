import 'package:app_fonts/app_fonts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AppFonts exposes NotoSansSC family name', () {
    expect(AppFonts.notoSansSC, 'NotoSansSC');
  });
}
