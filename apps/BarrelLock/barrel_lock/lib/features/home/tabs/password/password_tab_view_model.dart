import 'package:core/core.dart';

import 'password_tab_coordinator.dart';
import 'password_tab_model.dart';

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

  VaultSummary get selectedVault =>
      vaults.firstWhere((vault) => vault.id == selectedVaultId);

  bool isFolderCollapsed(String folderId) =>
      collapsedFolderIds.contains(folderId);

  int get totalItemCount =>
      folderGroups.fold<int>(0, (sum, group) => sum + group.items.length);
}

/// 首页「密码」Tab 状态与业务编排（MVVM-C 的 VM 层）。
final class PasswordTabViewModel extends Notifier<PasswordTabViewState> {
  late final PasswordTabModel _model;
  late final PasswordTabCoordinator _coordinator;

  @override
  PasswordTabViewState build() {
    _model = ref.read(passwordTabModelProvider);
    _coordinator = ref.read(passwordTabCoordinatorProvider);
    final selectedVaultId = _model.vaults.first.id;
    return _buildState(
      selectedVaultId: selectedVaultId,
      quickFilter: VaultQuickFilter.all,
      searchQuery: '',
      collapsedFolderIds: const {},
    );
  }

  PasswordTabViewState _buildState({
    required String selectedVaultId,
    required VaultQuickFilter quickFilter,
    required String searchQuery,
    required Set<String> collapsedFolderIds,
  }) {
    return PasswordTabViewState(
      title: '密码',
      vaults: _model.vaults,
      selectedVaultId: selectedVaultId,
      quickFilter: quickFilter,
      searchQuery: searchQuery,
      folderGroups: _model.buildFolderGroups(
        vaultId: selectedVaultId,
        filter: quickFilter,
        searchQuery: searchQuery,
      ),
      collapsedFolderIds: collapsedFolderIds,
    );
  }

  void onSearchChanged(String query) {
    state = _buildState(
      selectedVaultId: state.selectedVaultId,
      quickFilter: state.quickFilter,
      searchQuery: query,
      collapsedFolderIds: state.collapsedFolderIds,
    );
  }

  void onQuickFilterSelected(VaultQuickFilter filter) {
    if (filter == state.quickFilter) {
      return;
    }
    state = _buildState(
      selectedVaultId: state.selectedVaultId,
      quickFilter: filter,
      searchQuery: state.searchQuery,
      collapsedFolderIds: state.collapsedFolderIds,
    );
  }

  void onVaultSelected(String vaultId) {
    if (vaultId == state.selectedVaultId) {
      return;
    }
    state = _buildState(
      selectedVaultId: vaultId,
      quickFilter: state.quickFilter,
      searchQuery: state.searchQuery,
      collapsedFolderIds: const {},
    );
  }

  void onFolderCollapseToggled(String folderId) {
    final collapsed = Set<String>.from(state.collapsedFolderIds);
    if (collapsed.contains(folderId)) {
      collapsed.remove(folderId);
    } else {
      collapsed.add(folderId);
    }
    state = _buildState(
      selectedVaultId: state.selectedVaultId,
      quickFilter: state.quickFilter,
      searchQuery: state.searchQuery,
      collapsedFolderIds: collapsed,
    );
  }

  void onFavoriteToggled(String cipherId) {
    _model.toggleFavorite(cipherId);
    state = _buildState(
      selectedVaultId: state.selectedVaultId,
      quickFilter: state.quickFilter,
      searchQuery: state.searchQuery,
      collapsedFolderIds: state.collapsedFolderIds,
    );
  }

  void onCipherTapped(String cipherId) {
    _coordinator.openCipherDetail(cipherId);
  }
}

final passwordTabViewModelProvider =
    NotifierProvider<PasswordTabViewModel, PasswordTabViewState>(
      PasswordTabViewModel.new,
    );
