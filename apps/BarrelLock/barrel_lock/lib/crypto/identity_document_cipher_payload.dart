import 'package:core/core.dart';

import 'cipher_full_data_payload.dart';

/// 身份证件类（`CipherType.identityDocument = 3`）的 [CipherEntry.fullDataBlob] 明文结构。
final class IdentityDocumentCipherPayload extends CipherFullDataPayload {
  const IdentityDocumentCipherPayload({
    required this.documentType,
    required this.fullName,
    required this.documentNumber,
    this.issueDate,
    this.expiryDate,
    this.notes,
  });

  final String documentType;
  final String fullName;
  final String documentNumber;
  final String? issueDate;
  final String? expiryDate;
  final String? notes;

  @override
  int get type => CipherType.identityDocument;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'documentType': documentType,
    'fullName': fullName,
    'documentNumber': documentNumber,
    if (issueDate != null && issueDate!.isNotEmpty) 'issueDate': issueDate,
    if (expiryDate != null && expiryDate!.isNotEmpty) 'expiryDate': expiryDate,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };

  factory IdentityDocumentCipherPayload.fromJson(Map<String, dynamic> json) {
    return IdentityDocumentCipherPayload(
      documentType: json['documentType'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      documentNumber: json['documentNumber'] as String? ?? '',
      issueDate: json['issueDate'] as String?,
      expiryDate: json['expiryDate'] as String?,
      notes: json['notes'] as String?,
    );
  }
}
