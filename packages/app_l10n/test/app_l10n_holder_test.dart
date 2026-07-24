import 'package:app_l10n/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppL10nHolder', () {
    tearDown(() {
      AppL10nHolder.update(const Locale('zh'));
    });

    test('update switches current strings', () {
      AppL10nHolder.update(const Locale('en'));
      expect(AppL10n.current.common_cancel, 'Cancel');

      AppL10nHolder.update(const Locale('zh', 'TW'));
      expect(AppL10n.current.common_cancel, '取消');

      AppL10nHolder.update(const Locale('ar'));
      expect(AppL10n.current.common_cancel, 'إلغاء');
    });
  });
}
