import 'package:core/core.dart';

import 'cipher_full_data_payload.dart';

/// 银行卡类（`CipherType.bankCard = 2`）的 [CipherEntry.fullDataBlob] 明文结构。
final class BankCardCipherPayload extends CipherFullDataPayload {
  const BankCardCipherPayload({
    required this.cardholderName,
    required this.cardNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvv,
    this.pin,
    this.notes,
  });

  final String cardholderName;
  final String cardNumber;
  final String expiryMonth;
  final String expiryYear;
  final String cvv;
  final String? pin;
  final String? notes;

  @override
  int get type => CipherType.bankCard;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'cardholderName': cardholderName,
    'cardNumber': cardNumber,
    'expiryMonth': expiryMonth,
    'expiryYear': expiryYear,
    'cvv': cvv,
    if (pin != null && pin!.isNotEmpty) 'pin': pin,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };

  factory BankCardCipherPayload.fromJson(Map<String, dynamic> json) {
    return BankCardCipherPayload(
      cardholderName: json['cardholderName'] as String? ?? '',
      cardNumber: json['cardNumber'] as String? ?? '',
      expiryMonth: json['expiryMonth'] as String? ?? '',
      expiryYear: json['expiryYear'] as String? ?? '',
      cvv: json['cvv'] as String? ?? '',
      pin: json['pin'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
