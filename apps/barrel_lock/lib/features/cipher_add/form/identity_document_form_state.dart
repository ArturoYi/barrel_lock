import 'package:core/core.dart';

import 'cipher_add_form_state.dart';

/// 身份证件（type=3）添加表单态。
final class IdentityDocumentFormState extends CipherAddFormState {
  const IdentityDocumentFormState({
    this.title = '',
    this.documentType = '',
    this.fullName = '',
    this.documentNumber = '',
    this.issueDate = '',
    this.expiryDate = '',
    this.notes = '',
    super.isSaving,
    super.errorMessage,
    super.validationMessage,
  });

  final String title;
  final String documentType;
  final String fullName;
  final String documentNumber;
  final String issueDate;
  final String expiryDate;
  final String notes;

  @override
  int get cipherType => CipherType.identityDocument;

  @override
  bool get canSave =>
      !isSaving &&
      title.trim().isNotEmpty &&
      documentType.trim().isNotEmpty &&
      fullName.trim().isNotEmpty &&
      documentNumber.trim().isNotEmpty;

  IdentityDocumentFormState copyWith({
    String? title,
    String? documentType,
    String? fullName,
    String? documentNumber,
    String? issueDate,
    String? expiryDate,
    String? notes,
    bool? isSaving,
    String? errorMessage,
    String? validationMessage,
    bool clearError = false,
    bool clearValidation = false,
  }) {
    return IdentityDocumentFormState(
      title: title ?? this.title,
      documentType: documentType ?? this.documentType,
      fullName: fullName ?? this.fullName,
      documentNumber: documentNumber ?? this.documentNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      notes: notes ?? this.notes,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      validationMessage: clearValidation
          ? null
          : (validationMessage ?? this.validationMessage),
    );
  }
}
