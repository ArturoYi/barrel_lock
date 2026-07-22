import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:core/core.dart';

import '../../storage/storage_providers.dart';
import 'backup_archive_codec.dart';
import 'backup_snapshot.dart';

/// 导入模式：合并 upsert 或全量替换。
enum BackupImportMode { merge, replace }

/// 本地备份元数据（不含文件内容）。
final class BackupLogSummary {
  const BackupLogSummary({
    required this.logId,
    required this.backupTime,
    required this.backupPath,
    required this.note,
  });

  final String logId;
  final DateTime backupTime;
  final String? backupPath;
  final String? note;
}

/// 本地备份创建结果。
final class LocalBackupResult {
  const LocalBackupResult({required this.logId, required this.filePath});

  final String logId;
  final String filePath;
}

/// 备份管理失败。
final class BackupManageException implements Exception {
  BackupManageException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 备份快照、本地文件与恢复（MVVM-C 的 M 层）。
final class BackupManageModel {
  BackupManageModel(
    this._repos, {
    Directory? backupRootOverride,
    int maxLocalBackups = 5,
  }) : _backupRootOverride = backupRootOverride,
       _maxLocalBackups = maxLocalBackups;

  final StorageRepositories _repos;
  final Directory? _backupRootOverride;
  final int _maxLocalBackups;

  /// 聚合四表密文快照并编码为 `.blbak` 字节。
  Future<Uint8List> createSnapshotBytes({DateTime? exportedAt}) async {
    final tables = await _loadTables();
    final snapshot = BackupArchiveCodec.snapshotFromTables(
      tables,
      exportedAt: exportedAt ?? DateTime.now().toUtc(),
    );
    return BackupArchiveCodec.encode(snapshot);
  }

  /// 写入应用内本地备份并记录 `backup_log`。
  Future<LocalBackupResult> createLocalBackup({String? note}) async {
    final logId = AppIds.newUuid();
    final now = DateTime.now().toUtc();
    final bytes = await createSnapshotBytes(exportedAt: now);
    final directory = await _backupDirectory();
    final filePath =
        '${directory.path}/$logId.${BackupArchiveCodec.fileExtension}';
    await File(filePath).writeAsBytes(bytes, flush: true);

    await _repos.backupLogs.insert(
      BackupLog(
        logId: logId,
        backupTime: now,
        backupPath: filePath,
        backupPasswordSalt: _randomSalt(),
        vaultVersion: DatabaseSchemaVersion.current,
        isEncrypted: true,
        note: note,
        createdAt: now,
      ),
    );

    await pruneOldBackups(maxCount: _maxLocalBackups);

    return LocalBackupResult(logId: logId, filePath: filePath);
  }

  Stream<List<BackupLogSummary>> watchRecentBackups() {
    return _repos.backupLogs.watchAll().map((rows) {
      final sorted = [...rows]..sort(_compareBackupLogs);
      return sorted
          .map(
            (row) => BackupLogSummary(
              logId: row.logId,
              backupTime: row.backupTime,
              backupPath: row.backupPath,
              note: row.note,
            ),
          )
          .toList(growable: false);
    });
  }

  Future<void> restoreFromBytes(
    Uint8List bytes, {
    required BackupImportMode mode,
  }) async {
    final snapshot = await BackupArchiveCodec.decode(bytes);
    await _applySnapshot(snapshot.tables, mode: mode);
  }

  Future<void> restoreFromLocalBackup(
    String logId, {
    required BackupImportMode mode,
  }) async {
    final row = await _repos.backupLogs.findById(logId);
    if (row == null) {
      throw BackupManageException('找不到备份记录');
    }
    final path = row.backupPath;
    if (path == null || path.isEmpty) {
      throw BackupManageException('备份文件路径无效');
    }
    final file = File(path);
    if (!await file.exists()) {
      throw BackupManageException('备份文件不存在');
    }
    final bytes = await file.readAsBytes();
    await restoreFromBytes(bytes, mode: mode);
  }

  Future<void> pruneOldBackups({required int maxCount}) async {
    if (maxCount <= 0) {
      return;
    }

    final rows = await _repos.backupLogs.findAll();
    if (rows.length <= maxCount) {
      return;
    }

    rows.sort((a, b) {
      final byTime = a.backupTime.compareTo(b.backupTime);
      if (byTime != 0) {
        return byTime;
      }
      return a.createdAt.compareTo(b.createdAt);
    });

    final deleteCount = rows.length - maxCount;
    for (final row in rows.take(deleteCount)) {
      final path = row.backupPath;
      if (path != null && path.isNotEmpty) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
      await _repos.backupLogs.delete(row.logId);
    }
  }

  Future<BackupTableSnapshot> _loadTables() async {
    return BackupTableSnapshot(
      vaults: await _repos.vaults.findAll(),
      folders: await _repos.folders.findAll(),
      ciphers: await _repos.cipherEntries.findAll(),
      attachments: await _repos.cipherAttachments.findAll(),
    );
  }

  Future<void> _applySnapshot(
    BackupTableSnapshot tables, {
    required BackupImportMode mode,
  }) async {
    await _repos.runInTransaction(() async {
      if (mode == BackupImportMode.replace) {
        await _repos.cipherAttachments.deleteAll();
        await _repos.cipherEntries.deleteAll();
        await _repos.folders.deleteAll();
        await _repos.vaults.deleteAll();
      }

      await _upsertAll(tables, mergeOnly: mode == BackupImportMode.merge);
    });
  }

  Future<void> _upsertAll(
    BackupTableSnapshot tables, {
    required bool mergeOnly,
  }) async {
    for (final row in tables.vaults) {
      await _upsertRow(_repos.vaults, row.vaultUuid, row, mergeOnly);
    }
    for (final row in tables.folders) {
      await _upsertRow(_repos.folders, row.folderUuid, row, mergeOnly);
    }
    for (final row in tables.ciphers) {
      await _upsertRow(_repos.cipherEntries, row.cipherUuid, row, mergeOnly);
    }
    for (final row in tables.attachments) {
      await _upsertRow(
        _repos.cipherAttachments,
        row.attachUuid,
        row,
        mergeOnly,
      );
    }
  }

  Future<void> _upsertRow<T>(
    CrudRepository<T, String> repo,
    String id,
    T row,
    bool mergeOnly,
  ) async {
    if (mergeOnly) {
      final existing = await repo.findById(id);
      if (existing != null) {
        await repo.update(row);
        return;
      }
    }
    await repo.insert(row);
  }

  Future<Directory> _backupDirectory() async {
    final override = _backupRootOverride;
    if (override != null) {
      if (!await override.exists()) {
        await override.create(recursive: true);
      }
      return override;
    }

    final docs = await getApplicationDocumentsDirectory();
    final directory = Directory('${docs.path}/backups');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  Uint8List _randomSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
  }

  static int _compareBackupLogs(BackupLog a, BackupLog b) {
    final byTime = b.backupTime.compareTo(a.backupTime);
    if (byTime != 0) {
      return byTime;
    }
    return b.createdAt.compareTo(a.createdAt);
  }
}

final backupManageModelProvider = Provider<BackupManageModel>((ref) {
  return BackupManageModel(ref.watch(storageRepositoriesProvider));
});
