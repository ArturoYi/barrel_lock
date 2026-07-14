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
    AppDeviceInfoReader.debugSetSnapshot(
      const AppDeviceInfoSnapshot(
        appName: 'BarrelLock',
        packageName: 'com.hulk.bazaarAndroid',
        version: '1.0.0',
        buildNumber: '1',
        platform: AppDeviceInfoPlatform.android,
      ),
    );
  });

  tearDown(AppDeviceInfoReader.debugReset);

  test('exports unified app entrypoints', () {
    expect(runBarrelLockApp, isNotNull);
    expect(BarrelLockApp.new, isNotNull);
  });

  testWidgets('HomePage renders tab shell', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomePage())),
    );

    expect(find.text('密码'), findsWidgets);
    expect(find.text('设置'), findsOneWidget);
  });

  testWidgets('SettingsPage renders theme controls', (tester) async {
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SettingsPage())),
    );

    expect(find.text('设置'), findsOneWidget);
    expect(find.text('主题模式'), findsOneWidget);
  });
}
