import 'dart:async';

import 'package:core/core.dart';

import '../folder_manage/folder_manage_model.dart';
import '../vault_manage/vault_manage_model.dart';
import 'cipher_add_providers.dart';

/// 添加页文件夹选择态（与表单 state 分离，避免污染各类型 form state）。
final class CipherAddFolderState {
  const CipherAddFolderState({
    this.folders = const [],
    this.selectedFolderId,
    this.resolvedVaultId,
    this.isLoading = false,
  });

  /// Dropdown 快捷新建项 sentinel（非真实 folder UUID）。
  static const createNewSentinel = '__create_folder__';

  final List<FolderSummary> folders;
  final String? selectedFolderId;
  final String? resolvedVaultId;
  final bool isLoading;

  bool get canSelectFolder => resolvedVaultId != null;

  CipherAddFolderState copyWith({
    List<FolderSummary>? folders,
    String? selectedFolderId,
    String? resolvedVaultId,
    bool? isLoading,
    bool clearSelectedFolder = false,
  }) {
    return CipherAddFolderState(
      folders: folders ?? this.folders,
      selectedFolderId: clearSelectedFolder
          ? null
          : (selectedFolderId ?? this.selectedFolderId),
      resolvedVaultId: resolvedVaultId ?? this.resolvedVaultId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 加载当前 vault 下文件夹列表，并维护选中 folder。
final class CipherAddFolderNotifier extends Notifier<CipherAddFolderState> {
  StreamSubscription<List<FolderSummary>>? _folderSubscription;

  FolderManageModel get _folderModel => ref.read(folderManageModelProvider);

  VaultManageModel get _vaultManage => ref.read(vaultManageModelProvider);

  @override
  CipherAddFolderState build() {
    ref.onDispose(() {
      unawaited(_folderSubscription?.cancel());
    });

    ref.listen(cipherAddVaultIdProvider, (previous, next) {
      if (previous != next) {
        unawaited(_bindFolders());
      }
    });

    unawaited(_bindFolders());
    return const CipherAddFolderState(isLoading: true);
  }

  void onFolderSelected(String? folderId) {
    if (folderId == CipherAddFolderState.createNewSentinel) {
      return;
    }
    state = state.copyWith(
      selectedFolderId: folderId,
      clearSelectedFolder: folderId == null,
    );
  }

  Future<String?> createFolder(String name) async {
    final vaultId = state.resolvedVaultId;
    if (vaultId == null || vaultId.isEmpty) {
      return null;
    }
    final folderId = await _folderModel.createFolder(
      vaultUuid: vaultId,
      name: name,
    );
    state = state.copyWith(selectedFolderId: folderId);
    return folderId;
  }

  Future<void> _bindFolders() async {
    await _folderSubscription?.cancel();
    _folderSubscription = null;

    state = state.copyWith(isLoading: true, clearSelectedFolder: true);

    final preferredVaultId = ref.read(cipherAddVaultIdProvider);
    String? vaultId = preferredVaultId;
    if (vaultId == null || vaultId.isEmpty) {
      vaultId = await _vaultManage.firstActiveVaultId();
    }

    if (vaultId == null || vaultId.isEmpty) {
      state = const CipherAddFolderState();
      return;
    }

    _folderSubscription = _folderModel
        .watchSummariesByVault(vaultId)
        .listen(
          (folders) {
            state = CipherAddFolderState(
              folders: folders,
              selectedFolderId: state.selectedFolderId,
              resolvedVaultId: vaultId,
            );
          },
          onError: (_) {
            state = CipherAddFolderState(resolvedVaultId: vaultId);
          },
        );
  }
}

final cipherAddFolderNotifierProvider =
    NotifierProvider.autoDispose<CipherAddFolderNotifier, CipherAddFolderState>(
      CipherAddFolderNotifier.new,
    );
