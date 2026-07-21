import 'dart:async';

import 'package:core/core.dart';

import '../folder_manage/folder_manage_model.dart';
import 'detail_model.dart';

/// 详情页文件夹选择态。
final class DetailFolderState {
  const DetailFolderState({
    this.folders = const [],
    this.selectedFolderId,
    this.resolvedVaultId,
    this.isLoading = false,
  });

  static const createNewSentinel = '__create_folder__';

  final List<FolderSummary> folders;
  final String? selectedFolderId;
  final String? resolvedVaultId;
  final bool isLoading;

  bool get canSelectFolder => resolvedVaultId != null;

  DetailFolderState copyWith({
    List<FolderSummary>? folders,
    String? selectedFolderId,
    String? resolvedVaultId,
    bool? isLoading,
    bool clearSelectedFolder = false,
  }) {
    return DetailFolderState(
      folders: folders ?? this.folders,
      selectedFolderId: clearSelectedFolder
          ? null
          : (selectedFolderId ?? this.selectedFolderId),
      resolvedVaultId: resolvedVaultId ?? this.resolvedVaultId,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// 详情页文件夹列表（按 cipher 所属 vault 加载）。
final class DetailFolderNotifier extends Notifier<DetailFolderState> {
  DetailFolderNotifier(this._cipherId);

  final String _cipherId;

  StreamSubscription<List<FolderSummary>>? _folderSubscription;

  FolderManageModel get _folderModel => ref.read(folderManageModelProvider);

  CipherDetailModel get _detailModel => ref.read(cipherDetailModelProvider);

  @override
  DetailFolderState build() {
    ref.onDispose(() {
      unawaited(_folderSubscription?.cancel());
    });

    unawaited(_bindFolders(_cipherId));
    return const DetailFolderState(isLoading: true);
  }

  void syncSelectedFolder(String? folderUuid) {
    state = state.copyWith(
      selectedFolderId: folderUuid,
      clearSelectedFolder: folderUuid == null,
    );
  }

  void onFolderSelected(String? folderId) {
    if (folderId == DetailFolderState.createNewSentinel) {
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

  Future<void> _bindFolders(String cipherId) async {
    await _folderSubscription?.cancel();
    _folderSubscription = null;
    state = state.copyWith(isLoading: true, clearSelectedFolder: true);

    try {
      final detail = await _detailModel.loadCipherDetail(cipherId);
      final vaultId = detail.vaultUuid;
      state = DetailFolderState(
        resolvedVaultId: vaultId,
        selectedFolderId: detail.folderUuid,
        isLoading: true,
      );

      _folderSubscription = _folderModel
          .watchSummariesByVault(vaultId)
          .listen(
            (folders) {
              state = DetailFolderState(
                folders: folders,
                selectedFolderId: state.selectedFolderId ?? detail.folderUuid,
                resolvedVaultId: vaultId,
              );
            },
            onError: (_) {
              state = DetailFolderState(
                resolvedVaultId: vaultId,
                selectedFolderId: detail.folderUuid,
              );
            },
          );
    } on Object {
      state = const DetailFolderState();
    }
  }
}

final detailFolderNotifierProvider = NotifierProvider.autoDispose
    .family<DetailFolderNotifier, DetailFolderState, String>(
      DetailFolderNotifier.new,
    );
