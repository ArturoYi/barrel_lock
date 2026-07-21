import 'dart:async';

import 'package:core/core.dart';

import 'password_tab_coordinator.dart';
import 'password_tab_model.dart';
import '../../../vault_manage/vault_manage_model.dart';

/// 首页「密码」Tab 展示状态。
final class PasswordTabViewState {
  const PasswordTabViewState({
    required this.title,
    required this.vaults,
    required this.selectedVaultId,
    required this.quickFilter,
    required this.searchQuery,
    required this.folderGroups,
    required this.collapsedFolderIds,
  });

  final String title;
  final List<VaultSummary> vaults;
  final String selectedVaultId;
  final VaultQuickFilter quickFilter;
  final String searchQuery;
  final List<VaultFolderGroup> folderGroups;
  final Set<String> collapsedFolderIds;

  bool get hasVaults => vaults.isNotEmpty;

  VaultSummary? get selectedVault {
    if (vaults.isEmpty) {
      return null;
    }
    for (final vault in vaults) {
      if (vault.id == selectedVaultId) {
        return vault;
      }
    }
    return vaults.first;
  }

  bool isFolderCollapsed(String folderId) =>
      collapsedFolderIds.contains(folderId);

  int get totalItemCount =>
      folderGroups.fold<int>(0, (sum, group) => sum + group.items.length);
}

/// 首页「密码」Tab 状态与业务编排（MVVM-C 的 VM 层）。
final class PasswordTabViewModel extends AsyncNotifier<PasswordTabViewState> {
  VaultQuickFilter _quickFilter = VaultQuickFilter.all;
  String _searchQuery = '';
  Set<String> _collapsedFolderIds = {};
  String? _selectedVaultId;

  StreamSubscription<void>? _dataSubscription;
  var _isBuilding = false;

  PasswordTabCoordinator get _coordinator =>
      ref.read(passwordTabCoordinatorProvider);

  @override
  Future<PasswordTabViewState> build() async {
    _isBuilding = true;
    try {
      final model = ref.watch(passwordTabModelProvider);

      await _dataSubscription?.cancel();
      _dataSubscription = model.watchDataChanges(_selectedVaultId).listen((_) {
        unawaited(_reloadFromDatabase());
      });
      ref.onDispose(() => _dataSubscription?.cancel());

      return _composeState(model);
    } finally {
      _isBuilding = false;
    }
  }

  Future<void> _reloadFromDatabase() async {
    if (_isBuilding || !ref.mounted) {
      return;
    }
    final model = ref.read(passwordTabModelProvider);
    final previousVaultId = _selectedVaultId;
    final nextState = await _composeState(model);
    if (_selectedVaultId != previousVaultId) {
      ref.invalidateSelf();
      return;
    }
    state = AsyncData(nextState);
  }

  Future<PasswordTabViewState> _composeState(PasswordTabModel model) async {
    final data = await model.loadVaultData(selectedVaultId: _selectedVaultId);

    if (data.vaults.isNotEmpty) {
      _selectedVaultId ??= data.vaults.first.id;
      if (!data.vaults.any((vault) => vault.id == _selectedVaultId)) {
        _selectedVaultId = data.vaults.first.id;
        _collapsedFolderIds = {};
      }
    } else {
      _selectedVaultId = null;
    }

    final effectiveVaultId = _selectedVaultId ?? '';
    final folderGroups = data.vaults.isEmpty
        ? const <VaultFolderGroup>[]
        : model.buildFolderGroups(
            ciphers: data.ciphers,
            folderNames: data.folderNames,
            filter: _quickFilter,
            searchQuery: _searchQuery,
          );

    return PasswordTabViewState(
      title: '密码',
      vaults: data.vaults,
      selectedVaultId: effectiveVaultId,
      quickFilter: _quickFilter,
      searchQuery: _searchQuery,
      folderGroups: folderGroups,
      collapsedFolderIds: _collapsedFolderIds,
    );
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    ref.invalidateSelf();
  }

  void onQuickFilterSelected(VaultQuickFilter filter) {
    if (filter == _quickFilter) {
      return;
    }
    _quickFilter = filter;
    ref.invalidateSelf();
  }

  void onVaultSelected(String vaultId) {
    if (vaultId == _selectedVaultId) {
      return;
    }
    _selectedVaultId = vaultId;
    _collapsedFolderIds = {};
    ref.invalidateSelf();
  }

  void onFolderCollapseToggled(String folderId) {
    final collapsed = Set<String>.from(_collapsedFolderIds);
    if (collapsed.contains(folderId)) {
      collapsed.remove(folderId);
    } else {
      collapsed.add(folderId);
    }
    _collapsedFolderIds = collapsed;
    ref.invalidateSelf();
  }

  Future<void> onFavoriteToggled(String cipherId) async {
    final model = ref.read(passwordTabModelProvider);
    await model.toggleFavorite(cipherId);
  }

  void onCipherTapped(String cipherId) {
    _coordinator.openCipherDetail(cipherId);
  }

  void onAddPasswordTapped() {
    final vaultId = _selectedVaultId;
    _coordinator.openAddPassword(
      vaultId: vaultId != null && vaultId.isNotEmpty ? vaultId : null,
    );
  }

  Future<String?> createVault(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final vaultManage = ref.read(vaultManageModelProvider);
    final vaultId = await vaultManage.createVault(name: trimmed);
    _selectedVaultId = vaultId;
    _collapsedFolderIds = {};
    ref.invalidateSelf();
    return vaultId;
  }
}

final passwordTabViewModelProvider =
    AsyncNotifierProvider<PasswordTabViewModel, PasswordTabViewState>(
      PasswordTabViewModel.new,
    );
