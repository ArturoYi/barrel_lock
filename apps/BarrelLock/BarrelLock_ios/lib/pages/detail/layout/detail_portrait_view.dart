import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../../cipher_add/layout/app_account_form_section.dart';
import '../../cipher_add/layout/bank_card_form_section.dart';
import '../../cipher_add/layout/identity_document_form_section.dart';
import '../../cipher_add/layout/secure_note_form_section.dart';
import '../../cipher_add/layout/website_login_form_section.dart';
import '../../cipher_add/widgets/cipher_folder_selector.dart';
import '../widgets/cipher_detail_attachment_section.dart';
import '../widgets/cipher_detail_read_body.dart';

/// 密码详情页竖屏布局。
final class DetailPortraitView extends StatelessWidget {
  const DetailPortraitView({
    super.key,
    required this.state,
    required this.folderState,
    required this.attachments,
    required this.supportsAttachments,
    required this.onPop,
    required this.onToggleFavorite,
    required this.onStartEdit,
    required this.onCancelEdit,
    required this.onSaveEdit,
    required this.onDeleteTapped,
    required this.onChangeFolderTapped,
    required this.onToggleReveal,
    required this.onCopy,
    required this.onFolderSelected,
    required this.onCreateFolder,
    required this.onTitleChanged,
    required this.onUsernameChanged,
    required this.onPasswordChanged,
    required this.onWebsiteChanged,
    required this.onPackageNameChanged,
    required this.onNotesChanged,
    required this.onCardholderNameChanged,
    required this.onCardNumberChanged,
    required this.onExpiryMonthChanged,
    required this.onExpiryYearChanged,
    required this.onCvvChanged,
    required this.onPinChanged,
    required this.onDocumentTypeChanged,
    required this.onFullNameChanged,
    required this.onDocumentNumberChanged,
    required this.onIssueDateChanged,
    required this.onExpiryDateChanged,
    required this.onContentChanged,
    required this.onAddAttachmentTapped,
    required this.onDeleteAttachment,
    required this.onPreviewAttachment,
  });

