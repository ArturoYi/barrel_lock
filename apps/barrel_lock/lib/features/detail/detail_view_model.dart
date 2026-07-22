import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/services.dart';

import '../cipher_add/cipher_type_catalog.dart';
import '../cipher_add/form/app_account_form_state.dart';
import '../cipher_add/form/bank_card_form_state.dart';
import '../cipher_add/form/cipher_add_form_state.dart';
import '../cipher_add/form/cipher_add_form_state_factory.dart';
import '../cipher_add/form/identity_document_form_state.dart';
import '../cipher_add/form/secure_note_form_state.dart';
import '../cipher_add/form/ssh_key_form_state.dart';
import '../cipher_add/form/website_login_form_state.dart';
import 'detail_coordinator.dart';
import 'detail_folder_notifier.dart';
import 'detail_model.dart';

/// 详情页 UI 状态。
final class DetailViewState {
  const DetailViewState({
    this.isLoading = true,
    this.data,
    this.errorMessage,
    this.isEditing = false,
    this.editFormState,
    this.isSaving = false,
    this.revealedFieldKeys = const {},
  });

  final bool isLoading;
  final CipherDetailData? data;
  final String? errorMessage;
  final bool isEditing;
  final CipherAddFormState? editFormState;
  final bool isSaving;
  final Set<String> revealedFieldKeys;

  bool get hasData => data != null;

  DetailViewState copyWith({
    bool? isLoading,
    CipherDetailData? data,
    String? errorMessage,
    bool? isEditing,
    CipherAddFormState? editFormState,
    bool? isSaving,
    Set<String>? revealedFieldKeys,
    bool clearData = false,
    bool clearError = false,
    bool clearEditForm = false,
  }) {
    return DetailViewState(
      isLoading: isLoading ?? this.isLoading,
      data: clearData ? null : (data ?? this.data),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isEditing: isEditing ?? this.isEditing,
      editFormState: clearEditForm
          ? null
          : (editFormState ?? this.editFormState),
      isSaving: isSaving ?? this.isSaving,
      revealedFieldKeys: revealedFieldKeys ?? this.revealedFieldKeys,
    );
  }
}

/// 详情页状态与业务编排（MVVM-C 的 VM 层）。
final class DetailViewModel extends Notifier<DetailViewState> {
  DetailViewModel(this._cipherId);

  final String _cipherId;

  StreamSubscription<CipherEntry?>? _rowSubscription;
  CipherDetailData? _loadedSnapshot;
  var _initialLoadDone = false;

  CipherDetailModel get _model => ref.read(cipherDetailModelProvider);

  DetailCoordinatorGateway get _coordinator =>
      ref.read(detailCoordinatorProvider);

  @override
  DetailViewState build() {
    ref.onDispose(() {
      unawaited(_rowSubscription?.cancel());
    });

    unawaited(_rowSubscription?.cancel());
    _rowSubscription = _model.watchCipherRow(_cipherId).listen((row) {
      if (!_initialLoadDone) {
        return;
      }
      if (row == null || row.deletedAt != null) {
        if (!ref.mounted) {
          return;
        }
        state = state.copyWith(
          isLoading: false,
          clearData: true,
          errorMessage: '密码条目不存在或已删除',
        );
        return;
      }
      unawaited(_reload(showLoading: false));
    });

    Future.microtask(() async {
      await _reload(showLoading: true);
      _initialLoadDone = true;
    });

    return const DetailViewState(isLoading: true);
  }

