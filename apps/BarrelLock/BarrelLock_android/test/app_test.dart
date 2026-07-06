import 'package:barrel_lock_android/pages/home/home_page.dart';
import 'package:barrel_lock_android/pages/settings_page.dart';
import 'package:barrel_lock_ui/barrel_lock_ui.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await SPStorage.init(
      appNamespace: 'barrel_lock',
      env: 'test',
      managedKeys: PreferenceKeys.allKeys,
    );
  });

  test('exports unified app entrypoints', () {
    expect(runBarrelLockApp, isNotNull);
    expect(BarrelLockApp.new, isNotNull);
  });

  testWidgets('HomePage renders BarrelLock greeting', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomePage())),
    );

    expect(find.text('BarrelLock'), findsOneWidget);
    expect(find.textContaining('Hello'), findsOneWidget);
    expect(find.text('路径跳转 → 详情页'), findsOneWidget);
  });

  testWidgets('SettingsPage renders theme controls', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SettingsPage())),
    );

    expect(find.text('设置页'), findsOneWidget);
    expect(find.text('主题模式'), findsOneWidget);
  });
}
