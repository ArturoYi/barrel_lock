import '../../features/backup_manage/backup_bluetooth_delegate.dart';
import '../../features/backup_manage/backup_bluetooth_transport_mode.dart';
import '../../features/data_migration/bluetooth_backup_session.dart';

/// 蓝牙共享页路由（query `role=send|receive` & `mode=samePlatform|crossPlatform`）。
final class BluetoothBackupRoute {
  const BluetoothBackupRoute();

  String get name => 'bluetoothBackup';
  String get path => '/settings/data-migration/bluetooth';

  String call({
    required BackupBluetoothRole role,
    BackupBluetoothTransportMode transportMode =
        BackupBluetoothTransportMode.samePlatform,
  }) {
    return '$path?role=${role.name}&mode=${transportMode.name}';
  }

  BluetoothBackupSessionKey sessionFromQuery(Map<String, String> query) {
    return BluetoothBackupSessionKey(
      role: parseBluetoothBackupRole(query['role']),
      transportMode: parseBluetoothTransportMode(query['mode']),
    );
  }
}
