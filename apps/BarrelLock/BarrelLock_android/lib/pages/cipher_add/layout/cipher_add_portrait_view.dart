import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../widgets/cipher_type_selector.dart';
import 'app_account_form_section.dart';
import 'bank_card_form_section.dart';
import 'identity_document_form_section.dart';
import 'secure_note_form_section.dart';
import 'ssh_key_form_section.dart';
import 'website_login_form_section.dart';

/// 添加密码页竖屏布局：AppBar + 类型选择 + 分类型表单区。
final class CipherAddPortraitView extends StatelessWidget {
  const CipherAddPortraitView({
    super.key,
    required this.state,
    required this.onCipherTypeSelected,
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
    required this.onPrivateKeyChanged,
    required this.onPublicKeyChanged,
    required this.onPassphraseChanged,
    required this.onHostChanged,
    required this.onCancel,
    required this.onSave,
  });

  final CipherAddFormState state;
  final ValueChanged<int> onCipherTypeSelected;
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
  final ValueChanged<String> onPrivateKeyChanged;
  final ValueChanged<String> onPublicKeyChanged;
  final ValueChanged<String> onPassphraseChanged;
  final ValueChanged<String> onHostChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;
    final isSaving = state.isSaving;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 72,
        leading: TextButton(
          onPressed: isSaving ? null : onCancel,
          child: const Text('取消'),
        ),
        title: const Text('添加密码'),
        actions: [
          TextButton(
            onPressed: isSaving || !state.canSave ? null : onSave,
            child: isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  )
                : const Text('保存'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CipherTypeSelector(
              selectedType: state.cipherType,
              onTypeSelected: onCipherTypeSelected,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  if (state.validationMessage case final message?)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        message,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  _FormSection(
                    state: state,
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
                    onPrivateKeyChanged: onPrivateKeyChanged,
                    onPublicKeyChanged: onPublicKeyChanged,
                    onPassphraseChanged: onPassphraseChanged,
                    onHostChanged: onHostChanged,
                    onSave: onSave,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.state,
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
    required this.onPrivateKeyChanged,
    required this.onPublicKeyChanged,
    required this.onPassphraseChanged,
    required this.onHostChanged,
    required this.onSave,
  });

  final CipherAddFormState state;
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
  final ValueChanged<String> onPrivateKeyChanged;
  final ValueChanged<String> onPublicKeyChanged;
  final ValueChanged<String> onPassphraseChanged;
  final ValueChanged<String> onHostChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      WebsiteLoginFormState s => WebsiteLoginFormSection(
        key: const ValueKey('website-login-form'),
        state: s,
        onTitleChanged: onTitleChanged,
        onUsernameChanged: onUsernameChanged,
        onPasswordChanged: onPasswordChanged,
        onWebsiteChanged: onWebsiteChanged,
        onNotesChanged: onNotesChanged,
        onSave: onSave,
      ),
      BankCardFormState s => BankCardFormSection(
        key: const ValueKey('bank-card-form'),
        state: s,
        onTitleChanged: onTitleChanged,
        onCardholderNameChanged: onCardholderNameChanged,
        onCardNumberChanged: onCardNumberChanged,
        onExpiryMonthChanged: onExpiryMonthChanged,
        onExpiryYearChanged: onExpiryYearChanged,
        onCvvChanged: onCvvChanged,
        onPinChanged: onPinChanged,
        onNotesChanged: onNotesChanged,
        onSave: onSave,
      ),
      IdentityDocumentFormState s => IdentityDocumentFormSection(
        key: const ValueKey('identity-document-form'),
        state: s,
        onTitleChanged: onTitleChanged,
        onDocumentTypeChanged: onDocumentTypeChanged,
        onFullNameChanged: onFullNameChanged,
        onDocumentNumberChanged: onDocumentNumberChanged,
        onIssueDateChanged: onIssueDateChanged,
        onExpiryDateChanged: onExpiryDateChanged,
        onNotesChanged: onNotesChanged,
        onSave: onSave,
      ),
      SecureNoteFormState s => SecureNoteFormSection(
        key: const ValueKey('secure-note-form'),
        state: s,
        onTitleChanged: onTitleChanged,
        onContentChanged: onContentChanged,
        onNotesChanged: onNotesChanged,
        onSave: onSave,
      ),
      SshKeyFormState s => SshKeyFormSection(
        key: const ValueKey('ssh-key-form'),
        state: s,
        onTitleChanged: onTitleChanged,
        onPrivateKeyChanged: onPrivateKeyChanged,
        onPublicKeyChanged: onPublicKeyChanged,
        onPassphraseChanged: onPassphraseChanged,
        onHostChanged: onHostChanged,
        onUsernameChanged: onUsernameChanged,
        onNotesChanged: onNotesChanged,
        onSave: onSave,
      ),
      AppAccountFormState s => AppAccountFormSection(
        key: const ValueKey('app-account-form'),
        state: s,
        onTitleChanged: onTitleChanged,
        onUsernameChanged: onUsernameChanged,
        onPasswordChanged: onPasswordChanged,
        onPackageNameChanged: onPackageNameChanged,
        onNotesChanged: onNotesChanged,
        onSave: onSave,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}
