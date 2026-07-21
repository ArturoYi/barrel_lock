import 'dart:typed_data';

import 'backup_bluetooth_delegate.dart';
import 'backup_bluetooth_events.dart';
import 'backup_bluetooth_transport_mode.dart';

/// 按传输模式路由到同平台 P2P 或跨平台 GATT delegate。
final class BackupBluetoothCompositeDelegate extends BackupBluetoothDelegate {
  const BackupBluetoothCompositeDelegate({
    required this.samePlatform,
    required this.crossPlatform,
    this.transportMode = BackupBluetoothTransportMode.samePlatform,
  });

  final BackupBluetoothDelegate samePlatform;
  final BackupBluetoothDelegate crossPlatform;
  final BackupBluetoothTransportMode transportMode;

  BackupBluetoothDelegate get _active => switch (transportMode) {
    BackupBluetoothTransportMode.samePlatform => samePlatform,
    BackupBluetoothTransportMode.crossPlatform => crossPlatform,
  };

  BackupBluetoothCompositeDelegate withMode(BackupBluetoothTransportMode mode) {
    return BackupBluetoothCompositeDelegate(
      samePlatform: samePlatform,
      crossPlatform: crossPlatform,
      transportMode: mode,
    );
  }

  @override
  Stream<BackupBluetoothEvent> get events => _active.events;

  @override
  Future<void> sendBackup({
    required Uint8List bytes,
    BackupBluetoothProgressCallback? onProgress,
  }) {
    return _active.sendBackup(bytes: bytes, onProgress: onProgress);
  }

  @override
  Future<Uint8List?> receiveBackup({
    BackupBluetoothProgressCallback? onProgress,
  }) {
    return _active.receiveBackup(onProgress: onProgress);
  }

  @override
  Future<void> cancel() => _active.cancel();

  @override
  Future<void> connectToPeer(String peerId) => _active.connectToPeer(peerId);
}
