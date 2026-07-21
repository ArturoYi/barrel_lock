import 'dart:async';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../../../crypto/cipher_overview_codec.dart';
import '../../../../crypto/encrypted_name_codec.dart';
import '../../../../storage/storage_providers.dart';

/// 快捷筛选：全部 / 收藏 / 最近使用。
enum VaultQuickFilter {
  all,
  favorites,
  recent;

  String get label => switch (this) {
    VaultQuickFilter.all => '全部',
    VaultQuickFilter.favorites => '收藏',
    VaultQuickFilter.recent => '最近使用',
  };

  IconData get icon => switch (this) {
    VaultQuickFilter.all => Icons.grid_view_rounded,
    VaultQuickFilter.favorites => Icons.star_rounded,
    VaultQuickFilter.recent => Icons.history_rounded,
  };
}

/// 保险库概览（展示层使用已解密的明文名称）。
final class VaultSummary {
  const VaultSummary({
    required this.id,
    required this.name,
    this.iconName,
    this.colorHex,
  });

  final String id;
  final String name;
  final String? iconName;
  final String? colorHex;
}

/// 密码条目概览卡片数据（仅 overview，不含完整密码）。
final class CipherOverviewItem {
  const CipherOverviewItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.vaultId,
    this.folderId,
    this.host,
    this.isFavorite = false,
    this.hasTotp = false,
    this.lastUsedAt,
  });

  final String id;
  final String title;
  final String subtitle;
  final String vaultId;
  final String? folderId;
  final String? host;
  final bool isFavorite;
  final bool hasTotp;
  final DateTime? lastUsedAt;
}

/// 按文件夹分组的密码列表。
final class VaultFolderGroup {
  const VaultFolderGroup({
    required this.id,
    required this.name,
    required this.items,
  });

  final String id;
  final String name;
  final List<CipherOverviewItem> items;
}

/// 密码 Tab 单次加载的快照（vault 列表 + 当前库条目与文件夹名）。
final class PasswordTabVaultData {
  const PasswordTabVaultData({
    required this.vaults,
    required this.ciphers,
    required this.folderNames,
  });

  final List<VaultSummary> vaults;
  final List<CipherOverviewItem> ciphers;
  final Map<String, String> folderNames;
}

/// 首页「密码」Tab 业务数据（MVVM-C 的 M 层）。
///
/// 从 [StorageRepositories] 读取 Drift 数据，解密 overview / 名称 BLOB 后供 ViewModel 分组展示。
final class PasswordTabModel {
  PasswordTabModel(this._repos);

  static const uncategorizedFolderId = '__uncategorized__';

  final StorageRepositories _repos;

  /// 加载 vault 列表与指定保险库的 cipher / folder 解密数据。
  ///
  /// [selectedVaultId] 为空时，若存在 active vault 则默认加载首个 vault 的条目。
  Future<PasswordTabVaultData> loadVaultData({String? selectedVaultId}) async {
    final vaultRows = await _repos.vaults.watchActive().first;
    final vaults = await _mapVaultSummaries(vaultRows);

    final resolvedVaultId =
        selectedVaultId != null && selectedVaultId.isNotEmpty
        ? selectedVaultId
        : (vaults.isNotEmpty ? vaults.first.id : null);

    if (resolvedVaultId == null) {
      return PasswordTabVaultData(
        vaults: vaults,
        ciphers: const [],
        folderNames: const {},
      );
    }

    final cipherRows = await _repos.cipherEntries
        .watchByVault(resolvedVaultId)
        .first;
    final folderRows = await _repos.folders.watchByVault(resolvedVaultId).first;

    final ciphers = await _mapCipherOverviews(cipherRows);
    final folderNames = await _mapFolderNames(folderRows);

    return PasswordTabVaultData(
      vaults: vaults,
      ciphers: ciphers,
      folderNames: folderNames,
    );
  }

  /// 当 vault / folder / cipher 表变更时发出通知，供 ViewModel 刷新。
  Stream<void> watchDataChanges(String? vaultId) {
    late StreamSubscription<dynamic> vaultSub;
    late StreamSubscription<dynamic> cipherSub;
    StreamSubscription<dynamic>? folderSub;
    late StreamController<void> controller;

    void emit() {
      if (!controller.isClosed) {
        controller.add(null);
      }
    }

    controller = StreamController<void>(
      onListen: () {
        vaultSub = _repos.vaults.watchActive().listen((_) => emit());
        cipherSub = _repos.cipherEntries.watchAll().listen((_) => emit());
        if (vaultId != null && vaultId.isNotEmpty) {
          folderSub = _repos.folders
              .watchByVault(vaultId)
              .listen((_) => emit());
        }
      },
      onCancel: () async {
        await vaultSub.cancel();
        await cipherSub.cancel();
        await folderSub?.cancel();
      },
    );

    return controller.stream;
  }