  final DetailViewState state;
  final DetailFolderState folderState;
  final List<AttachmentMetadata> attachments;
  final bool supportsAttachments;
  final VoidCallback onPop;
  final VoidCallback onToggleFavorite;
  final VoidCallback onStartEdit;
  final VoidCallback onCancelEdit;
  final VoidCallback onSaveEdit;
  final VoidCallback onDeleteTapped;
  final VoidCallback onChangeFolderTapped;
  final ValueChanged<String> onToggleReveal;
  final Future<void> Function(String value) onCopy;
  final ValueChanged<String?> onFolderSelected;
  final Future<void> Function() onCreateFolder;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onWebsiteChanged;
  final ValueChanged<String> onPackageNameChanged;
  final ValueChanged<String> onNotesChanged;
  final ValueChanged<String> onCardholderNameChanged;
  final ValueChanged<String> onCardNumberChanged;
  final ValueChanged<String> onExpiryMonthChanged;
  final ValueChanged<String> onExpiryYearChanged;
  final ValueChanged<String> onCvvChanged;
  final ValueChanged<String> onPinChanged;
  final ValueChanged<String> onDocumentTypeChanged;
  final ValueChanged<String> onFullNameChanged;
  final ValueChanged<String> onDocumentNumberChanged;
  final ValueChanged<String> onIssueDateChanged;
  final ValueChanged<String> onExpiryDateChanged;
  final ValueChanged<String> onContentChanged;
  final VoidCallback onAddAttachmentTapped;
  final ValueChanged<String> onDeleteAttachment;
  final ValueChanged<AttachmentMetadata> onPreviewAttachment;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('详情')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null || state.data == null) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: onPop),
          title: const Text('详情'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              state.errorMessage ?? '无法加载详情',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final data = state.data!;
    final isEditing = state.isEditing;
    final form = state.editFormState;
    final isSaving = state.isSaving;

    return Scaffold(
      appBar: AppBar(
        leading: isEditing
            ? TextButton(
                onPressed: isSaving ? null : onCancelEdit,
                child: const Text('取消'),
              )
            : BackButton(onPressed: onPop),
        title: Text(isEditing ? '编辑' : data.overview.title),
        actions: [
          if (!isEditing) ...[
            IconButton(
              tooltip: data.isFavorite ? '取消收藏' : '收藏',
              onPressed: onToggleFavorite,
              icon: Icon(
                data.isFavorite ? Icons.star : Icons.star_border,
                color: data.isFavorite ? Colors.amber : null,
              ),
            ),
            IconButton(
              tooltip: '编辑',
              onPressed: onStartEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  onDeleteTapped();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'delete', child: Text('删除')),
              ],
            ),
          ] else
            TextButton(
              onPressed: isSaving || form == null || !form.canSave
                  ? null
                  : onSaveEdit,
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('完成'),
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            if (state.errorMessage case final message?)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  message,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.error,
                  ),
                ),
              ),
            if (!isEditing) ...[
              CipherDetailMetadataSection(
                data: data,
                onChangeFolderTapped: onChangeFolderTapped,
              ),
              const SizedBox(height: 16),
              CipherDetailReadBody(
                data: data,
                revealedFieldKeys: state.revealedFieldKeys,
                onToggleReveal: onToggleReveal,
                onCopy: onCopy,
              ),
              if (supportsAttachments) ...[
                const SizedBox(height: 16),
                CipherDetailAttachmentSection(
                  attachments: attachments,
                  enabled: true,
                  onAddTapped: onAddAttachmentTapped,
                  onDelete: onDeleteAttachment,
                  onPreview: onPreviewAttachment,
                ),
              ],
            ] else if (form != null) ...[
              if (form.validationMessage case final message?)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    message,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                ),
              CipherFolderSelector(
                folderState: _folderStateAdapter(folderState),
                onFolderSelected: onFolderSelected,
                onCreateFolder: onCreateFolder,
              ),
              _EditFormSection(
                form: form,
                supportsAttachments: supportsAttachments,
                attachments: attachments,
                onTitleChanged: onTitleChanged,
                onUsernameChanged: onUsernameChanged,
                onPasswordChanged: onPasswordChanged,
                onWebsiteChanged: onWebsiteChanged,
                onPackageNameChanged: onPackageNameChanged,
                onNotesChanged: onNotesChanged,
                onCardholderNameChanged: onCardholderNameChanged,
                onCardNumberChanged: onCardNumberChanged,
                onExpiryMonthChanged: onExpiryMonthChanged,
                onExpiryYearChanged: onExpiryYearChanged,
                onCvvChanged: onCvvChanged,
                onPinChanged: onPinChanged,
                onDocumentTypeChanged: onDocumentTypeChanged,
                onFullNameChanged: onFullNameChanged,
                onDocumentNumberChanged: onDocumentNumberChanged,
                onIssueDateChanged: onIssueDateChanged,
                onExpiryDateChanged: onExpiryDateChanged,
                onContentChanged: onContentChanged,
                onSaveEdit: onSaveEdit,
                onAddAttachmentTapped: onAddAttachmentTapped,
                onDeleteAttachment: onDeleteAttachment,
                onPreviewAttachment: onPreviewAttachment,
              ),
            ],
          ],
        ),
      ),
    );
  }

  CipherAddFolderState _folderStateAdapter(DetailFolderState folderState) {
    return CipherAddFolderState(
      folders: folderState.folders,
      selectedFolderId: folderState.selectedFolderId,
      resolvedVaultId: folderState.resolvedVaultId,
      isLoading: folderState.isLoading,
    );
  }
}

final class _EditFormSection extends StatelessWidget {
  const _EditFormSection({
    required this.form,
    required this.supportsAttachments,
    required this.attachments,
    required this.onTitleChanged,
    required this.onUsernameChanged,
    required this.onPasswordChanged,
    required this.onWebsiteChanged,
    required this.onPackageNameChanged,
    required this.onNotesChanged,
    required this.onCardholderNameChanged,
    required this.onCardNumberChanged,
    required this.onExpiryMonthChanged,
    required this.onExpiryYearChanged,
    required this.onCvvChanged,
    required this.onPinChanged,
    required this.onDocumentTypeChanged,
    required this.onFullNameChanged,
    required this.onDocumentNumberChanged,
    required this.onIssueDateChanged,
    required this.onExpiryDateChanged,
    required this.onContentChanged,
    required this.onSaveEdit,
    required this.onAddAttachmentTapped,
    required this.onDeleteAttachment,
    required this.onPreviewAttachment,
  });

