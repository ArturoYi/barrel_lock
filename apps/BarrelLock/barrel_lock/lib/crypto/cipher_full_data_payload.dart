import 'package:core/core.dart';

import 'app_account_cipher_payload.dart';
import 'bank_card_cipher_payload.dart';
import 'identity_document_cipher_payload.dart';
import 'secure_note_cipher_payload.dart';
import 'ssh_key_cipher_payload.dart';
import 'website_login_cipher_payload.dart';

/// [CipherEntry.fullDataBlob] 解密后的明文根类型。
///
/// 与 [CipherEntries.type] 一一对应；各子类 JSON 必须含 `"type": <int>` 字段。
/// Schema 约定见 `packages/core/lib/storage/密码App数据表设计.md`。
abstract base class CipherFullDataPayload {
  const CipherFullDataPayload();

  int get type;

  Map<String, dynamic> toJson();

  /// 按 JSON 内 `type` 字段反序列化为具体 payload。
  static CipherFullDataPayload fromJson(Map<String, dynamic> json) {
    return switch (json['type'] as int?) {
      CipherType.websiteLogin => WebsiteLoginCipherPayload.fromJson(json),
      CipherType.bankCard => BankCardCipherPayload.fromJson(json),
      CipherType.identityDocument => IdentityDocumentCipherPayload.fromJson(
        json,
      ),
      CipherType.secureNote => SecureNoteCipherPayload.fromJson(json),
      CipherType.sshKey => SshKeyCipherPayload.fromJson(json),
      CipherType.appAccount => AppAccountCipherPayload.fromJson(json),
      _ => throw UnsupportedCipherTypeException(json['type'] as int?),
    };
  }
}

/// 未知或未支持的 cipher 类型。
final class UnsupportedCipherTypeException implements Exception {
  const UnsupportedCipherTypeException(this.type);

  final int? type;

  @override
  String toString() => 'UnsupportedCipherTypeException(type: $type)';
}
