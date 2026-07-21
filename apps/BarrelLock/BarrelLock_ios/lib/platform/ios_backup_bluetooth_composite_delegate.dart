import 'package:barrel_lock/barrel_lock.dart';

import 'backup_bluetooth_delegate_impl.dart';

/// iOS 蓝牙备份 composite：同系统 Multipeer + 跨平台 BLE GATT。
const iosBackupBluetoothCompositeDelegate = BackupBluetoothCompositeDelegate(
  samePlatform: IosBackupBluetoothDelegate(),
  crossPlatform: BleGattBackupDelegate(),
);

/// iOS 同系统 P2P（MultipeerConnectivity）。
typedef IosBackupMultipeerDelegate = IosBackupBluetoothDelegate;
