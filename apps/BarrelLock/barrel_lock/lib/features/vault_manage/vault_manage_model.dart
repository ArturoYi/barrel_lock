import 'package:core/core.dart';

import '../../crypto/encrypted_name_codec.dart';
import '../../storage/storage_providers.dart';

/// 保险库写操作（MVVM-C 的 M 层）。
final class VaultManageModel {
  VaultManageModel(this._repos);

  final StorageRepositories _repos;

  /// 创建 active 保险库，返回新 vault UUID。
  Future<String> createVault({
    required String name,
    String iconName = 'person',
    String? colorHex,
    bool isPersonal = true,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Vault name must not be empty');
    }

    final now = DateTime.now().toUtc();
    final vaultUuid = AppIds.newUuid();
    final nameBlob = await EncryptedNameCodec.encrypt(trimmed);

    await _repos.vaults.insert(
      Vault(
        vaultUuid: vaultUuid,
        name: nameBlob,
        iconName: iconName,
        colorHex: colorHex,
        isPersonal: isPersonal,
        isTrashed: false,
        syncRevision: now,
        localModified: true,
        createdAt: now,
        updatedAt: now,
        ownerAccountId: null,
      ),
    );

    return vaultUuid;
  }

  /// 首个 active 保险库 ID；无库时返回 null。
  Future<String?> firstActiveVaultId() async {
    final activeVaults = await _repos.vaults.watchActive().first;
    if (activeVaults.isEmpty) {
      return null;
    }
    return activeVaults.first.vaultUuid;
  }
}

final vaultManageModelProvider = Provider<VaultManageModel>((ref) {
  return VaultManageModel(ref.watch(storageRepositoriesProvider));
});
