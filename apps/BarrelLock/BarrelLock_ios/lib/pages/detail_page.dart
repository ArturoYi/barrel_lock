import 'dart:async';

import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'cipher_add/widgets/cipher_attachment_picker.dart';
import 'cipher_add/widgets/cipher_attachment_section.dart';
import 'home/tabs/password/widgets/vault_create_sheet.dart';
import 'detail/layout/detail_portrait_view.dart';
import 'detail/widgets/cipher_detail_attachment_section.dart';
import 'detail/widgets/cipher_detail_sheets.dart';

/// 密码详情页（MVVM-C 的 V 层）。
class DetailPage extends ConsumerWidget {
  const DetailPage({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _DetailPageBody(id: id);
  }
}

final class _DetailPageBody extends ConsumerStatefulWidget {
  const _DetailPageBody({required this.id});

  final String id;

  @override
  ConsumerState<_DetailPageBody> createState() => _DetailPageBodyState();
}

final class _DetailPageBodyState extends ConsumerState<_DetailPageBody> {
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleCopy(String value) async {
    final message = await ref
        .read(detailViewModelProvider(widget.id).notifier)
        .onCopyField(value);
    if (mounted) {
      _showSnackBar(message);
    }
  }

  Future<void> _handleChangeFolder() async {
    final folderState = ref.read(detailFolderNotifierProvider(widget.id));
    final folderNotifier = ref.read(
      detailFolderNotifierProvider(widget.id).notifier,
    );
    final viewModel = ref.read(detailViewModelProvider(widget.id).notifier);

    final selected = await showCipherDetailFolderSheet(
      context: context,
      folderState: folderState,
      onCreateFolder: () async {
        final name = await showCreateFolderSheet(context);
        if (name == null) {
          return null;
        }
        return folderNotifier.createFolder(name);
      },
    );

    if (!mounted || selected == DetailFolderState.createNewSentinel) {
      return;
    }

    await viewModel.onChangeFolder(selected);
  }

  Future<void> _handleDelete() async {
    final confirmed = await showCipherDetailDeleteDialog(context);
    if (!confirmed || !mounted) {
      return;
    }
    await ref
        .read(detailViewModelProvider(widget.id).notifier)
        .onDeleteConfirmed();
  }

  Future<void> _handleAddAttachment(String cipherUuid) async {
    final source = await showAttachmentSourceSheet(context);
    if (source == null || !mounted) {
      return;
    }

    final picked = await pickCipherAttachment(source: source);
    if (picked == null || !mounted) {
      return;
    }

    try {
      await ref
          .read(attachmentManageModelProvider)
          .insertAttachment(
            cipherUuid: cipherUuid,
            fileName: picked.fileName,
            mimeType: picked.mimeType,
            bytes: picked.bytes,
          );
    } on AttachmentManageException catch (error) {
      if (mounted) {
        _showSnackBar(error.message);
      }
    }
  }

  Future<void> _handleDeleteAttachment(String attachId) async {
    final confirmed = await confirmDeleteAttachment(context);
    if (!confirmed || !mounted) {
      return;
    }
    await ref.read(attachmentManageModelProvider).deleteAttachment(attachId);
  }

  @override
  Widget build(BuildContext context) {
    final cipherId = widget.id;
    final state = ref.watch(detailViewModelProvider(cipherId));
    final folderState = ref.watch(detailFolderNotifierProvider(cipherId));
    final viewModel = ref.read(detailViewModelProvider(cipherId).notifier);
    final folderNotifier = ref.read(
      detailFolderNotifierProvider(cipherId).notifier,
    );
    final attachmentModel = ref.watch(attachmentManageModelProvider);
    final attachments =
        ref.watch(detailAttachmentsStreamProvider(cipherId)).value ??
        const <AttachmentMetadata>[];

    final data = state.data;
    final supportsAttachments =
        data != null &&
        CipherTypeDescriptor.forType(data.type).supportsAttachments;

    return DetailPortraitView(
      state: state,
      folderState: folderState,
      attachments: attachments,
      supportsAttachments: supportsAttachments,
      onPop: viewModel.onPop,
      onToggleFavorite: viewModel.onToggleFavorite,
      onStartEdit: viewModel.onStartEdit,
      onCancelEdit: viewModel.onCancelEdit,
      onSaveEdit: viewModel.onSaveEdit,
      onDeleteTapped: () => unawaited(_handleDelete()),
      onChangeFolderTapped: () => unawaited(_handleChangeFolder()),
      onToggleReveal: viewModel.onToggleReveal,
      onCopy: _handleCopy,
      onFolderSelected: folderNotifier.onFolderSelected,
      onCreateFolder: () async {
        final name = await showCreateFolderSheet(context);
        if (name == null) {
          return;
        }
        await folderNotifier.createFolder(name);
      },
      onTitleChanged: viewModel.onTitleChanged,
      onUsernameChanged: viewModel.onUsernameChanged,
      onPasswordChanged: viewModel.onPasswordChanged,
      onWebsiteChanged: viewModel.onWebsiteChanged,
      onPackageNameChanged: viewModel.onPackageNameChanged,
      onNotesChanged: viewModel.onNotesChanged,
      onCardholderNameChanged: viewModel.onCardholderNameChanged,
      onCardNumberChanged: viewModel.onCardNumberChanged,
      onExpiryMonthChanged: viewModel.onExpiryMonthChanged,
      onExpiryYearChanged: viewModel.onExpiryYearChanged,
      onCvvChanged: viewModel.onCvvChanged,
      onPinChanged: viewModel.onPinChanged,
      onDocumentTypeChanged: viewModel.onDocumentTypeChanged,
      onFullNameChanged: viewModel.onFullNameChanged,
      onDocumentNumberChanged: viewModel.onDocumentNumberChanged,
      onIssueDateChanged: viewModel.onIssueDateChanged,
      onExpiryDateChanged: viewModel.onExpiryDateChanged,
      onContentChanged: viewModel.onContentChanged,
      onAddAttachmentTapped: data == null
          ? () {}
          : () => unawaited(_handleAddAttachment(data.cipherUuid)),
      onDeleteAttachment: (id) => unawaited(_handleDeleteAttachment(id)),
      onPreviewAttachment: (metadata) => unawaited(
        showStoredAttachmentPreview(
          context: context,
          model: attachmentModel,
          metadata: metadata,
        ),
      ),
    );
  }
}
