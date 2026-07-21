import '../backup_manage/backup_bluetooth_delegate.dart';
import '../backup_manage/backup_bluetooth_transport_mode.dart';

/// 蓝牙共享会话参数（角色 + 传输模式）。
final class BluetoothBackupSessionKey {
  const BluetoothBackupSessionKey({
    required this.role,
    this.transportMode = BackupBluetoothTransportMode.samePlatform,
  });

  final BackupBluetoothRole role;
  final BackupBluetoothTransportMode transportMode;

  @override
  bool operator ==(Object other) {
    return other is BluetoothBackupSessionKey &&
        other.role == role &&
        other.transportMode == transportMode;
  }

  @override
  int get hashCode => Object.hash(role, transportMode);
}

/// 角色选择 Sheet 返回值。
final class BluetoothBackupSelection {
  const BluetoothBackupSelection({
    required this.role,
    required this.transportMode,
  });

  final BackupBluetoothRole role;
  final BackupBluetoothTransportMode transportMode;

  BluetoothBackupSessionKey get sessionKey =>
      BluetoothBackupSessionKey(role: role, transportMode: transportMode);
}

BackupBluetoothRole parseBluetoothBackupRole(String? raw) {
  for (final role in BackupBluetoothRole.values) {
    if (role.name == raw) {
      return role;
    }
  }
  return BackupBluetoothRole.send;
}

BackupBluetoothTransportMode parseBluetoothTransportMode(String? raw) {
  for (final mode in BackupBluetoothTransportMode.values) {
    if (mode.name == raw) {
      return mode;
    }
  }
  return BackupBluetoothTransportMode.samePlatform;
}
