import 'package:core/core.dart';

import 'cipher_add_coordinator.dart';
import 'cipher_add_providers.dart';
import 'cipher_type_catalog.dart';
import 'form/app_account_form_state.dart';
import 'form/bank_card_form_state.dart';
import 'form/cipher_add_form_state.dart';
import 'form/cipher_add_form_state_factory.dart';
import 'form/identity_document_form_state.dart';
import 'form/secure_note_form_state.dart';
import 'form/ssh_key_form_state.dart';
import 'form/website_login_form_state.dart';
import 'cipher_add_folder_notifier.dart';
import 'cipher_add_attachment_notifier.dart';
import '../attachment_manage/attachment_manage_model.dart';
import 'cipher_add_model.dart';

final class CipherAddViewModel extends Notifier<CipherAddFormState> {
  CipherAddModel get _model => ref.read(cipherAddModelProvider);

  CipherAddCoordinatorGateway get _coordinator =>
      ref.read(cipherAddCoordinatorProvider);

  String? get _preferredVaultId {
    final vaultId = ref.read(cipherAddVaultIdProvider);
    if (vaultId == null || vaultId.isEmpty) {
      return null;
    }
    return vaultId;
  }

  @override
  CipherAddFormState build() {
    final initialType = ref.read(cipherAddInitialTypeProvider);
    return CipherAddFormStateFactory.emptyForType(initialType);
  }

  void onCipherTypeSelected(int type) {
    if (state.isSaving || state.cipherType == type) {
      return;
    }
    final descriptor = CipherTypeDescriptor.forType(type);
    if (!descriptor.isFormEnabled) {
      state = CipherAddFormStateFactory.emptyForType(
        state.cipherType,
      ).copyWithCommon(validationMessage: '${descriptor.label}表单即将推出');
      return;
    }
    state = CipherAddFormStateFactory.emptyForType(type);
    if (!CipherTypeDescriptor.forType(type).supportsAttachments) {
      ref.read(cipherAddAttachmentNotifierProvider.notifier).clearPending();
    }
  }

  void onTitleChanged(String value) {
    final current = state;
    if (current is WebsiteLoginFormState) {
      state = current.copyWith(title: value, clearValidation: true);
    } else if (current is BankCardFormState) {
      state = current.copyWith(title: value, clearValidation: true);
    } else if (current is IdentityDocumentFormState) {
      state = current.copyWith(title: value, clearValidation: true);
    } else if (current is SecureNoteFormState) {
      state = current.copyWith(title: value, clearValidation: true);
    } else if (current is SshKeyFormState) {
      state = current.copyWith(title: value, clearValidation: true);
    } else if (current is AppAccountFormState) {
      state = current.copyWith(title: value, clearValidation: true);
    }
  }

  void onUsernameChanged(String value) {
    final current = state;
    if (current is WebsiteLoginFormState) {
      state = current.copyWith(username: value, clearValidation: true);
    } else if (current is SshKeyFormState) {
      state = current.copyWith(username: value, clearValidation: true);
    } else if (current is AppAccountFormState) {
      state = current.copyWith(username: value, clearValidation: true);
    }
  }

  void onPasswordChanged(String value) {
    final current = state;
    if (current is WebsiteLoginFormState) {
      state = current.copyWith(password: value, clearValidation: true);
    } else if (current is AppAccountFormState) {
      state = current.copyWith(password: value, clearValidation: true);
    }
  }

  void onWebsiteChanged(String value) {
    final current = state;
    if (current is WebsiteLoginFormState) {
      state = current.copyWith(website: value);
    }
  }

  void onNotesChanged(String value) {
    final current = state;
    if (current is WebsiteLoginFormState) {
      state = current.copyWith(notes: value);
    } else if (current is BankCardFormState) {
      state = current.copyWith(notes: value);
    } else if (current is IdentityDocumentFormState) {
      state = current.copyWith(notes: value);
    } else if (current is SecureNoteFormState) {
      state = current.copyWith(notes: value);
    } else if (current is SshKeyFormState) {
      state = current.copyWith(notes: value);
    } else if (current is AppAccountFormState) {
      state = current.copyWith(notes: value);
    }
  }

  void onPackageNameChanged(String value) {
    final current = state;
    if (current is AppAccountFormState) {
      state = current.copyWith(packageName: value);
    }
  }

  void onCardholderNameChanged(String value) {
    final current = state;
    if (current is BankCardFormState) {
      state = current.copyWith(cardholderName: value, clearValidation: true);
    }
  }

