import 'package:core/core.dart';
import 'package:core/locale/data/locale_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleSettings', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SPStorage.init(
        appNamespace: 'core_test',
        env: 'test',
        managedKeys: PreferenceKeys.allKeys,
      );
      for (final key in PreferenceKeys.allKeys) {
        await SPStorage.remove(key);
      }
    });

    test('defaults to system preference', () {
      final repository = LocaleRepositoryImpl();
      expect(repository.load().preference, AppLocalePreference.system);
    });

    test('persists zh_hans preference', () async {
      final repository = LocaleRepositoryImpl();
      await repository.savePreference(AppLocalePreference.zhHans);
      expect(repository.load().preference, AppLocalePreference.zhHans);
    });

    test('migrates legacy zh storage value to zhHans', () async {
      await AppPreference.setLocalePreference('zh');
      final repository = LocaleRepositoryImpl();
      expect(repository.load().preference, AppLocalePreference.zhHans);
    });

    test('fixedLocale maps all five preferences', () {
      expect(AppLocalePreference.system.fixedLocale, isNull);
      expect(AppLocalePreference.zhHans.fixedLocale, const Locale('zh'));
      expect(AppLocalePreference.zhHant.fixedLocale, const Locale('zh', 'TW'));
      expect(AppLocalePreference.en.fixedLocale, const Locale('en'));
      expect(AppLocalePreference.ar.fixedLocale, const Locale('ar'));
    });
  });
}
