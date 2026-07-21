import '../app_database.dart';
import '../app_storage.dart';
import 'backup_log_repository.dart';
import 'cipher_attachment_repository.dart';
import 'cipher_entry_repository.dart';
import 'folder_repository.dart';
import 'vault_repository.dart';

/// 存储层聚合入口：共享单一 [AppDatabase] 连接，向业务层暴露各表仓储。
///
/// ```dart
/// final repos = StorageRepositories.defaults();
/// await repos.vaults.insert(vault);
/// repos.cipherEntries.watchAll().listen(...);
/// ```
///
/// 测试时可注入内存库，无需经过 [AppStorage] 单例：
///
/// ```dart
/// final db = AppDatabase.memory();
/// final repos = StorageRepositories(db);
/// ```
final class StorageRepositories {
  StorageRepositories(this.database)
    : vaults = VaultRepository(database),
      folders = FolderRepository(database),
      cipherEntries = CipherEntryRepository(database),
      cipherAttachments = CipherAttachmentRepository(database),
      backupLogs = BackupLogRepository(database);

  /// 使用 [AppStorage.database] 的便捷构造，供 App 运行时默认装配。
  StorageRepositories.defaults() : this(AppStorage.database);

  final AppDatabase database;

  final VaultRepository vaults;
  final FolderRepository folders;
  final CipherEntryRepository cipherEntries;
  final CipherAttachmentRepository cipherAttachments;
  final BackupLogRepository backupLogs;

  /// 在单事务中执行备份恢复等批量写操作。
  Future<T> runInTransaction<T>(Future<T> Function() action) {
    return database.transaction(action);
  }
}
