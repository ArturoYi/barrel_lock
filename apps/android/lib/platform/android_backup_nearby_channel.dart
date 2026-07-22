import 'package:barrel_lock/barrel_lock.dart';
import 'package:flutter/services.dart';

/// Android Nearby Connections MethodChannel 封装。
abstract final class AndroidBackupNearbyChannel {
  static const _channel = MethodChannel('com.barrellock/backup_nearby');

  static Future<void> transferSend({
    required String sessionMeta,
    required List<Uint8List> frames,
  }) async {
    try {
      await _channel.invokeMethod<void>('transferSend', {
        'sessionMeta': sessionMeta,
        'frames': frames,
      });
    } on PlatformException catch (error) {
      throw BackupBluetoothException(error.message ?? '蓝牙发送失败');
    }
  }

  static Future<({String sessionMeta, List<Uint8List> frames})>
  transferReceive() async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'transferReceive',
      );
      if (result == null) {
        return (sessionMeta: '', frames: const <Uint8List>[]);
      }
      final sessionMeta = result['sessionMeta'] as String? ?? '';
      final rawFrames = result['frames'] as List<Object?>? ?? const [];
      final frames = <Uint8List>[
        for (final item in rawFrames)
          if (item is Uint8List) item,
      ];
      return (sessionMeta: sessionMeta, frames: frames);
    } on PlatformException catch (error) {
      throw BackupBluetoothException(error.message ?? '蓝牙接收失败');
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
