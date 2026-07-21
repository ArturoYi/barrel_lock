import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart';

import 'backup_bluetooth_delegate.dart';

/// P2P 传输分片协议（纯 Dart，供各平台 delegate 复用）。
///
/// 帧布局：`[magic BLBT][u32 frameIndex][u32 totalFrames][u32 payloadLen][payload]`
abstract final class BackupBluetoothTransfer {
  static const magicBytes = [0x42, 0x4C, 0x42, 0x54]; // BLBT
  static const defaultChunkSize = 512 * 1024;

  static List<Uint8List> encodeFrames(
    Uint8List bytes, {
    int chunkSize = defaultChunkSize,
  }) {
    if (chunkSize <= 0) {
      throw BackupBluetoothException('分片大小无效');
    }

    final totalFrames = (bytes.length + chunkSize - 1) ~/ chunkSize;
    final frames = <Uint8List>[];
    for (var index = 0; index < totalFrames; index++) {
      final start = index * chunkSize;
      final end = (start + chunkSize > bytes.length)
          ? bytes.length
          : start + chunkSize;
      final chunk = bytes.sublist(start, end);
      frames.add(
        _buildFrame(index: index, totalFrames: totalFrames, chunk: chunk),
      );
    }
    return frames;
  }

  static Uint8List decodeFrames(List<Uint8List> frames) {
    if (frames.isEmpty) {
      throw BackupBluetoothException('未收到任何传输帧');
    }

    final parsed = frames.map(_parseFrame).toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    final totalFrames = parsed.first.totalFrames;
    if (parsed.length != totalFrames) {
      throw BackupBluetoothException('传输帧数量不完整');
    }
    for (var i = 0; i < totalFrames; i++) {
      if (parsed[i].index != i) {
        throw BackupBluetoothException('传输帧顺序错误');
      }
    }

    final builder = BytesBuilder(copy: false);
    for (final frame in parsed) {
      builder.add(frame.payload);
    }
    return builder.toBytes();
  }

  static Uint8List _buildFrame({
    required int index,
    required int totalFrames,
    required Uint8List chunk,
  }) {
    final output = BytesBuilder(copy: false);
    output.add(magicBytes);
    output.add(_u32(index));
    output.add(_u32(totalFrames));
    output.add(_u32(chunk.length));
    output.add(chunk);
    return output.toBytes();
  }

  static _ParsedFrame _parseFrame(Uint8List frame) {
    if (frame.length < magicBytes.length + 12) {
      throw BackupBluetoothException('传输帧过短');
    }
    for (var i = 0; i < magicBytes.length; i++) {
      if (frame[i] != magicBytes[i]) {
        throw BackupBluetoothException('无效的蓝牙传输帧');
      }
    }

    final offset = magicBytes.length;
    final index = _readU32(frame, offset);
    final totalFrames = _readU32(frame, offset + 4);
    final payloadLen = _readU32(frame, offset + 8);
    final payloadStart = offset + 12;
    if (frame.length < payloadStart + payloadLen) {
      throw BackupBluetoothException('传输帧 payload 长度不匹配');
    }

    return _ParsedFrame(
      index: index,
      totalFrames: totalFrames,
      payload: frame.sublist(payloadStart, payloadStart + payloadLen),
    );
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

final class _ParsedFrame {
  const _ParsedFrame({
    required this.index,
    required this.totalFrames,
    required this.payload,
  });

  final int index;
  final int totalFrames;
  final Uint8List payload;
}

/// 会话元数据（可选，首帧前 JSON 握手）。
final class BackupBluetoothSessionMeta {
  const BackupBluetoothSessionMeta({
    required this.totalBytes,
    required this.sha256Hex,
    this.chunkCount,
  });

  final int totalBytes;
  final String sha256Hex;
  final int? chunkCount;

  Map<String, dynamic> toJson() {
    return {
      'totalBytes': totalBytes,
      'sha256Hex': sha256Hex,
      if (chunkCount != null) 'chunkCount': chunkCount,
    };
  }

  factory BackupBluetoothSessionMeta.fromJson(Map<String, dynamic> json) {
    return BackupBluetoothSessionMeta(
      totalBytes: json['totalBytes'] as int? ?? 0,
      sha256Hex: json['sha256Hex'] as String? ?? '',
      chunkCount: json['chunkCount'] as int?,
    );
  }

  static String encodeJson(BackupBluetoothSessionMeta meta) {
    return jsonEncode(meta.toJson());
  }

  static BackupBluetoothSessionMeta decodeJson(String raw) {
    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) {
      throw BackupBluetoothException('会话元数据无效');
    }
    return BackupBluetoothSessionMeta.fromJson(json);
  }
}
