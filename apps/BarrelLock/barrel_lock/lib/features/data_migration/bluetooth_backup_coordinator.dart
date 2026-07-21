import 'package:core/core.dart';

import '../../router/application/app_router.dart';
import '../../router/domain/bluetooth_backup_route.dart';
import '../backup_manage/backup_bluetooth_delegate.dart';
import '../backup_manage/backup_bluetooth_transport_mode.dart';
import 'bluetooth_backup_session.dart';

/// 蓝牙共享页导航协调器。
final class BluetoothBackupCoordinator {
  const BluetoothBackupCoordinator();

  void pop() => AppRouter.pop();

  void open({
    required BackupBluetoothRole role,
    BackupBluetoothTransportMode transportMode =
        BackupBluetoothTransportMode.samePlatform,
  }) {
    AppRouter.push(
      BluetoothBackupRoute().call(role: role, transportMode: transportMode),
    );
  }

  void openSession(BluetoothBackupSessionKey session) {
    open(role: session.role, transportMode: session.transportMode);
  }
}

final bluetoothBackupCoordinatorProvider = Provider<BluetoothBackupCoordinator>(
  (_) => const BluetoothBackupCoordinator(),
);
