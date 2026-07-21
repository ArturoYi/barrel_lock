import 'dart:typed_data';

import 'package:core/core.dart';

import '../../crypto/encrypted_name_codec.dart';
import '../../storage/storage_providers.dart';

/// 附件数量与大小限制（首版身份证件场景）。
abstract final class AttachmentLimits {
  static const maxFileSizeBytes = 5 * 1024 * 1024;
  static const maxCountPerCipher = 5;

  static const allowedMimeTypes = <String>{
    'image/jpeg',
    'image/png',
    'image/webp',
  };
}

/// 添加页待保存附件（内存态，尚未写入 DB）。
final class PendingAttachment {
  const PendingAttachment({
    required this.localId,
    required this.fileName,
    required this.mimeType,
    required this.bytes,
  });

  final String localId;
  final String fileName;
  final String mimeType;
  final Uint8List bytes;

  int get sizeBytes => bytes.length;
}

/// 附件元数据（不含文件 BLOB）。
final class AttachmentMetadata {
  const AttachmentMetadata({
    required this.id,
    required this.cipherUuid,
    required this.fileName,
    required this.fileSize,
    required this.createdAt,
  });

  final String id;
  final String cipherUuid;
  final String fileName;
  final int fileSize;
  final DateTime createdAt;
}

/// 附件校验或持久化失败。
final class AttachmentManageException implements Exception {
  AttachmentManageException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 附件写操作与按 cipher 查询（MVVM-C 的 M 层）。
final class AttachmentManageModel {
  AttachmentManageModel(this._repos);

  final StorageRepositories _repos;

  /// 监听指定 cipher 的附件元数据（不解密文件 BLOB）。
  Stream<List<AttachmentMetadata>> watchMetadataByCipher(String cipherUuid) {
    return _repos.cipherAttachments
        .watchByCipher(cipherUuid)
        .asyncMap(_mapMetadataList);
  }

  /// 插入单个附件，返回新 attach UUID。
  Future<String> insertAttachment({
    required String cipherUuid,
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    _validateMimeType(mimeType);
    _validateFileSize(bytes.length);

    final existing = await _repos.cipherAttachments.findByCipher(cipherUuid);
    if (existing.length >= AttachmentLimits.maxCountPerCipher) {
      throw AttachmentManageException(
        '每条密码最多 ${AttachmentLimits.maxCountPerCipher} 个附件',
      );
    }

    final trimmedName = fileName.trim();
    if (trimmedName.isEmpty) {
      throw AttachmentManageException('文件名不能为空');
    }

    final now = DateTime.now().toUtc();
    final attachUuid = AppIds.newUuid();
    final nameBlob = await EncryptedNameCodec.encrypt(trimmedName);
    final encryptedFile = await _encryptBytes(bytes);

    await _repos.cipherAttachments.insert(
      CipherAttachment(
        attachUuid: attachUuid,
        cipherUuid: cipherUuid,
        ownerAccountId: null,
        fileName: nameBlob,
        encryptedFile: encryptedFile,
        fileSize: bytes.length,
        syncRevision: now,
        createdAt: now,
      ),
    );

    return attachUuid;
  }

  /// 批量插入待保存附件。
  Future<void> insertAll({
    required String cipherUuid,
    required List<PendingAttachment> pending,
  }) async {
    if (pending.isEmpty) {
      return;
    }

    final existing = await _repos.cipherAttachments.findByCipher(cipherUuid);
    if (existing.length + pending.length > AttachmentLimits.maxCountPerCipher) {
      throw AttachmentManageException(
        '每条密码最多 ${AttachmentLimits.maxCountPerCipher} 个附件',
      );
    }

    for (final item in pending) {
      await insertAttachment(
        cipherUuid: cipherUuid,
        fileName: item.fileName,
        mimeType: item.mimeType,
        bytes: item.bytes,
      );
    }
  }

  /// 按需解密附件二进制。
  Future<Uint8List> loadDecryptedBytes(String attachUuid) async {
    final row = await _repos.cipherAttachments.findById(attachUuid);
    if (row == null) {
      throw AttachmentManageException('附件不存在');
    }
    final plain = await AppCrypto.decrypt(EncryptedPayload(row.encryptedFile));
    return Uint8List.fromList(plain);
  }

  /// 删除附件行。
  Future<void> deleteAttachment(String attachUuid) async {
    await _repos.cipherAttachments.delete(attachUuid);
  }

  static void validatePendingAttachment({
    required String mimeType,
    required int sizeBytes,
    required int currentPendingCount,
  }) {
    _validateMimeType(mimeType);
    _validateFileSize(sizeBytes);
    if (currentPendingCount >= AttachmentLimits.maxCountPerCipher) {
      throw AttachmentManageException(
        '每条密码最多 ${AttachmentLimits.maxCountPerCipher} 个附件',
      );
    }
  }

  static void _validateMimeType(String mimeType) {
    if (!AttachmentLimits.allowedMimeTypes.contains(mimeType)) {
      throw AttachmentManageException('仅支持 JPEG、PNG、WebP 图片');
    }
  }

  static void _validateFileSize(int sizeBytes) {
    if (sizeBytes <= 0) {
      throw AttachmentManageException('文件不能为空');
    }
    if (sizeBytes > AttachmentLimits.maxFileSizeBytes) {
      throw AttachmentManageException('单个附件不能超过 5MB');
    }
  }

  Future<List<AttachmentMetadata>> _mapMetadataList(
    List<CipherAttachment> rows,
  ) async {
    final metadata = <AttachmentMetadata>[];
    for (final row in rows) {
      metadata.add(await _mapMetadata(row));
    }
    metadata.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return metadata;
  }

  Future<AttachmentMetadata> _mapMetadata(CipherAttachment row) async {
    final name = await EncryptedNameCodec.decryptOrFallback(
      Uint8List.fromList(row.fileName),
    );
    return AttachmentMetadata(
      id: row.attachUuid,
      cipherUuid: row.cipherUuid,
      fileName: name.isEmpty ? '未命名附件' : name,
      fileSize: row.fileSize,
      createdAt: row.createdAt,
    );
  }

  Future<Uint8List> _encryptBytes(Uint8List bytes) async {
    final payload = await AppCrypto.encrypt(bytes);
    return Uint8List.fromList(payload.bytes);
  }
}

final attachmentManageModelProvider = Provider<AttachmentManageModel>((ref) {
  return AttachmentManageModel(ref.watch(storageRepositoriesProvider));
});
