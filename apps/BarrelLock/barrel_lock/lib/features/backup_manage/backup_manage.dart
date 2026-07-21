export 'backup_archive_codec.dart';
export 'backup_ble_gatt_transfer.dart';
export 'backup_bluetooth_composite_delegate.dart';
export 'backup_bluetooth_delegate.dart';
export 'backup_bluetooth_events.dart';
export 'backup_bluetooth_transfer.dart';
export 'backup_bluetooth_transport_mode.dart';
export 'backup_p2p_event_channel.dart';
export 'ble_gatt_backup_channel.dart';
export 'ble_gatt_backup_delegate.dart';
export 'backup_file_delegate.dart';
export 'backup_manage_model.dart';
export 'backup_snapshot.dart';

import 'package:core/core.dart';

import 'backup_bluetooth_composite_delegate.dart';
import 'backup_bluetooth_delegate.dart';
import 'backup_bluetooth_transport_mode.dart';
import 'backup_file_delegate.dart';

final backupFileDelegateProvider = Provider<BackupFileDelegate>(
  (_) => const UnavailableBackupFileDelegate(),
);

final backupBluetoothDelegateProvider = Provider<BackupBluetoothDelegate>(
  (_) => const UnavailableBackupBluetoothDelegate(),
);

/// 按传输模式解析 composite delegate；非 composite 时返回原 delegate。
final backupBluetoothDelegateForModeProvider =
    Provider.family<BackupBluetoothDelegate, BackupBluetoothTransportMode>((
      ref,
      mode,
    ) {
      final delegate = ref.watch(backupBluetoothDelegateProvider);
      if (delegate is BackupBluetoothCompositeDelegate) {
        return delegate.withMode(mode);
      }
      return delegate;
    });
