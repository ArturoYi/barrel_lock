import 'dart:typed_data';

import 'package:core/core.dart';

import '../attachment_manage/attachment_manage_model.dart';

/// 添加页附件 pending 态。
final class CipherAddAttachmentState {
  const CipherAddAttachmentState({this.pending = const [], this.errorMessage});

  final List<PendingAttachment> pending;
  final String? errorMessage;

  bool get canAddMore => pending.length < AttachmentLimits.maxCountPerCipher;

  bool get hasPending => pending.isNotEmpty;

  CipherAddAttachmentState copyWith({
    List<PendingAttachment>? pending,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CipherAddAttachmentState(
      pending: pending ?? this.pending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// 维护添加页待保存附件列表。
final class CipherAddAttachmentNotifier
    extends Notifier<CipherAddAttachmentState> {
  @override
  CipherAddAttachmentState build() => const CipherAddAttachmentState();

  void addPending({
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
  }) {
    try {
      AttachmentManageModel.validatePendingAttachment(
        mimeType: mimeType,
        sizeBytes: bytes.length,
        currentPendingCount: state.pending.length,
      );
    } on AttachmentManageException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return;
    }

    final item = PendingAttachment(
      localId: AppIds.newUuid(),
      fileName: fileName,
      mimeType: mimeType,
      bytes: bytes,
    );
    state = CipherAddAttachmentState(pending: [...state.pending, item]);
  }

  void removePending(String localId) {
    state = CipherAddAttachmentState(
      pending: [
        for (final item in state.pending)
          if (item.localId != localId) item,
      ],
    );
  }

  void clearPending() {
    state = const CipherAddAttachmentState();
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }
    state = state.copyWith(clearError: true);
  }
}

final cipherAddAttachmentNotifierProvider =
    NotifierProvider.autoDispose<
      CipherAddAttachmentNotifier,
      CipherAddAttachmentState
    >(CipherAddAttachmentNotifier.new);
