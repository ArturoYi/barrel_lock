import 'package:core/core.dart';

import 'cipher_add_form_state.dart';

/// App 账户密码（type=6）添加表单态。
final class AppAccountFormState extends CipherAddFormState {
  const AppAccountFormState({
    this.title = '',
    this.username = '',
    this.password = '',
    this.packageName = '',
    this.notes = '',
    super.isSaving,
    super.errorMessage,
    super.validationMessage,
  });

  final String title;
  final String username;
  final String password;
  final String packageName;
  final String notes;

  @override
  int get cipherType => CipherType.appAccount;

  @override
  bool get canSave =>
      !isSaving &&
      title.trim().isNotEmpty &&
      username.trim().isNotEmpty &&
      password.isNotEmpty;

  AppAccountFormState copyWith({
    String? title,
    String? username,
    String? password,
    String? packageName,
    String? notes,
    bool? isSaving,
    String? errorMessage,
    String? validationMessage,
    bool clearError = false,
    bool clearValidation = false,
  }) {
    return AppAccountFormState(
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      packageName: packageName ?? this.packageName,
      notes: notes ?? this.notes,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      validationMessage: clearValidation
          ? null
          : (validationMessage ?? this.validationMessage),
    );
  }
}
