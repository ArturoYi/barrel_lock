import 'package:core/core.dart';

import 'cipher_full_data_payload.dart';

/// 安全笔记类（`CipherType.secureNote = 4`）的 [CipherEntry.fullDataBlob] 明文结构。
final class SecureNoteCipherPayload extends CipherFullDataPayload {
  const SecureNoteCipherPayload({required this.content, this.notes});

  final String content;
  final String? notes;

  @override
  int get type => CipherType.secureNote;

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'content': content,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
  };

  factory SecureNoteCipherPayload.fromJson(Map<String, dynamic> json) {
    return SecureNoteCipherPayload(
      content: json['content'] as String? ?? '',
      notes: json['notes'] as String?,
    );
  }
}