  void onCardNumberChanged(String value) {
    final current = state;
    if (current is BankCardFormState) {
      state = current.copyWith(cardNumber: value, clearValidation: true);
    }
  }

  void onExpiryMonthChanged(String value) {
    final current = state;
    if (current is BankCardFormState) {
      state = current.copyWith(expiryMonth: value, clearValidation: true);
    }
  }

  void onExpiryYearChanged(String value) {
    final current = state;
    if (current is BankCardFormState) {
      state = current.copyWith(expiryYear: value, clearValidation: true);
    }
  }

  void onCvvChanged(String value) {
    final current = state;
    if (current is BankCardFormState) {
      state = current.copyWith(cvv: value, clearValidation: true);
    }
  }

  void onPinChanged(String value) {
    final current = state;
    if (current is BankCardFormState) {
      state = current.copyWith(pin: value);
    }
  }

  void onDocumentTypeChanged(String value) {
    final current = state;
    if (current is IdentityDocumentFormState) {
      state = current.copyWith(documentType: value, clearValidation: true);
    }
  }

  void onFullNameChanged(String value) {
    final current = state;
    if (current is IdentityDocumentFormState) {
      state = current.copyWith(fullName: value, clearValidation: true);
    }
  }

  void onDocumentNumberChanged(String value) {
    final current = state;
    if (current is IdentityDocumentFormState) {
      state = current.copyWith(documentNumber: value, clearValidation: true);
    }
  }

  void onIssueDateChanged(String value) {
    final current = state;
    if (current is IdentityDocumentFormState) {
      state = current.copyWith(issueDate: value);
    }
  }

  void onExpiryDateChanged(String value) {
    final current = state;
    if (current is IdentityDocumentFormState) {
      state = current.copyWith(expiryDate: value);
    }
  }

  void onContentChanged(String value) {
    final current = state;
    if (current is SecureNoteFormState) {
      state = current.copyWith(content: value, clearValidation: true);
    }
  }

  void onPrivateKeyChanged(String value) {
    final current = state;
    if (current is SshKeyFormState) {
      state = current.copyWith(privateKey: value, clearValidation: true);
    }
  }

  void onPublicKeyChanged(String value) {
    final current = state;
    if (current is SshKeyFormState) {
      state = current.copyWith(publicKey: value);
    }
  }

  void onPassphraseChanged(String value) {
    final current = state;
    if (current is SshKeyFormState) {
      state = current.copyWith(passphrase: value);
    }
  }

  void onHostChanged(String value) {
    final current = state;
    if (current is SshKeyFormState) {
      state = current.copyWith(host: value);
    }
  }

  void onCancel() {
    if (state.isSaving) {
      return;
    }
    ref.read(cipherAddAttachmentNotifierProvider.notifier).clearPending();
    _coordinator.pop();
  }

  Future<void> onSave() async {
    if (state.isSaving) {
      return;
    }
    if (!state.canSave) {
      state = state.copyWithCommon(
        validationMessage: _validationMessageFor(state),
      );
      return;
    }

    state = state.copyWithCommon(
      isSaving: true,
      clearError: true,
      clearValidation: true,
    );

    try {
      final cipherUuid = await _saveCurrentState();
      final pending = ref.read(cipherAddAttachmentNotifierProvider).pending;
      if (pending.isNotEmpty) {
        await ref
            .read(attachmentManageModelProvider)
            .insertAll(cipherUuid: cipherUuid, pending: pending);
        ref.read(cipherAddAttachmentNotifierProvider.notifier).clearPending();
      }
      _coordinator.finishAddSuccess();
    } on AttachmentManageException catch (error) {
      state = state.copyWithCommon(
        isSaving: false,
        errorMessage: error.message,
      );
    } on Object {
      state = state.copyWithCommon(isSaving: false, errorMessage: '保存失败，请稍后重试');
    }
  }

