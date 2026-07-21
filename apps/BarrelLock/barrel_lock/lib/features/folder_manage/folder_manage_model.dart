import 'dart:typed_data';

import 'package:core/core.dart';

import '../../crypto/encrypted_name_codec.dart';
import '../../storage/storage_providers.dart';

/// 文件夹展示层 DTO（已解密名称）。
final class FolderSummary {
  const FolderSummary({required this.id, required this.name});

  final String id;
  final String name;
}

/// 文件夹写操作与按 vault 查询（MVVM-C 的 M 层）。
final class FolderManageModel {
  FolderManageModel(this._repos);

  final StorageRepositories _repos;

  /// 监听指定保险库下未回收的文件夹（名称已解密）。
  Stream<List<FolderSummary>> watchSummariesByVault(String vaultUuid) {
    return _repos.folders.watchByVault(vaultUuid).asyncMap(_mapSummaries);
  }

  /// 创建文件夹，返回新 folder UUID。
  Future<String> createFolder({
    required String vaultUuid,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Folder name must not be empty');
    }

    final now = DateTime.now().toUtc();
    final folderUuid = AppIds.newUuid();
    final nameBlob = await EncryptedNameCodec.encrypt(trimmed);

    await _repos.folders.insert(
      Folder(
        folderUuid: folderUuid,
        vaultUuid: vaultUuid,
        name: nameBlob,
        isTrashed: false,
        syncRevision: now,
        localModified: true,
        createdAt: now,
        updatedAt: now,
        ownerAccountId: null,
      ),
    );

    return folderUuid;
  }

  Future<List<FolderSummary>> _mapSummaries(List<Folder> rows) async {
    final summaries = <FolderSummary>[];
    for (final row in rows) {
      final name = await EncryptedNameCodec.decryptOrFallback(
        Uint8List.fromList(row.name),
      );
      if (name.isEmpty) {
        continue;
      }
      summaries.add(FolderSummary(id: row.folderUuid, name: name));
    }
    summaries.sort((a, b) => a.name.compareTo(b.name));
    return summaries;
  }
}

final folderManageModelProvider = Provider<FolderManageModel>((ref) {
  return FolderManageModel(ref.watch(storageRepositoriesProvider));
});
