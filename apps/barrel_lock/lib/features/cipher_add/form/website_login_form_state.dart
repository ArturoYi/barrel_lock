import 'package:core/core.dart';

import 'cipher_add_form_state.dart';

/// 网站登录（type=1）添加表单态。
final class WebsiteLoginFormState extends CipherAddFormState {
  const WebsiteLoginFormState({
    this.title = '',
    this.username = '',
    this.password = '',
    this.website = '',
    this.notes = '',
    super.isSaving,
    super.errorMessage,
    super.validationMessage,
  });

  final String title;
  final String username;
  final String password;
  final String website;
  final String notes;

  @override
  int get cipherType => CipherType.websiteLogin;

  @override
  bool get canSave =>
      !isSaving &&
      title.trim().isNotEmpty &&
      username.trim().isNotEmpty &&
      password.isNotEmpty;

  WebsiteLoginFormState copyWith({
    String? title,
    String? username,
    String? password,
    String? website,
    String? notes,
    bool? isSaving,
    String? errorMessage,
    String? validationMessage,
    bool clearError = false,
    bool clearValidation = false,
  }) {
    return WebsiteLoginFormState(
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      validationMessage: clearValidation
          ? null
          : (validationMessage ?? this.validationMessage),
    );
  }
}
