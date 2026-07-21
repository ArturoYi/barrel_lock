import 'dart:typed_data';

import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';

import 'ios_backup_multipeer_channel.dart';

/// iOS 蓝牙 P2P 迁移（MultipeerConnectivity + BLBT 帧）。
final class IosBackupBluetoothDelegate extends BackupBluetoothDelegate {
  const IosBackupBluetoothDelegate();

  @override
  Stream<BackupBluetoothEvent> get events => BackupP2pEventChannel.watch();

  @override
  Future<void> sendBackup({
    required Uint8List bytes,
    BackupBluetoothProgressCallback? onProgress,
  }) async {
    final frames = BackupBluetoothTransfer.encodeFrames(bytes);
    final digest = sha256.convert(bytes).toString();
    final meta = BackupBluetoothSessionMeta(
      totalBytes: bytes.length,
      sha256Hex: digest,
    );
    await IosBackupMultipeerChannel.transferSend(
      sessionMeta: BackupBluetoothSessionMeta.encodeJson(meta),
      frames: frames,
    );
    onProgress?.call(1);
  }

  @override
  Future<Uint8List?> receiveBackup({
    BackupBluetoothProgressCallback? onProgress,
  }) async {
    final result = await IosBackupMultipeerChannel.transferReceive();
    if (result.frames.isEmpty) {
      return null;
    }

    final bytes = BackupBluetoothTransfer.decodeFrames(result.frames);
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
  Future<void> cancel() => IosBackupMultipeerChannel.cancel();

  @override
  Future<void> connectToPeer(String peerId) =>
      IosBackupMultipeerChannel.connectPeer(peerId);
}