  Future<String> _saveCurrentState() async {
    final vaultId = _preferredVaultId;
    final folderId = ref.read(cipherAddFolderNotifierProvider).selectedFolderId;
    final current = state;
    if (current is WebsiteLoginFormState) {
      return _model.saveWebsiteLoginCipher(
        preferredVaultId: vaultId,
        folderUuid: folderId,
        title: current.title,
        username: current.username,
        password: current.password,
        website: current.website,
        notes: current.notes,
      );
    }
    if (current is BankCardFormState) {
      return _model.saveBankCardCipher(
        preferredVaultId: vaultId,
        folderUuid: folderId,
        title: current.title,
        cardholderName: current.cardholderName,
        cardNumber: current.cardNumber,
        expiryMonth: current.expiryMonth,
        expiryYear: current.expiryYear,
        cvv: current.cvv,
        pin: current.pin,
        notes: current.notes,
      );
    }
    if (current is IdentityDocumentFormState) {
      return _model.saveIdentityDocumentCipher(
        preferredVaultId: vaultId,
        folderUuid: folderId,
        title: current.title,
        documentType: current.documentType,
        fullName: current.fullName,
        documentNumber: current.documentNumber,
        issueDate: current.issueDate,
        expiryDate: current.expiryDate,
        notes: current.notes,
      );
    }
    if (current is SecureNoteFormState) {
      return _model.saveSecureNoteCipher(
        preferredVaultId: vaultId,
        folderUuid: folderId,
        title: current.title,
        content: current.content,
        notes: current.notes,
      );
    }
    if (current is SshKeyFormState) {
      return _model.saveSshKeyCipher(
        preferredVaultId: vaultId,
        folderUuid: folderId,
        title: current.title,
        privateKey: current.privateKey,
        publicKey: current.publicKey,
        passphrase: current.passphrase,
        host: current.host,
        username: current.username,
        notes: current.notes,
      );
    }
    if (current is AppAccountFormState) {
      return _model.saveAppAccountCipher(
        preferredVaultId: vaultId,
        folderUuid: folderId,
        title: current.title,
        username: current.username,
        password: current.password,
        packageName: current.packageName,
        notes: current.notes,
      );
    }
    throw StateError('Unsupported cipher form state: ${current.runtimeType}');
  }

  String _validationMessageFor(CipherAddFormState formState) {
    if (formState is WebsiteLoginFormState) {
      return '请填写名称、用户名和密码';
    }
    if (formState is BankCardFormState) {
      return '请填写名称、持卡人、卡号、有效期和 CVV';
    }
    if (formState is IdentityDocumentFormState) {
      return '请填写名称、证件类型、姓名和证件号码';
    }
    if (formState is SecureNoteFormState) {
      return '请填写标题和笔记内容';
    }
    if (formState is SshKeyFormState) {
      return '请填写名称和私钥';
    }
    if (formState is AppAccountFormState) {
      return '请填写名称、账号和密码';
    }
    return '请完善必填项';
  }
}

extension _CipherAddFormStateCommon on CipherAddFormState {
  CipherAddFormState copyWithCommon({
    bool? isSaving,
    String? errorMessage,
    String? validationMessage,
    bool clearError = false,
    bool clearValidation = false,
  }) {
    if (this is WebsiteLoginFormState) {
      return (this as WebsiteLoginFormState).copyWith(
        isSaving: isSaving,
        errorMessage: errorMessage,
        validationMessage: validationMessage,
        clearError: clearError,
        clearValidation: clearValidation,
      );
    }
    if (this is BankCardFormState) {
      return (this as BankCardFormState).copyWith(
        isSaving: isSaving,
        errorMessage: errorMessage,
        validationMessage: validationMessage,
        clearError: clearError,
        clearValidation: clearValidation,
      );
    }
    if (this is IdentityDocumentFormState) {
      return (this as IdentityDocumentFormState).copyWith(
        isSaving: isSaving,
        errorMessage: errorMessage,
        validationMessage: validationMessage,
        clearError: clearError,
        clearValidation: clearValidation,
      );
    }
    if (this is SecureNoteFormState) {
      return (this as SecureNoteFormState).copyWith(
        isSaving: isSaving,
        errorMessage: errorMessage,
        validationMessage: validationMessage,
        clearError: clearError,
        clearValidation: clearValidation,
      );
    }
    if (this is SshKeyFormState) {
      return (this as SshKeyFormState).copyWith(
        isSaving: isSaving,
        errorMessage: errorMessage,
        validationMessage: validationMessage,
        clearError: clearError,
        clearValidation: clearValidation,
      );
    }
    if (this is AppAccountFormState) {
      return (this as AppAccountFormState).copyWith(
        isSaving: isSaving,
        errorMessage: errorMessage,
        validationMessage: validationMessage,
        clearError: clearError,
        clearValidation: clearValidation,
      );
    }
    return this;
  }
}

final cipherAddViewModelProvider =
    NotifierProvider.autoDispose<CipherAddViewModel, CipherAddFormState>(
      CipherAddViewModel.new,
    );
