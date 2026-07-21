import 'dart:typed_data';

import 'package:core/core.dart';

import '../../crypto/app_account_cipher_payload.dart';
import '../../crypto/bank_card_cipher_payload.dart';
import '../../crypto/cipher_full_data_codec.dart';
import '../../crypto/cipher_full_data_payload.dart';
import '../../crypto/cipher_overview_codec.dart';
import '../../crypto/cipher_overview_data.dart';
import '../../crypto/encrypted_name_codec.dart';
import '../../crypto/identity_document_cipher_payload.dart';
import '../../crypto/secure_note_cipher_payload.dart';
import '../../crypto/ssh_key_cipher_payload.dart';
import '../../crypto/website_login_cipher_payload.dart';
import '../../storage/storage_providers.dart';
import '../cipher_add/cipher_add_model.dart';
import '../cipher_add/form/app_account_form_state.dart';
import '../cipher_add/form/bank_card_form_state.dart';
import '../cipher_add/form/cipher_add_form_state.dart';
import '../cipher_add/form/identity_document_form_state.dart';
import '../cipher_add/form/secure_note_form_state.dart';
import '../cipher_add/form/ssh_key_form_state.dart';
import '../cipher_add/form/website_login_form_state.dart';

/// 详情页加载失败原因。
enum CipherDetailFailure { notFound, decryptFailed }

/// 详情页加载/展示用 DTO。
final class CipherDetailData {
  const CipherDetailData({
    required this.cipherUuid,
    required this.type,
    required this.overview,
    required this.fullData,
    required this.vaultUuid,
    required this.folderUuid,
    required this.folderName,
    required this.isFavorite,
    required this.updatedAt,
  });

  final String cipherUuid;
  final int type;
  final CipherOverviewData overview;
  final CipherFullDataPayload fullData;
  final String vaultUuid;
  final String? folderUuid;
  final String? folderName;
  final bool isFavorite;
  final DateTime updatedAt;
}

/// 详情页业务异常。
final class CipherDetailException implements Exception {
  const CipherDetailException(this.failure, [this.message]);

  final CipherDetailFailure failure;
  final String? message;

  @override
  String toString() => message ?? failure.name;
}

/// 密码详情读写（MVVM-C 的 M 层）。
final class CipherDetailModel {
  CipherDetailModel(this._repos);

  final StorageRepositories _repos;

  Stream<CipherEntry?> watchCipherRow(String cipherUuid) {
    return _repos.cipherEntries.watchById(cipherUuid);
  }

  Future<CipherDetailData> loadCipherDetail(String cipherUuid) async {
    final row = await _repos.cipherEntries.findById(cipherUuid);
    if (row == null || row.deletedAt != null) {
      throw const CipherDetailException(CipherDetailFailure.notFound);
    }

    try {
      final overview = await CipherOverviewCodec.decrypt(row.overviewBlob);
      final fullData = await CipherFullDataCodec.decrypt(row.fullDataBlob);
      final folderName = await _resolveFolderName(row.folderUuid);

      return CipherDetailData(
        cipherUuid: row.cipherUuid,
        type: row.type,
        overview: overview,
        fullData: fullData,
        vaultUuid: row.vaultUuid,
        folderUuid: row.folderUuid,
        folderName: folderName,
        isFavorite: row.isFavorite,
        updatedAt: row.updatedAt,
      );
    } on Object {
      throw const CipherDetailException(CipherDetailFailure.decryptFailed);
    }
  }

