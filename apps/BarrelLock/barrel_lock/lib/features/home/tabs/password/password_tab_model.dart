import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// 快捷筛选：全部 / 收藏 / 最近使用 / TOTP。
enum VaultQuickFilter {
  all,
  favorites,
  recent,
  totp;

  String get label => switch (this) {
    VaultQuickFilter.all => '全部',
    VaultQuickFilter.favorites => '收藏',
    VaultQuickFilter.recent => '最近使用',
    VaultQuickFilter.totp => 'TOTP 验证码',
  };

  IconData get icon => switch (this) {
    VaultQuickFilter.all => Icons.grid_view_rounded,
    VaultQuickFilter.favorites => Icons.star_rounded,
    VaultQuickFilter.recent => Icons.history_rounded,
    VaultQuickFilter.totp => Icons.pin_rounded,
  };
}

/// 保险库概览（不解密名称 blob，展示层使用已解析的明文）。
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

  CipherOverviewItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? vaultId,
    String? folderId,
    String? host,
    bool? isFavorite,
    bool? hasTotp,
    DateTime? lastUsedAt,
  }) {
    return CipherOverviewItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      vaultId: vaultId ?? this.vaultId,
      folderId: folderId ?? this.folderId,
      host: host ?? this.host,
      isFavorite: isFavorite ?? this.isFavorite,
      hasTotp: hasTotp ?? this.hasTotp,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }
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

/// 首页「密码」Tab 业务数据（MVVM-C 的 M 层）。
///
/// 当前使用内存 mock；后续接入 [StorageRepositories] 与 overview 解密。
final class PasswordTabModel {
  PasswordTabModel() : _ciphers = _seedCiphers();

  static const uncategorizedFolderId = '__uncategorized__';

  final List<VaultSummary> vaults = const [
    VaultSummary(id: 'vault-personal', name: '个人库', iconName: 'person'),
    VaultSummary(id: 'vault-work', name: '工作库', iconName: 'work'),
  ];

  List<CipherOverviewItem> _ciphers;

  List<CipherOverviewItem> ciphersForVault(String vaultId) {
    return _ciphers
        .where((item) => item.vaultId == vaultId)
        .toList(growable: false);
  }

  void toggleFavorite(String cipherId) {
    _ciphers = [
      for (final item in _ciphers)
        if (item.id == cipherId)
          item.copyWith(isFavorite: !item.isFavorite)
        else
          item,
    ];
  }

  List<VaultFolderGroup> buildFolderGroups({
    required String vaultId,
    required VaultQuickFilter filter,
    required String searchQuery,
  }) {
    var items = ciphersForVault(vaultId);

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
      VaultQuickFilter.totp => items.where((item) => item.hasTotp).toList(),
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

    final folderNames = <String, String>{
      'folder-social': '社交账号',
      'folder-finance': '金融',
      uncategorizedFolderId: '未分组',
    };

    final groups = <VaultFolderGroup>[];
    for (final entry in grouped.entries) {
      groups.add(
        VaultFolderGroup(
          id: entry.key,
          name: folderNames[entry.key] ?? '其他',
          items: entry.value,
        ),
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

  static List<CipherOverviewItem> _seedCiphers() {
    final now = DateTime.now();
    return [
      CipherOverviewItem(
        id: 'cipher-github',
        title: 'GitHub',
        subtitle: 'cyr@example.com',
        vaultId: 'vault-personal',
        folderId: 'folder-social',
        host: 'github.com',
        isFavorite: true,
        hasTotp: true,
        lastUsedAt: now.subtract(const Duration(hours: 2)),
      ),
      CipherOverviewItem(
        id: 'cipher-twitter',
        title: 'X (Twitter)',
        subtitle: '@cyr_dev',
        vaultId: 'vault-personal',
        folderId: 'folder-social',
        host: 'x.com',
        lastUsedAt: now.subtract(const Duration(days: 1)),
      ),
      CipherOverviewItem(
        id: 'cipher-visa',
        title: '招商银行 Visa',
        subtitle: '尾号 4826',
        vaultId: 'vault-personal',
        folderId: 'folder-finance',
        host: 'cmbchina.com',
        isFavorite: true,
        lastUsedAt: now.subtract(const Duration(days: 3)),
      ),
      CipherOverviewItem(
        id: 'cipher-alipay',
        title: '支付宝',
        subtitle: '138****5678',
        vaultId: 'vault-personal',
        folderId: 'folder-finance',
        host: 'alipay.com',
        hasTotp: true,
        lastUsedAt: now.subtract(const Duration(hours: 6)),
      ),
      CipherOverviewItem(
        id: 'cipher-wifi',
        title: '家庭 Wi-Fi',
        subtitle: '客厅路由器',
        vaultId: 'vault-personal',
        lastUsedAt: now.subtract(const Duration(days: 14)),
      ),
      CipherOverviewItem(
        id: 'cipher-jira',
        title: 'Jira',
        subtitle: 'cyr@company.com',
        vaultId: 'vault-work',
        folderId: 'folder-social',
        host: 'company.atlassian.net',
        hasTotp: true,
        lastUsedAt: now.subtract(const Duration(hours: 1)),
      ),
      CipherOverviewItem(
        id: 'cipher-vpn',
        title: '公司 VPN',
        subtitle: 'cyr.wang',
        vaultId: 'vault-work',
        isFavorite: true,
        lastUsedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}

final passwordTabModelProvider = Provider<PasswordTabModel>(
  (_) => PasswordTabModel(),
);
