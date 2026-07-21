import 'dart:async';
import 'dart:typed_data';

import 'backup_bluetooth_events.dart';

/// 蓝牙 / 附近设备 P2P 传输角色。
enum BackupBluetoothRole { send, receive }

/// 蓝牙传输进度（0.0–1.0）。
typedef BackupBluetoothProgressCallback = void Function(double progress);

/// 平台 P2P 蓝牙迁移委托；由各 app 通过 Riverpod override 注入。
abstract class BackupBluetoothDelegate {
  const BackupBluetoothDelegate();

  /// 会话事件流（发现设备、阶段、进度等）；无活动会话时无事件。
  Stream<BackupBluetoothEvent> get events => const Stream.empty();

  /// 发送端：向已连接/发现的对端传输 `.blbak` 字节。
  Future<void> sendBackup({
    required Uint8List bytes,
    BackupBluetoothProgressCallback? onProgress,
  });

  /// 接收端：等待对端传输；取消或失败返回 null。
  Future<Uint8List?> receiveBackup({
    BackupBluetoothProgressCallback? onProgress,
  });

  /// 取消当前广播 / 发现 / 传输。
  Future<void> cancel();

  /// 发送端：用户点选对端后发起连接（需在 [sendBackup] 会话进行中调用）。
  Future<void> connectToPeer(String peerId) async {
    throw BackupBluetoothException('当前传输模式不支持手动选择设备');
  }
}

/// 蓝牙迁移失败。
final class BackupBluetoothException implements Exception {
  BackupBluetoothException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 未注入或未实现平台 delegate 时的占位。
final class UnavailableBackupBluetoothDelegate extends BackupBluetoothDelegate {
  const UnavailableBackupBluetoothDelegate([this.message = '当前平台尚未配置蓝牙迁移']);

  final String message;

  @override
  Future<void> sendBackup({
    required Uint8List bytes,
    BackupBluetoothProgressCallback? onProgress,
  }) async {
    throw BackupBluetoothException(message);
  }

  @override
  Future<Uint8List?> receiveBackup({
    BackupBluetoothProgressCallback? onProgress,
  }) async {
    throw BackupBluetoothException(message);
  }

  @override
  Future<void> cancel() async {}
}
