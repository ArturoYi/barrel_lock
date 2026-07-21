import 'package:flutter/services.dart';

import 'backup_bluetooth_delegate.dart';

/// 跨平台 BLE GATT 备份 MethodChannel（iOS / Android 原生层统一接口）。
abstract final class BleGattBackupChannel {
  static const _channel = MethodChannel('com.barrellock/backup_ble_gatt');

  static Future<void> transferSend({
    required String sessionMeta,
    required List<Uint8List> chunks,
  }) async {
    try {
      await _channel.invokeMethod<void>('transferSend', {
        'sessionMeta': sessionMeta,
        'chunks': chunks,
      });
    } on PlatformException catch (error) {
      throw BackupBluetoothException(error.message ?? '跨平台蓝牙发送失败');
    }
  }

  static Future<({String sessionMeta, List<Uint8List> chunks})>
  transferReceive() async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'transferReceive',
      );
      if (result == null) {
        return (sessionMeta: '', chunks: const <Uint8List>[]);
      }
      final sessionMeta = result['sessionMeta'] as String? ?? '';
      final rawChunks = result['chunks'] as List<Object?>? ?? const [];
      final chunks = <Uint8List>[
        for (final item in rawChunks)
          if (item is Uint8List) item,
      ];
      return (sessionMeta: sessionMeta, chunks: chunks);
    } on PlatformException catch (error) {
      throw BackupBluetoothException(error.message ?? '跨平台蓝牙接收失败');
    }
  }

  static Future<void> cancel() async {
    await _channel.invokeMethod<void>('cancel');
  }

  static Future<void> connectPeer(String peerId) async {
    try {
      await _channel.invokeMethod<void>('connectPeer', peerId);
    } on PlatformException catch (error) {
      throw BackupBluetoothException(error.message ?? '连接设备失败');
    }
  }
}
