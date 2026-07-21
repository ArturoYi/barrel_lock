import 'package:barrel_lock/barrel_lock.dart';
import 'package:barrel_lock_ui/barrel_lock_ui.dart';
import 'package:core/core.dart';

import 'platform/android_backup_bluetooth_composite_delegate.dart';
import 'platform/backup_file_delegate_impl.dart';
import 'router/app_router_config.dart';

Future<void> main() async {
  await runBarrelLockApp(
    configureRouter: configureBarrelLockRouter,
    scopeBuilder: (child) => ProviderScope(
      overrides: [
        backupFileDelegateProvider.overrideWithValue(
          const AndroidBackupFileDelegate(),
        ),
        backupBluetoothDelegateProvider.overrideWithValue(
          androidBackupBluetoothCompositeDelegate,
        ),
      ],
      child: child,
    ),
  );
}
