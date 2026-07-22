import 'package:barrel_lock/barrel_lock.dart';

import '../pages/app_lock/app_lock_pin_manage_page.dart';
import '../pages/app_lock/app_lock_settings_page.dart';
import '../pages/settings_subpages.dart';
import '../pages/cipher_add/cipher_add_page.dart';
import '../pages/detail_page.dart';
import '../pages/home/home_page.dart';
import '../pages/launch_screen/launch_screen_page.dart';
import '../pages/settings_page.dart';

/// 向 [AppRouter] 注入本平台 Page Widget。
void configureBarrelLockRouter() {
  AppRouter.configure(
    AppRouteBuilders(
      launchScreen: (_, _) => const LaunchScreenPage(),
      home: (_, _) => const HomePage(),
      detail: (_, match) => DetailPage(id: match.parameters.pathParams['id']!),
      cipherAdd: (_, match) =>
          CipherAddPage(vaultId: match.parameters.queryParams['vaultId']),
      settings: (_, _) => const SettingsPage(),
      dataMigration: (_, _) => const DataMigrationPage(),
      bluetoothBackup: (_, match) {
        final session = AppRoutes.bluetoothBackup.sessionFromQuery(
          match.parameters.queryParams,
        );
        return BluetoothBackupPage(
          role: session.role,
          transportMode: session.transportMode,
        );
      },
      appLock: (_, _) => const AppLockSettingsPage(),
      appLockPinSetup: (_, _) => const AppLockPinSetupPage(),
      clearData: (_, _) => const ClearDataPage(),
      supportDocument: (_, match) => SupportDocumentPage(
        docId: AppRoutes.supportDocument.docIdFromQuery(
          match.parameters.queryParams,
        ),
      ),
      supportFeedback: (_, _) => const SupportFeedbackPage(),
    ),
  );
}