  Future<void> updateFromFormState({
    required String cipherUuid,
    required CipherAddFormState formState,
    String? folderUuid,
  }) async {
    if (!formState.canSave) {
      throw ArgumentError('formState is not valid for save');
    }

    final row = await _repos.cipherEntries.findById(cipherUuid);
    if (row == null || row.deletedAt != null) {
      throw const CipherDetailException(CipherDetailFailure.notFound);
    }

    final payloads = _payloadsFromFormState(formState);
    final now = DateTime.now().toUtc();
    final overviewBlob = await CipherOverviewCodec.encrypt(payloads.$1);
    final fullDataBlob = await CipherFullDataCodec.encrypt(payloads.$2);

    await _repos.cipherEntries.update(
      CipherEntry(
        cipherUuid: row.cipherUuid,
        vaultUuid: row.vaultUuid,
        folderUuid: folderUuid ?? row.folderUuid,
        ownerAccountId: row.ownerAccountId,
        type: row.type,
        overviewBlob: overviewBlob,
        fullDataBlob: fullDataBlob,
        isFavorite: row.isFavorite,
        deletedAt: row.deletedAt,
        syncRevision: now,
        localModified: true,
        remoteId: row.remoteId,
        createdAt: row.createdAt,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateFolder(String cipherUuid, String? folderUuid) async {
    final updated = await _repos.cipherEntries.updateFolderUuid(
      cipherUuid,
      folderUuid,
    );
    if (!updated) {
      throw const CipherDetailException(CipherDetailFailure.notFound);
    }
  }

  Future<void> setFavorite(String cipherUuid, bool isFavorite) async {
    final updated = await _repos.cipherEntries.setFavorite(
      cipherUuid,
      isFavorite,
    );
    if (!updated) {
      throw const CipherDetailException(CipherDetailFailure.notFound);
    }
  }

  Future<void> softDelete(String cipherUuid) async {
    final deleted = await _repos.cipherEntries.softDelete(cipherUuid);
    if (!deleted) {
      throw const CipherDetailException(CipherDetailFailure.notFound);
    }
  }

  Future<String?> _resolveFolderName(String? folderUuid) async {
    if (folderUuid == null || folderUuid.isEmpty) {
      return null;
    }
    final folder = await _repos.folders.findById(folderUuid);
    if (folder == null || folder.isTrashed) {
      return null;
    }
    return EncryptedNameCodec.decryptOrFallback(
      Uint8List.fromList(folder.name),
    );
  }

  (CipherOverviewData, CipherFullDataPayload) _payloadsFromFormState(
    CipherAddFormState formState,
  ) {
    if (formState is WebsiteLoginFormState) {
      final host = CipherAddModel.parseWebsiteHost(formState.website);
      return (
        CipherOverviewData(
          title: formState.title.trim(),
          subtitle: formState.username.trim(),
          host: host,
        ),
        WebsiteLoginCipherPayload(
          username: formState.username.trim(),
          password: formState.password,
          notes: formState.notes.trim().isEmpty ? null : formState.notes.trim(),
        ),
      );
    }
    if (formState is BankCardFormState) {
      final normalizedNumber = formState.cardNumber.replaceAll(
        RegExp(r'\s'),
        '',
      );
      return (
        CipherOverviewData(
          title: formState.title.trim(),
          subtitle: CipherAddModel.lastFourDigits(normalizedNumber),
        ),
        BankCardCipherPayload(
          cardholderName: formState.cardholderName.trim(),
          cardNumber: normalizedNumber,
          expiryMonth: formState.expiryMonth.trim(),
          expiryYear: formState.expiryYear.trim(),
          cvv: formState.cvv.trim(),
          pin: formState.pin.trim().isEmpty ? null : formState.pin.trim(),
          notes: formState.notes.trim().isEmpty ? null : formState.notes.trim(),
        ),
      );
    }
    if (formState is IdentityDocumentFormState) {
      return (
        CipherOverviewData(
          title: formState.title.trim(),
          subtitle: CipherAddModel.maskDocumentNumber(
            formState.documentNumber.trim(),
          ),
        ),
        IdentityDocumentCipherPayload(
          documentType: formState.documentType.trim(),
          fullName: formState.fullName.trim(),
          documentNumber: formState.documentNumber.trim(),
          issueDate: formState.issueDate.trim().isEmpty
              ? null
              : formState.issueDate.trim(),
          expiryDate: formState.expiryDate.trim().isEmpty
              ? null
              : formState.expiryDate.trim(),
          notes: formState.notes.trim().isEmpty ? null : formState.notes.trim(),
        ),
      );
    }
    if (formState is SecureNoteFormState) {
      return (
        CipherOverviewData(
          title: formState.title.trim(),
          subtitle: CipherAddModel.contentSummary(formState.content),
        ),
        SecureNoteCipherPayload(
          content: formState.content.trim(),
          notes: formState.notes.trim().isEmpty ? null : formState.notes.trim(),
        ),
      );
    }
    if (formState is SshKeyFormState) {
      final trimmedHost = formState.host.trim();
      final trimmedUser = formState.username.trim();
      return (
        CipherOverviewData(
          title: formState.title.trim(),
          subtitle: CipherAddModel.sshSubtitle(trimmedUser, trimmedHost),
          host: trimmedHost.isEmpty ? null : trimmedHost,
        ),
        SshKeyCipherPayload(
          privateKey: formState.privateKey,
          publicKey: formState.publicKey.trim().isEmpty
              ? null
              : formState.publicKey.trim(),
          passphrase: formState.passphrase.trim().isEmpty
              ? null
              : formState.passphrase.trim(),
          host: trimmedHost.isEmpty ? null : trimmedHost,
          username: trimmedUser.isEmpty ? null : trimmedUser,
          notes: formState.notes.trim().isEmpty ? null : formState.notes.trim(),
        ),
      );
    }
    if (formState is AppAccountFormState) {
      final trimmedPackage = formState.packageName.trim();
      return (
        CipherOverviewData(
          title: formState.title.trim(),
          subtitle: formState.username.trim(),
          host: trimmedPackage.isEmpty ? null : trimmedPackage,
        ),
        AppAccountCipherPayload(
          username: formState.username.trim(),
          password: formState.password,
          packageName: trimmedPackage.isEmpty ? null : trimmedPackage,
          notes: formState.notes.trim().isEmpty ? null : formState.notes.trim(),
        ),
      );
    }
    throw ArgumentError('Unsupported form state: ${formState.runtimeType}');
  }
}

final cipherDetailModelProvider = Provider<CipherDetailModel>((ref) {
  return CipherDetailModel(ref.watch(storageRepositoriesProvider));
});
