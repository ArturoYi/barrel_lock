import 'package:core/core.dart';

import 'cipher_add_form_state.dart';

/// SSH 密钥（type=5）添加表单态。
final class SshKeyFormState extends CipherAddFormState {
  const SshKeyFormState({
    this.title = '',
    this.privateKey = '',
    this.publicKey = '',
    this.passphrase = '',
    this.host = '',
    this.username = '',
    this.notes = '',
    super.isSaving,
    super.errorMessage,
    super.validationMessage,
  });

  final String title;
  final String privateKey;
  final String publicKey;
  final String passphrase;
  final String host;
  final String username;
  final String notes;

  @override
  int get cipherType => CipherType.sshKey;

  @override
  bool get canSave =>
      !isSaving && title.trim().isNotEmpty && privateKey.isNotEmpty;

  SshKeyFormState copyWith({
    String? title,
    String? privateKey,
    String? publicKey,
    String? passphrase,
    String? host,
    String? username,
    String? notes,
    bool? isSaving,
    String? errorMessage,
    String? validationMessage,
    bool clearError = false,
    bool clearValidation = false,
  }) {
    return SshKeyFormState(
      title: title ?? this.title,
      privateKey: privateKey ?? this.privateKey,
      publicKey: publicKey ?? this.publicKey,
      passphrase: passphrase ?? this.passphrase,
      host: host ?? this.host,
      username: username ?? this.username,
      notes: notes ?? this.notes,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      validationMessage: clearValidation
          ? null
          : (validationMessage ?? this.validationMessage),
    );
  }
}
