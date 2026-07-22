import 'package:core/core.dart';

import 'cipher_add_form_state.dart';

/// 银行卡（type=2）添加表单态。
final class BankCardFormState extends CipherAddFormState {
  const BankCardFormState({
    this.title = '',
    this.cardholderName = '',
    this.cardNumber = '',
    this.expiryMonth = '',
    this.expiryYear = '',
    this.cvv = '',
    this.pin = '',
    this.notes = '',
    super.isSaving,
    super.errorMessage,
    super.validationMessage,
  });

  final String title;
  final String cardholderName;
  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final String pin;
  final String notes;

  @override
  int get cipherType => CipherType.bankCard;

  @override
  bool get canSave =>
      !isSaving &&
      title.trim().isNotEmpty &&
      cardholderName.trim().isNotEmpty &&
      cardNumber.trim().isNotEmpty &&
      expiryMonth.trim().isNotEmpty &&
      expiryYear.trim().isNotEmpty &&
      cvv.trim().isNotEmpty;

  BankCardFormState copyWith({
    String? title,
    String? cardholderName,
    String? cardNumber,
    String? expiryMonth,
    String? expiryYear,
    String? cvv,
    String? pin,
    String? notes,
    bool? isSaving,
    String? errorMessage,
    String? validationMessage,
    bool clearError = false,
    bool clearValidation = false,
  }) {
    return BankCardFormState(
      title: title ?? this.title,
      cardholderName: cardholderName ?? this.cardholderName,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      cvv: cvv ?? this.cvv,
      pin: pin ?? this.pin,
      notes: notes ?? this.notes,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      validationMessage: clearValidation
          ? null
          : (validationMessage ?? this.validationMessage),
    );
  }
}
