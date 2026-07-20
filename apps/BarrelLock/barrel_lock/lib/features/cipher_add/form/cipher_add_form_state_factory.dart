import 'package:core/core.dart';

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
}
