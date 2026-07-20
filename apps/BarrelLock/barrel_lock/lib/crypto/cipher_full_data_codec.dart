import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart';

import 'cipher_full_data_payload.dart';
import 'website_login_cipher_payload.dart';

/// 密码条目 [CipherEntry.fullDataBlob] 编解码：JSON UTF-8 → ChaCha20-Poly1305。
///
/// 加解密入口为 [encrypt] / [decrypt]，按 JSON 内 `type` 字段分发到具体 payload。
/// 各类型 schema 见 `packages/core/lib/storage/密码App数据表设计.md`。
final class CipherFullDataCodec {
  CipherFullDataCodec._();

  static Future<Uint8List> encrypt(CipherFullDataPayload payload) async {
    final plain = utf8.encode(jsonEncode(payload.toJson()));
    final encrypted = await AppCrypto.encrypt(plain);
    return Uint8List.fromList(encrypted.bytes);
  }

  static Future<CipherFullDataPayload> decrypt(Uint8List blob) async {
    final payload = EncryptedPayload(blob);
    final plain = await AppCrypto.decrypt(payload);
    final json = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
    return CipherFullDataPayload.fromJson(json);
  }

  /// 网站登录类便捷方法（`CipherType.websiteLogin`）。
  static Future<Uint8List> encryptWebsiteLogin(
    WebsiteLoginCipherPayload payload,
  ) => encrypt(payload);

  /// 网站登录类便捷方法（`CipherType.websiteLogin`）。
  static Future<WebsiteLoginCipherPayload> decryptWebsiteLogin(
    Uint8List blob,
  ) async {
    final decoded = await decrypt(blob);
    if (decoded is! WebsiteLoginCipherPayload) {
      throw UnsupportedCipherTypeException(decoded.type);
    }
    return decoded;
  }
}
