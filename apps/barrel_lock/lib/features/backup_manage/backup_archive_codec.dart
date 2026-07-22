import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart';

import 'backup_snapshot.dart';

/// `.blbak` 备份包编解码。
abstract final class BackupArchiveCodec {
  static const magicBytes = [0x42, 0x4C, 0x42, 0x4B]; // BLBK
  static const formatVersion = 1;
  static const fileExtension = 'blbak';

  static BackupSnapshot snapshotFromTables(
    BackupTableSnapshot tables, {
    required DateTime exportedAt,
  }) {
    final tablesJson = jsonEncode(tables.toTablesJson());
    return BackupSnapshot(
      formatVersion: formatVersion,
      appSchemaVersion: DatabaseSchemaVersion.current,
      exportedAt: exportedAt.toUtc(),
      tables: tables,
      checksum: _checksumHex(tablesJson),
    );
  }

  static Future<Uint8List> encode(BackupSnapshot snapshot) async {
    final tablesJson = jsonEncode(snapshot.tables.toTablesJson());
    final checksum = _checksumHex(tablesJson);
    final payload = BackupSnapshot(
      formatVersion: snapshot.formatVersion,
      appSchemaVersion: snapshot.appSchemaVersion,
      exportedAt: snapshot.exportedAt,
      tables: snapshot.tables,
      checksum: checksum,
    );

    final payloadBytes = utf8.encode(jsonEncode(payload.toPayloadJson()));
    final encrypted = await AppCrypto.encrypt(payloadBytes);

    final output = BytesBuilder(copy: false);
    output.add(magicBytes);
    output.add(_int32LittleEndian(formatVersion));
    output.add(encrypted.bytes);
    return output.toBytes();
  }

  static Future<BackupSnapshot> decode(Uint8List bytes) async {
    if (bytes.length < magicBytes.length + 4) {
      throw BackupArchiveException('备份文件过短');
    }

    for (var i = 0; i < magicBytes.length; i++) {
      if (bytes[i] != magicBytes[i]) {
        throw BackupArchiveException('不是有效的 BarrelLock 备份文件');
      }
    }

    final fileFormatVersion = _readInt32LittleEndian(bytes, magicBytes.length);
    if (fileFormatVersion != formatVersion) {
      throw BackupArchiveException('不支持的备份格式版本：$fileFormatVersion');
    }

    final encryptedBytes = bytes.sublist(magicBytes.length + 4);
    List<int> plainBytes;
    try {
      plainBytes = await AppCrypto.decrypt(EncryptedPayload(encryptedBytes));
    } on SecretBoxAuthenticationError {
      throw BackupArchiveException('备份文件无法解密，密钥可能不匹配');
    }

    final payloadJson = jsonDecode(utf8.decode(plainBytes));
    if (payloadJson is! Map<String, dynamic>) {
      throw BackupArchiveException('备份包内容无效');
    }

    final snapshot = BackupSnapshot.fromPayloadJson(payloadJson);
    if (snapshot.formatVersion != formatVersion) {
      throw BackupArchiveException(
        '不支持的备份 payload 版本：${snapshot.formatVersion}',
      );
    }
    if (snapshot.appSchemaVersion > DatabaseSchemaVersion.current) {
      throw BackupArchiveException('备份来自更高版本应用，请先升级 App');
    }

    final tablesJson = jsonEncode(snapshot.tables.toTablesJson());
    final expectedChecksum = _checksumHex(tablesJson);
    if (snapshot.checksum != expectedChecksum) {
      throw BackupArchiveException('备份文件校验失败，可能已损坏或被篡改');
    }

    return snapshot;
  }

  static String _checksumHex(String tablesJson) {
    final digest = sha256.convert(utf8.encode(tablesJson));
    return digest.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  static List<int> _int32LittleEndian(int value) {
    return [
      value & 0xFF,
      (value >> 8) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 24) & 0xFF,
    ];
  }

  static int _readInt32LittleEndian(Uint8List bytes, int offset) {
    return bytes[offset] |
        (bytes[offset + 1] << 8) |
        (bytes[offset + 2] << 16) |
        (bytes[offset + 3] << 24);
  }
}
