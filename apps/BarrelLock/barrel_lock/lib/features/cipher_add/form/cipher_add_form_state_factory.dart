import 'package:core/core.dart';

import '../../../crypto/app_account_cipher_payload.dart';
import '../../../crypto/bank_card_cipher_payload.dart';
import '../../../crypto/cipher_full_data_payload.dart';
import '../../../crypto/cipher_overview_data.dart';
import '../../../crypto/identity_document_cipher_payload.dart';
import '../../../crypto/secure_note_cipher_payload.dart';
import '../../../crypto/ssh_key_cipher_payload.dart';
import '../../../crypto/website_login_cipher_payload.dart';
import '../cipher_type_catalog.dart';
import 'app_account_form_state.dart';
import 'bank_card_form_state.dart';
import 'cipher_add_form_state.dart';
import 'identity_document_form_state.dart';
import 'secure_note_form_state.dart';
import 'ssh_key_form_state.dart';
import 'website_login_form_state.dart';

/// 按 [CipherType] 创建空表单态。
abstract final class CipherAddFormStateFactory {
  static CipherAddFormState emptyForType(int type) {
    return switch (type) {
      CipherType.websiteLogin => const WebsiteLoginFormState(),
      CipherType.bankCard => const BankCardFormState(),
      CipherType.identityDocument => const IdentityDocumentFormState(),
      CipherType.secureNote => const SecureNoteFormState(),
      CipherType.sshKey => const SshKeyFormState(),
      CipherType.appAccount => const AppAccountFormState(),
      _ => const WebsiteLoginFormState(),
    };
  }

  static CipherAddFormState emptyForDescriptor(
    CipherTypeDescriptor descriptor,
  ) {
    return emptyForType(descriptor.type);
  }

  /// 从已解密 overview / full_data 填充编辑表单。
  static CipherAddFormState fromCipherDetail({
    required CipherOverviewData overview,
    required CipherFullDataPayload fullData,
  }) {
    return switch (fullData) {
      WebsiteLoginCipherPayload payload => WebsiteLoginFormState(
        title: overview.title,
        username: payload.username,
        password: payload.password,
        website: overview.host ?? '',
        notes: payload.notes ?? '',
      ),
      BankCardCipherPayload payload => BankCardFormState(
        title: overview.title,
        cardholderName: payload.cardholderName,
        cardNumber: payload.cardNumber,
        expiryMonth: payload.expiryMonth,
        expiryYear: payload.expiryYear,
        cvv: payload.cvv,
        pin: payload.pin ?? '',
        notes: payload.notes ?? '',
      ),
      IdentityDocumentCipherPayload payload => IdentityDocumentFormState(
        title: overview.title,
        documentType: payload.documentType,
        fullName: payload.fullName,
        documentNumber: payload.documentNumber,
        issueDate: payload.issueDate ?? '',
        expiryDate: payload.expiryDate ?? '',
        notes: payload.notes ?? '',
      ),
      SecureNoteCipherPayload payload => SecureNoteFormState(
        title: overview.title,
        content: payload.content,
        notes: payload.notes ?? '',
      ),
      SshKeyCipherPayload payload => SshKeyFormState(
        title: overview.title,
        privateKey: payload.privateKey,
        publicKey: payload.publicKey ?? '',
        passphrase: payload.passphrase ?? '',
        host: payload.host ?? overview.host ?? '',
        username: payload.username ?? '',
        notes: payload.notes ?? '',
      ),
      AppAccountCipherPayload payload => AppAccountFormState(
        title: overview.title,
        username: payload.username,
        password: payload.password,
        packageName: payload.packageName ?? overview.host ?? '',
        notes: payload.notes ?? '',
      ),
      _ => emptyForType(fullData.type),
    };
  }
}
