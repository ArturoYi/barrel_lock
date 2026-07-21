import 'package:core/core.dart';

import '../../storage/storage_providers.dart';

/// 清除数据流程步骤。
enum ClearDataStep { idle, confirm1, confirm2, clearing, done }

/// 清除数据页业务数据（MVVM-C 的 M 层）。
final class ClearDataModel {
  ClearDataModel(this._repos);

  final StorageRepositories _repos;

  /// 删除全部密码相关表（与备份 replace 模式相同顺序）。
  Future<void> wipeAllPasswords() async {
    await _repos.runInTransaction(() async {
      await _repos.cipherAttachments.deleteAll();
      await _repos.cipherEntries.deleteAll();
      await _repos.folders.deleteAll();
      await _repos.vaults.deleteAll();
    });
  }
}

final clearDataModelProvider = Provider<ClearDataModel>((ref) {
  return ClearDataModel(ref.watch(storageRepositoriesProvider));
});
