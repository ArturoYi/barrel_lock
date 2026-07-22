import 'package:core/core.dart';

import 'cipher_add_form_state.dart';

/// 安全笔记（type=4）添加表单态。
final class SecureNoteFormState extends CipherAddFormState {
  const SecureNoteFormState({
    this.title = '',
    this.content = '',
    this.notes = '',
    super.isSaving,
    super.errorMessage,
    super.validationMessage,
  });

  final String title;
  final String content;
  final String notes;

  @override
  int get cipherType => CipherType.secureNote;

  @override
  bool get canSave =>
      !isSaving && title.trim().isNotEmpty && content.trim().isNotEmpty;

  SecureNoteFormState copyWith({
    String? title,
    String? content,
    String? notes,
    bool? isSaving,
    String? errorMessage,
    String? validationMessage,
    bool clearError = false,
    bool clearValidation = false,
  }) {
    return SecureNoteFormState(
      title: title ?? this.title,
      content: content ?? this.content,
      notes: notes ?? this.notes,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      validationMessage: clearValidation
          ? null
          : (validationMessage ?? this.validationMessage),
    );
  }
}