  Future<void> _reload({required bool showLoading}) async {
    if (showLoading && ref.mounted) {
      state = state.copyWith(isLoading: true, clearError: true);
    }

    try {
      final data = await _model.loadCipherDetail(_cipherId);
      if (!ref.mounted) {
        return;
      }
      _loadedSnapshot = data;
      ref
          .read(detailFolderNotifierProvider(_cipherId).notifier)
          .syncSelectedFolder(data.folderUuid);
      state = state.copyWith(
        isLoading: false,
        data: data,
        clearError: true,
        isEditing: state.isEditing,
        editFormState: state.isEditing ? state.editFormState : null,
      );
    } on CipherDetailException catch (error) {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        clearData: true,
        errorMessage: _messageFor(error),
      );
    } on Object {
      if (!ref.mounted) {
        return;
      }
      state = state.copyWith(
        isLoading: false,
        clearData: true,
        errorMessage: '加载失败，请稍后重试',
      );
    }
  }

  void onPop() => _coordinator.pop();

  void onToggleReveal(String fieldKey) {
    final revealed = Set<String>.from(state.revealedFieldKeys);
    if (revealed.contains(fieldKey)) {
      revealed.remove(fieldKey);
    } else {
      revealed.add(fieldKey);
    }
    state = state.copyWith(revealedFieldKeys: revealed);
  }

  Future<String> onCopyField(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    return '已复制';
  }

  Future<void> onToggleFavorite() async {
    final data = state.data;
    if (data == null || state.isSaving) {
      return;
    }
    final next = !data.isFavorite;
    try {
      await _model.setFavorite(data.cipherUuid, next);
      await _reload(showLoading: false);
    } on Object {
      state = state.copyWith(errorMessage: '更新收藏失败');
    }
  }

  Future<void> onChangeFolder(String? folderUuid) async {
    final data = state.data;
    if (data == null || state.isSaving || state.isEditing) {
      return;
    }
    try {
      await _model.updateFolder(data.cipherUuid, folderUuid);
      ref
          .read(detailFolderNotifierProvider(_cipherId).notifier)
          .syncSelectedFolder(folderUuid);
      await _reload(showLoading: false);
    } on Object {
      state = state.copyWith(errorMessage: '更改文件夹失败');
    }
  }

  Future<bool> onDeleteConfirmed() async {
    final data = state.data;
    if (data == null || state.isSaving) {
      return false;
    }
    try {
      await _model.softDelete(data.cipherUuid);
      _coordinator.pop();
      return true;
    } on Object {
      state = state.copyWith(errorMessage: '删除失败，请稍后重试');
      return false;
    }
  }

  void onStartEdit() {
    final data = state.data;
    if (data == null || state.isSaving) {
      return;
    }
    final descriptor = CipherTypeDescriptor.forType(data.type);
    if (!descriptor.isFormEnabled) {
      state = state.copyWith(errorMessage: '${descriptor.label}暂不支持编辑');
      return;
    }
    state = state.copyWith(
      isEditing: true,
      editFormState: CipherAddFormStateFactory.fromCipherDetail(
        overview: data.overview,
        fullData: data.fullData,
      ),
      clearError: true,
    );
  }

  void onCancelEdit() {
    if (state.isSaving) {
      return;
    }
    final snapshot = _loadedSnapshot;
    state = state.copyWith(
      isEditing: false,
      clearEditForm: true,
      data: snapshot,
      revealedFieldKeys: const {},
    );
    if (snapshot != null) {
      ref
          .read(detailFolderNotifierProvider(_cipherId).notifier)
          .syncSelectedFolder(snapshot.folderUuid);
    }
  }

  Future<void> onSaveEdit() async {
    final data = state.data;
    final form = state.editFormState;
    if (data == null || form == null || state.isSaving) {
      return;
    }
    if (!form.canSave) {
      state = state.copyWith(
        editFormState: form.copyWithCommon(
          validationMessage: _validationMessageFor(form),
        ),
      );
      return;
    }

    state = state.copyWith(
      isSaving: true,
      editFormState: form.copyWithCommon(
        clearError: true,
        clearValidation: true,
      ),
    );

    try {
      final folderId = ref
          .read(detailFolderNotifierProvider(_cipherId))
          .selectedFolderId;
      await _model.updateFromFormState(
        cipherUuid: data.cipherUuid,
        formState: form,
        folderUuid: folderId,
      );
      state = state.copyWith(
        isSaving: false,
        isEditing: false,
        clearEditForm: true,
      );
      await _reload(showLoading: false);
    } on Object {
      state = state.copyWith(
        isSaving: false,
        editFormState: form.copyWithCommon(errorMessage: '保存失败，请稍后重试'),
      );
    }
  }

  void onTitleChanged(String value) => _updateEditForm(_mutateTitle(value));

  void onUsernameChanged(String value) =>
      _updateEditForm(_mutateUsername(value));

  void onPasswordChanged(String value) =>
      _updateEditForm(_mutatePassword(value));

  void onWebsiteChanged(String value) => _updateEditForm(_mutateWebsite(value));

  void onPackageNameChanged(String value) =>
      _updateEditForm(_mutatePackageName(value));

  void onNotesChanged(String value) => _updateEditForm(_mutateNotes(value));

  void onCardholderNameChanged(String value) =>
      _updateEditForm(_mutateCardholderName(value));

  void onCardNumberChanged(String value) =>
      _updateEditForm(_mutateCardNumber(value));

  void onExpiryMonthChanged(String value) =>
      _updateEditForm(_mutateExpiryMonth(value));

  void onExpiryYearChanged(String value) =>
      _updateEditForm(_mutateExpiryYear(value));

  void onCvvChanged(String value) => _updateEditForm(_mutateCvv(value));

  void onPinChanged(String value) => _updateEditForm(_mutatePin(value));

  void onDocumentTypeChanged(String value) =>
      _updateEditForm(_mutateDocumentType(value));

  void onFullNameChanged(String value) =>
      _updateEditForm(_mutateFullName(value));

  void onDocumentNumberChanged(String value) =>
      _updateEditForm(_mutateDocumentNumber(value));

  void onIssueDateChanged(String value) =>
      _updateEditForm(_mutateIssueDate(value));

  void onExpiryDateChanged(String value) =>
      _updateEditForm(_mutateExpiryDate(value));

  void onContentChanged(String value) => _updateEditForm(_mutateContent(value));

  void onPrivateKeyChanged(String value) =>
      _updateEditForm(_mutatePrivateKey(value));

  void onPublicKeyChanged(String value) =>
      _updateEditForm(_mutatePublicKey(value));

  void onPassphraseChanged(String value) =>
      _updateEditForm(_mutatePassphrase(value));

  void onHostChanged(String value) => _updateEditForm(_mutateHost(value));

  void _updateEditForm(CipherAddFormState? next) {
    if (next == null || !state.isEditing) {
      return;
    }
    state = state.copyWith(editFormState: next);
  }

  CipherAddFormState? _mutateTitle(String value) {
    final form = state.editFormState;
    if (form is WebsiteLoginFormState) {
      return form.copyWith(title: value, clearValidation: true);
    }
    if (form is BankCardFormState) {
      return form.copyWith(title: value, clearValidation: true);
    }
    if (form is IdentityDocumentFormState) {
      return form.copyWith(title: value, clearValidation: true);
    }
    if (form is SecureNoteFormState) {
      return form.copyWith(title: value, clearValidation: true);
    }
    if (form is SshKeyFormState) {
      return form.copyWith(title: value, clearValidation: true);
    }
    if (form is AppAccountFormState) {
      return form.copyWith(title: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutateUsername(String value) {
    final form = state.editFormState;
    if (form is WebsiteLoginFormState) {
      return form.copyWith(username: value, clearValidation: true);
    }
    if (form is SshKeyFormState) {
      return form.copyWith(username: value, clearValidation: true);
    }
    if (form is AppAccountFormState) {
      return form.copyWith(username: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutatePassword(String value) {
    final form = state.editFormState;
    if (form is WebsiteLoginFormState) {
      return form.copyWith(password: value, clearValidation: true);
    }
    if (form is AppAccountFormState) {
      return form.copyWith(password: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutateWebsite(String value) {
    final form = state.editFormState;
    if (form is WebsiteLoginFormState) {
      return form.copyWith(website: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutatePackageName(String value) {
    final form = state.editFormState;
    if (form is AppAccountFormState) {
      return form.copyWith(packageName: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutateNotes(String value) {
    final form = state.editFormState;
    if (form is WebsiteLoginFormState) {
      return form.copyWith(notes: value, clearValidation: true);
    }
    if (form is BankCardFormState) {
      return form.copyWith(notes: value, clearValidation: true);
    }
    if (form is IdentityDocumentFormState) {
      return form.copyWith(notes: value, clearValidation: true);
    }
    if (form is SecureNoteFormState) {
      return form.copyWith(notes: value, clearValidation: true);
    }
    if (form is SshKeyFormState) {
      return form.copyWith(notes: value, clearValidation: true);
    }
    if (form is AppAccountFormState) {
      return form.copyWith(notes: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutateCardholderName(String value) {
    final form = state.editFormState;
    if (form is BankCardFormState) {
      return form.copyWith(cardholderName: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutateCardNumber(String value) {
    final form = state.editFormState;
    if (form is BankCardFormState) {
      return form.copyWith(cardNumber: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutateExpiryMonth(String value) {
    final form = state.editFormState;
    if (form is BankCardFormState) {
      return form.copyWith(expiryMonth: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutateExpiryYear(String value) {
    final form = state.editFormState;
    if (form is BankCardFormState) {
      return form.copyWith(expiryYear: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutateCvv(String value) {
    final form = state.editFormState;
    if (form is BankCardFormState) {
      return form.copyWith(cvv: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutatePin(String value) {
    final form = state.editFormState;
    if (form is BankCardFormState) {
      return form.copyWith(pin: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutateDocumentType(String value) {
    final form = state.editFormState;
    if (form is IdentityDocumentFormState) {
      return form.copyWith(documentType: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutateFullName(String value) {
    final form = state.editFormState;
    if (form is IdentityDocumentFormState) {
      return form.copyWith(fullName: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutateDocumentNumber(String value) {
    final form = state.editFormState;
    if (form is IdentityDocumentFormState) {
      return form.copyWith(documentNumber: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutateIssueDate(String value) {
    final form = state.editFormState;
    if (form is IdentityDocumentFormState) {
      return form.copyWith(issueDate: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutateExpiryDate(String value) {
    final form = state.editFormState;
    if (form is IdentityDocumentFormState) {
      return form.copyWith(expiryDate: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutateContent(String value) {
    final form = state.editFormState;
    if (form is SecureNoteFormState) {
      return form.copyWith(content: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutatePrivateKey(String value) {
    final form = state.editFormState;
    if (form is SshKeyFormState) {
      return form.copyWith(privateKey: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutatePublicKey(String value) {
    final form = state.editFormState;
    if (form is SshKeyFormState) {
      return form.copyWith(publicKey: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutatePassphrase(String value) {
    final form = state.editFormState;
    if (form is SshKeyFormState) {
      return form.copyWith(passphrase: value, clearValidation: true);
    }
    return null;
  }

  CipherAddFormState? _mutateHost(String value) {
    final form = state.editFormState;
    if (form is SshKeyFormState) {
      return form.copyWith(host: value, clearValidation: true);
    }
    return null;
  }

  static String _messageFor(CipherDetailException error) {
    return switch (error.failure) {
      CipherDetailFailure.notFound => '密码条目不存在或已删除',
      CipherDetailFailure.decryptFailed => '无法解密条目内容',
    };
  }

  static String _validationMessageFor(CipherAddFormState formState) {
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

extension _DetailFormStateCommon on CipherAddFormState {
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

final detailViewModelProvider = NotifierProvider.autoDispose
    .family<DetailViewModel, DetailViewState, String>(DetailViewModel.new);
