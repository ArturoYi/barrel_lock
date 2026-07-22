import 'package:barrel_lock/barrel_lock.dart';

import 'backup_bluetooth_delegate_impl.dart';

/// Android 蓝牙备份 composite：同系统 Nearby + 跨平台 BLE GATT。
const androidBackupBluetoothCompositeDelegate =
    BackupBluetoothCompositeDelegate(
      samePlatform: AndroidBackupBluetoothDelegate(),
      crossPlatform: BleGattBackupDelegate(),
    );

/// Android 同系统 P2P（Nearby Connections）。
typedef AndroidBackupNearbyDelegate = AndroidBackupBluetoothDelegate;