  Future<void> toggleFavorite(String cipherId) async {
    final entry = await _repos.cipherEntries.findById(cipherId);
    if (entry == null) {
      return;
    }
    await _repos.cipherEntries.setFavorite(cipherId, !entry.isFavorite);
  }

  List<VaultFolderGroup> buildFolderGroups({
    required List<CipherOverviewItem> ciphers,
    required Map<String, String> folderNames,
    required VaultQuickFilter filter,
    required String searchQuery,
  }) {
    var items = [...ciphers];

    items = switch (filter) {
      VaultQuickFilter.all => items,
      VaultQuickFilter.favorites =>
        items.where((item) => item.isFavorite).toList(),
      VaultQuickFilter.recent => () {
        final sorted = [...items]
          ..sort((a, b) {
            final aTime =
                a.lastUsedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime =
                b.lastUsedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });
        return sorted;
      }(),
    };

    final query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      items = items
          .where(
            (item) =>
                item.title.toLowerCase().contains(query) ||
                item.subtitle.toLowerCase().contains(query) ||
                (item.host?.toLowerCase().contains(query) ?? false),
          )
          .toList(growable: false);
    }

    final grouped = <String, List<CipherOverviewItem>>{};
    for (final item in items) {
      final key = item.folderId ?? uncategorizedFolderId;
      grouped.putIfAbsent(key, () => []).add(item);
    }

    final groups = <VaultFolderGroup>[];
    for (final entry in grouped.entries) {
      final name = entry.key == uncategorizedFolderId
          ? '未分组'
          : (folderNames[entry.key]?.isNotEmpty == true
                ? folderNames[entry.key]!
                : '其他');
      groups.add(
        VaultFolderGroup(id: entry.key, name: name, items: entry.value),
      );
    }

    groups.sort((a, b) {
      if (a.id == uncategorizedFolderId) {
        return 1;
      }
      if (b.id == uncategorizedFolderId) {
        return -1;
      }
      return a.name.compareTo(b.name);
    });

    return groups;
  }

  Future<List<VaultSummary>> _mapVaultSummaries(List<Vault> rows) async {
    final summaries = <VaultSummary>[];
    for (final row in rows) {
      final name = await EncryptedNameCodec.decryptOrFallback(
        Uint8List.fromList(row.name),
      );
      summaries.add(
        VaultSummary(
          id: row.vaultUuid,
          name: name.isEmpty ? '未命名保险库' : name,
          iconName: row.iconName,
          colorHex: row.colorHex,
        ),
      );
    }
    summaries.sort((a, b) => a.name.compareTo(b.name));
    return summaries;
  }

  Future<Map<String, String>> _mapFolderNames(List<Folder> rows) async {
    final names = <String, String>{};
    for (final row in rows) {
      final name = await EncryptedNameCodec.decryptOrFallback(
        Uint8List.fromList(row.name),
      );
      if (name.isNotEmpty) {
        names[row.folderUuid] = name;
      }
    }
    return names;
  }

  Future<List<CipherOverviewItem>> _mapCipherOverviews(
    List<CipherEntry> rows,
  ) async {
    final items = <CipherOverviewItem>[];
    for (final row in rows) {
      final overview = await CipherOverviewCodec.decryptOrFallback(
        Uint8List.fromList(row.overviewBlob),
      );
      items.add(
        CipherOverviewItem(
          id: row.cipherUuid,
          title: overview.title,
          subtitle: overview.subtitle,
          vaultId: row.vaultUuid,
          folderId: row.folderUuid,
          host: overview.host,
          isFavorite: row.isFavorite,
          hasTotp: overview.hasTotp,
          lastUsedAt: row.updatedAt,
        ),
      );
    }
    return items;
  }
}

final passwordTabModelProvider = Provider<PasswordTabModel>((ref) {
  return PasswordTabModel(ref.watch(storageRepositoriesProvider));
});
