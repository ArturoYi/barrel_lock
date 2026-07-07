import 'package:core/core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppTypography', () {
    test('tokens carry geometry without baked color', () {
      final scheme = ColorScheme.fromSeed(seedColor: Colors.blue);
      final typography = AppTypography.standard(colorScheme: scheme);

      expect(typography.bodyLarge.color, isNull);
      expect(typography.bodyLarge.fontSize, isNotNull);
      expect(typography.titleLarge.fontWeight, isNotNull);
    });

    test('standard applies NotoSansSC to all M3 tokens', () {
      final typography = AppTypography.standard(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      );

      for (final style in [
        typography.displayLarge,
        typography.displayMedium,
        typography.displaySmall,
        typography.headlineLarge,
        typography.headlineMedium,
        typography.headlineSmall,
        typography.titleLarge,
        typography.titleMedium,
        typography.titleSmall,
        typography.bodyLarge,
        typography.bodyMedium,
        typography.bodySmall,
        typography.labelLarge,
        typography.labelMedium,
        typography.labelSmall,
      ]) {
        expect(style.fontFamily, AppFonts.notoSansSC);
      }
    });
  });

  group('AppTheme', () {
    testWidgets('wires NotoSansSC on textTheme and AppTypography extension', (
      tester,
    ) async {
      late ThemeData theme;
      late AppTypography typography;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(AppColorScheme.deepPurple),
          home: Builder(
            builder: (context) {
              theme = Theme.of(context);
              typography = context.typography;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(theme.textTheme.bodyMedium?.fontFamily, AppFonts.notoSansSC);
      expect(typography.bodyMedium.fontFamily, AppFonts.notoSansSC);
    });

    test('disables Material press splash globally', () {
      final theme = AppTheme.light(AppColorScheme.deepPurple);

      expect(theme.splashFactory, same(NoSplash.splashFactory));
      expect(theme.highlightColor, Colors.transparent);
    });
  });

  group('AppFontScale', () {
    test('fromStorage falls back to standard for unknown values', () {
      expect(AppFontScale.fromStorage(null), AppFontScale.standard);
      expect(AppFontScale.fromStorage(''), AppFontScale.standard);
      expect(AppFontScale.fromStorage('unknown'), AppFontScale.standard);
      expect(AppFontScale.fromStorage('large'), AppFontScale.large);
    });

    test('scaleFactor increases monotonically', () {
      expect(
        AppFontScale.small.scaleFactor,
        lessThan(AppFontScale.standard.scaleFactor),
      );
      expect(
        AppFontScale.standard.scaleFactor,
        lessThan(AppFontScale.large.scaleFactor),
      );
      expect(
        AppFontScale.large.scaleFactor,
        lessThan(AppFontScale.extraLarge.scaleFactor),
      );
    });
  });

  group('SPStorage', () {
    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({
        'other_plugin_key': 'keep',
        'barrel_lock_test_theme_mode': 'dark',
      });
      await SPStorage.init(
        appNamespace: 'barrel_lock',
        env: 'test',
        managedKeys: PreferenceKeys.allKeys,
      );
    });

    test('getRealKey uses app namespace and env prefix', () {
      expect(
        PreferenceConfig.getRealKey(PreferenceKeys.themeMode),
        'barrel_lock_test_theme_mode',
      );
    });

    test('clearAll only removes managed keys', () async {
      await SPStorage.clearAll();

      expect(SPStorage.getString(PreferenceKeys.themeMode), isNull);
      expect(
        SharedPreferences.getInstance().then(
          (prefs) => prefs.getString('other_plugin_key'),
        ),
        completion('keep'),
      );
    });

    test('exportAll only includes managed keys', () {
      final exported = SPStorage.getAllAsMap();

      expect(exported.containsKey(PreferenceKeys.themeMode), isTrue);
      expect(exported.containsKey('other_plugin_key'), isFalse);
    });
  });

  group('AppStorage', () {
    tearDown(() async {
      await AppStorage.close();
    });

    test('throws when accessed before init', () {
      expect(() => AppStorage.database, throwsStateError);
    });

    test('initForTesting opens in-memory database', () async {
      await AppStorage.initForTesting();
      expect(AppStorage.database, isA<AppDatabase>());
      expect(StorageConfig.databaseFileName, 'test_app_test');
    });
  });

  group('AppDeviceInfoSnapshot', () {
    test('versionLabel and osDescription format display strings', () {
      const snapshot = AppDeviceInfoSnapshot(
        appName: 'BarrelLock',
        packageName: 'com.example.barrel_lock',
        version: '1.2.3',
        buildNumber: '456',
        platform: AppDeviceInfoPlatform.ios,
        deviceModel: 'iPhone 16 Pro',
        osVersion: '17.2',
        isPhysicalDevice: true,
      );

      expect(snapshot.versionLabel, '1.2.3 (456)');
      expect(snapshot.osDescription, 'iOS 17.2');
    });
  });

  group('AppDeviceInfo', () {
    tearDown(AppDeviceInfoReader.debugReset);

    test('throws when accessed before init', () {
      expect(() => AppDeviceInfo.versionLabel, throwsStateError);
    });

    test('reads from cached snapshot', () {
      AppDeviceInfoReader.debugSetSnapshot(
        const AppDeviceInfoSnapshot(
          appName: 'BarrelLock',
          packageName: 'com.example.barrel_lock',
          version: '2.0.0',
          buildNumber: '100',
          platform: AppDeviceInfoPlatform.android,
        ),
      );

      expect(AppDeviceInfo.versionLabel, '2.0.0 (100)');
      expect(AppDeviceInfo.platform, AppDeviceInfoPlatform.android);
    });
  });

  group('AppDeviceInfoReader', () {
    test('maps iOS device info to normalized snapshot', () {
      final snapshot = AppDeviceInfoReader.mapSnapshotForTesting(
        packageInfo: PackageInfo(
          appName: 'BarrelLock',
          packageName: 'com.example.barrel_lock',
          version: '1.0.0',
          buildNumber: '42',
        ),
        deviceInfo: IosDeviceInfo.fromMap({
          'name': 'iPhone',
          'systemName': 'iOS',
          'systemVersion': '17.2',
          'model': 'iPhone',
          'modelName': 'iPhone 16 Pro',
          'localizedModel': 'iPhone',
          'freeDiskSize': 0,
          'totalDiskSize': 0,
          'isPhysicalDevice': true,
          'physicalRamSize': 0,
          'availableRamSize': 0,
          'isiOSAppOnMac': false,
          'isiOSAppOnVision': false,
          'utsname': {
            'sysname': 'Darwin',
            'nodename': 'localhost',
            'release': '23.0.0',
            'version': 'Darwin Kernel Version 23.0.0',
            'machine': 'iPhone16,1',
          },
        }),
      );

      expect(snapshot.platform, AppDeviceInfoPlatform.ios);
      expect(snapshot.deviceModel, 'iPhone 16 Pro');
      expect(snapshot.osVersion, '17.2');
      expect(snapshot.versionLabel, '1.0.0 (42)');
    });
  });
}
