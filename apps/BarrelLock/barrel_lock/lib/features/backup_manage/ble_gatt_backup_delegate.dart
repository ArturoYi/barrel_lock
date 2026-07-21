import 'dart:typed_data';

import 'package:core/core.dart';

import 'backup_ble_gatt_transfer.dart';
import 'backup_bluetooth_delegate.dart';
import 'backup_bluetooth_events.dart';
import 'backup_bluetooth_transfer.dart';
import 'backup_p2p_event_channel.dart';
import 'ble_gatt_backup_channel.dart';

/// 跨平台 BLE GATT 备份委托（BLBG → BLBT → BLBK）。
final class BleGattBackupDelegate extends BackupBluetoothDelegate {
  const BleGattBackupDelegate({
    this.mtu = BackupBleGattTransfer.crossPlatformMtu,
  });

  final int mtu;

  @override
  Stream<BackupBluetoothEvent> get events => BackupP2pEventChannel.watch();

  @override
  Future<void> sendBackup({
    required Uint8List bytes,
    BackupBluetoothProgressCallback? onProgress,
  }) async {
    final frames = BackupBluetoothTransfer.encodeFrames(bytes);
    final chunks = BackupBleGattTransfer.encodeBlbgChunksForBlbtFrames(
      frames,
      mtu: mtu,
    );
    final digest = sha256.convert(bytes).toString();
    final meta = BackupBluetoothSessionMeta(
      totalBytes: bytes.length,
      sha256Hex: digest,
      chunkCount: chunks.length,
    );
    await BleGattBackupChannel.transferSend(
      sessionMeta: BackupBluetoothSessionMeta.encodeJson(meta),
      chunks: chunks,
    );
    onProgress?.call(1);
  }

  @override
  Future<Uint8List?> receiveBackup({
    BackupBluetoothProgressCallback? onProgress,
  }) async {
    final result = await BleGattBackupChannel.transferReceive();
    if (result.chunks.isEmpty) {
      return null;
    }

    final frames = BackupBleGattTransfer.decodeBlbgChunksToBlbtFrames(
      result.chunks,
    );
    final bytes = BackupBluetoothTransfer.decodeFrames(frames);
    if (result.sessionMeta.isNotEmpty) {
      final meta = BackupBluetoothSessionMeta.decodeJson(result.sessionMeta);
      final digest = sha256.convert(bytes).toString();
      if (meta.sha256Hex.isNotEmpty && meta.sha256Hex != digest) {
        throw BackupBluetoothException('备份校验失败，请重试');
      }
    }
    onProgress?.call(1);
    return bytes;
  }

  @override
  Future<void> cancel() => BleGattBackupChannel.cancel();

  @override
  Future<void> connectToPeer(String peerId) =>
      BleGattBackupChannel.connectPeer(peerId);
}
