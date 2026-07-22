import 'dart:typed_data';

import 'backup_bluetooth_delegate.dart';

/// GATT 物理分片协议（BLBG），衔接现有 BLBT 逻辑帧。
///
/// 帧布局：`[magic BLBG][u32 blbtFrameIndex][u32 gattChunkIndex][u32 gattChunkTotal][u32 payloadLen][payload]`
abstract final class BackupBleGattTransfer {
  static const magicBytes = [0x42, 0x4C, 0x42, 0x47]; // BLBG
  static const headerSize = 20;
  static const defaultMtu = 517;

  /// 跨平台 BLE 编码 MTU（iOS Peripheral 协商后常见下限），发送前分片须能单次 ATT 写入。
  static const crossPlatformMtu = 185;
  static const defaultPayloadSize = 512;
  static const attWriteOverhead = 3;

  /// 避免 payload 恰好等于 `mtu - 3` 触发 Android Prepare+Execute 长写。
  static const attWriteSafetyMargin = 2;

  /// GATT 单 chunk payload 上限：`min(512, mtu - 3 - margin - headerSize)`，保证整包 BLBG 可单次 ATT 写入。
  static int gattPayloadMaxForMtu(int mtu) {
    final maxWriteBytes = mtu - attWriteOverhead - attWriteSafetyMargin;
    final maxPayload = maxWriteBytes - headerSize;
    if (maxPayload <= 0) {
      throw BackupBluetoothException('MTU 过小');
    }
    if (maxPayload >= defaultPayloadSize) {
      return defaultPayloadSize;
    }
    return maxPayload;
  }

  /// 单个 BLBG 分片的 GATT 写入字节数（含 20 字节头）。
  static int maxBlbgWriteSizeForMtu(int mtu) {
    return headerSize + gattPayloadMaxForMtu(mtu);
  }

  static List<Uint8List> encodeBlbgChunksForBlbtFrames(
    List<Uint8List> blbtFrames, {
    int mtu = defaultMtu,
  }) {
    final chunks = <Uint8List>[];
    for (var frameIndex = 0; frameIndex < blbtFrames.length; frameIndex++) {
      chunks.addAll(
        splitBlbtFrameToBlbgChunks(
          blbtFrames[frameIndex],
          blbtFrameIndex: frameIndex,
          mtu: mtu,
        ),
      );
    }
    return chunks;
  }

  static List<Uint8List> splitBlbtFrameToBlbgChunks(
    Uint8List blbtFrame, {
    required int blbtFrameIndex,
    int mtu = defaultMtu,
  }) {
    final maxPayload = gattPayloadMaxForMtu(mtu);
    final totalChunks = blbtFrame.isEmpty
        ? 1
        : (blbtFrame.length + maxPayload - 1) ~/ maxPayload;
    final chunks = <Uint8List>[];
    for (var chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
      final start = chunkIndex * maxPayload;
      final end = start + maxPayload > blbtFrame.length
          ? blbtFrame.length
          : start + maxPayload;
      final payload = blbtFrame.isEmpty
          ? Uint8List(0)
          : blbtFrame.sublist(start, end);
      chunks.add(
        _buildChunk(
          blbtFrameIndex: blbtFrameIndex,
          gattChunkIndex: chunkIndex,
          gattChunkTotal: totalChunks,
          payload: payload,
        ),
      );
    }
    return chunks;
  }

  static List<Uint8List> decodeBlbgChunksToBlbtFrames(List<Uint8List> chunks) {
    if (chunks.isEmpty) {
      throw BackupBluetoothException('未收到任何 GATT 分片');
    }

    final parsed = chunks.map(_parseBlbgChunk).toList();
    final byFrame = <int, List<_ParsedBlbgChunk>>{};
    for (final chunk in parsed) {
      byFrame.putIfAbsent(chunk.blbtFrameIndex, () => []).add(chunk);
    }

    final frameIndices = byFrame.keys.toList()..sort();
    final frames = <Uint8List>[];
    for (final frameIndex in frameIndices) {
      final frameChunks = byFrame[frameIndex]!
        ..sort((a, b) => a.gattChunkIndex.compareTo(b.gattChunkIndex));
      final expectedTotal = frameChunks.first.gattChunkTotal;
      if (frameChunks.length != expectedTotal) {
        throw BackupBluetoothException('GATT 分片数量不完整');
      }
      for (var i = 0; i < expectedTotal; i++) {
        final chunk = frameChunks[i];
        if (chunk.gattChunkIndex != i ||
            chunk.gattChunkTotal != expectedTotal) {
          throw BackupBluetoothException('GATT 分片顺序错误');
        }
      }
      final builder = BytesBuilder(copy: false);
      for (final chunk in frameChunks) {
        builder.add(chunk.payload);
      }
      frames.add(builder.toBytes());
    }
    return frames;
  }

  static _ParsedBlbgChunk _parseBlbgChunk(Uint8List chunk) {
    if (chunk.length < headerSize) {
      throw BackupBluetoothException('GATT 分片过短');
    }
    for (var i = 0; i < magicBytes.length; i++) {
      if (chunk[i] != magicBytes[i]) {
        throw BackupBluetoothException('无效的 GATT 分片');
      }
    }

    final offset = magicBytes.length;
    final blbtFrameIndex = _readU32(chunk, offset);
    final gattChunkIndex = _readU32(chunk, offset + 4);
    final gattChunkTotal = _readU32(chunk, offset + 8);
    final payloadLen = _readU32(chunk, offset + 12);
    final payloadStart = offset + 16;
    if (chunk.length < payloadStart + payloadLen) {
      throw BackupBluetoothException('GATT 分片 payload 长度不匹配');
    }
    if (gattChunkTotal <= 0 || gattChunkIndex >= gattChunkTotal) {
      throw BackupBluetoothException('GATT 分片索引无效');
    }

    return _ParsedBlbgChunk(
      blbtFrameIndex: blbtFrameIndex,
      gattChunkIndex: gattChunkIndex,
      gattChunkTotal: gattChunkTotal,
      payload: chunk.sublist(payloadStart, payloadStart + payloadLen),
    );
  }

  static Uint8List _buildChunk({
    required int blbtFrameIndex,
    required int gattChunkIndex,
    required int gattChunkTotal,
    required Uint8List payload,
  }) {
    final output = BytesBuilder(copy: false);
    output.add(magicBytes);
    output.add(_u32(blbtFrameIndex));
    output.add(_u32(gattChunkIndex));
    output.add(_u32(gattChunkTotal));
    output.add(_u32(payload.length));
    output.add(payload);
    return output.toBytes();
  }

  static List<int> _u32(int value) {
    return [
      value & 0xFF,
      (value >> 8) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 24) & 0xFF,
    ];
  }

  static int _readU32(Uint8List bytes, int offset) {
    return bytes[offset] |
        (bytes[offset + 1] << 8) |
        (bytes[offset + 2] << 16) |
        (bytes[offset + 3] << 24);
  }
}

final class _ParsedBlbgChunk {
  const _ParsedBlbgChunk({
    required this.blbtFrameIndex,
    required this.gattChunkIndex,
    required this.gattChunkTotal,
    required this.payload,
  });

  final int blbtFrameIndex;
  final int gattChunkIndex;
  final int gattChunkTotal;
  final Uint8List payload;
}