  final CipherAddFormState form;
  final bool supportsAttachments;
  final List<AttachmentMetadata> attachments;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onWebsiteChanged;
  final ValueChanged<String> onPackageNameChanged;
  final ValueChanged<String> onNotesChanged;
  final ValueChanged<String> onCardholderNameChanged;
  final ValueChanged<String> onCardNumberChanged;
  final ValueChanged<String> onExpiryMonthChanged;
  final ValueChanged<String> onExpiryYearChanged;
  final ValueChanged<String> onCvvChanged;
  final ValueChanged<String> onPinChanged;
  final ValueChanged<String> onDocumentTypeChanged;
  final ValueChanged<String> onFullNameChanged;
  final ValueChanged<String> onDocumentNumberChanged;
  final ValueChanged<String> onIssueDateChanged;
  final ValueChanged<String> onExpiryDateChanged;
  final ValueChanged<String> onContentChanged;
  final VoidCallback onSaveEdit;
  final VoidCallback onAddAttachmentTapped;
  final ValueChanged<String> onDeleteAttachment;
  final ValueChanged<AttachmentMetadata> onPreviewAttachment;

  @override
  Widget build(BuildContext context) {
    return switch (form) {
      WebsiteLoginFormState s => WebsiteLoginFormSection(
        state: s,
        onTitleChanged: onTitleChanged,
        onUsernameChanged: onUsernameChanged,
        onPasswordChanged: onPasswordChanged,
        onWebsiteChanged: onWebsiteChanged,
        onNotesChanged: onNotesChanged,
        onSave: onSaveEdit,
      ),
      BankCardFormState s => Column(
        children: [
          BankCardFormSection(
            state: s,
            onTitleChanged: onTitleChanged,
            onCardholderNameChanged: onCardholderNameChanged,
            onCardNumberChanged: onCardNumberChanged,
            onExpiryMonthChanged: onExpiryMonthChanged,
            onExpiryYearChanged: onExpiryYearChanged,
            onCvvChanged: onCvvChanged,
            onPinChanged: onPinChanged,
            onNotesChanged: onNotesChanged,
            onSave: onSaveEdit,
          ),
          if (supportsAttachments) ...[
            const SizedBox(height: 16),
            CipherDetailAttachmentSection(
              attachments: attachments,
              enabled: !s.isSaving,
              onAddTapped: onAddAttachmentTapped,
              onDelete: onDeleteAttachment,
              onPreview: onPreviewAttachment,
            ),
          ],
        ],
      ),
      IdentityDocumentFormState s => Column(
        children: [
          IdentityDocumentFormSection(
            state: s,
            onTitleChanged: onTitleChanged,
            onDocumentTypeChanged: onDocumentTypeChanged,
            onFullNameChanged: onFullNameChanged,
            onDocumentNumberChanged: onDocumentNumberChanged,
            onIssueDateChanged: onIssueDateChanged,
            onExpiryDateChanged: onExpiryDateChanged,
            onNotesChanged: onNotesChanged,
            onSave: onSaveEdit,
          ),
          if (supportsAttachments) ...[
            const SizedBox(height: 16),
            CipherDetailAttachmentSection(
              attachments: attachments,
              enabled: !s.isSaving,
              onAddTapped: onAddAttachmentTapped,
              onDelete: onDeleteAttachment,
              onPreview: onPreviewAttachment,
            ),
          ],
        ],
      ),
      SecureNoteFormState s => SecureNoteFormSection(
        state: s,
        onTitleChanged: onTitleChanged,
        onContentChanged: onContentChanged,
        onNotesChanged: onNotesChanged,
        onSave: onSaveEdit,
      ),
      AppAccountFormState s => AppAccountFormSection(
        state: s,
        onTitleChanged: onTitleChanged,
        onUsernameChanged: onUsernameChanged,
        onPasswordChanged: onPasswordChanged,
        onPackageNameChanged: onPackageNameChanged,
        onNotesChanged: onNotesChanged,
        onSave: onSaveEdit,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}
