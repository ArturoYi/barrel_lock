import 'package:core/core.dart';

/// 四表只读快照，用于备份包序列化。
final class BackupTableSnapshot {
  const BackupTableSnapshot({
    required this.vaults,
    required this.folders,
    required this.ciphers,
    required this.attachments,
  });

  final List<Vault> vaults;
  final List<Folder> folders;
  final List<CipherEntry> ciphers;
  final List<CipherAttachment> attachments;

  static const empty = BackupTableSnapshot(
    vaults: [],
    folders: [],
    ciphers: [],
    attachments: [],
  );

  Map<String, dynamic> toTablesJson() {
    return <String, dynamic>{
      'vault': vaults.map((row) => row.toJson()).toList(),
      'folder': folders.map((row) => row.toJson()).toList(),
      'cipher': ciphers.map((row) => row.toJson()).toList(),
      'cipher_attachment': attachments.map((row) => row.toJson()).toList(),
    };
  }

  factory BackupTableSnapshot.fromTablesJson(Map<String, dynamic> json) {
    List<T> parseRows<T>(
      String key,
      T Function(Map<String, dynamic> json) fromJson,
    ) {
      final raw = json[key];
      if (raw is! List) {
        return const [];
      }
      return raw
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList(growable: false);
    }

    return BackupTableSnapshot(
      vaults: parseRows('vault', Vault.fromJson),
      folders: parseRows('folder', Folder.fromJson),
      ciphers: parseRows('cipher', CipherEntry.fromJson),
      attachments: parseRows('cipher_attachment', CipherAttachment.fromJson),
    );
  }
}

/// 解密后的备份包业务载荷。
final class BackupSnapshot {
  const BackupSnapshot({
    required this.formatVersion,
    required this.appSchemaVersion,
    required this.exportedAt,
    required this.tables,
    required this.checksum,
  });

  final int formatVersion;
  final int appSchemaVersion;
  final DateTime exportedAt;
  final BackupTableSnapshot tables;
  final String checksum;

  Map<String, dynamic> toPayloadJson() {
    return <String, dynamic>{
      'formatVersion': formatVersion,
      'appSchemaVersion': appSchemaVersion,
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'tables': tables.toTablesJson(),
      'checksum': checksum,
    };
  }

  factory BackupSnapshot.fromPayloadJson(Map<String, dynamic> json) {
    final exportedAtRaw = json['exportedAt'];
    if (exportedAtRaw is! String) {
      throw BackupArchiveException('备份包缺少 exportedAt');
    }

    final tablesRaw = json['tables'];
    if (tablesRaw is! Map<String, dynamic>) {
      throw BackupArchiveException('备份包缺少 tables');
    }

    final checksum = json['checksum'];
    if (checksum is! String || checksum.isEmpty) {
      throw BackupArchiveException('备份包缺少 checksum');
    }

    return BackupSnapshot(
      formatVersion: json['formatVersion'] as int? ?? 0,
      appSchemaVersion: json['appSchemaVersion'] as int? ?? 0,
      exportedAt: DateTime.parse(exportedAtRaw).toUtc(),
      tables: BackupTableSnapshot.fromTablesJson(tablesRaw),
      checksum: checksum,
    );
  }
}

/// 备份包编解码失败。
final class BackupArchiveException implements Exception {
  BackupArchiveException(this.message);

  final String message;

  @override
  String toString() => message;
}
