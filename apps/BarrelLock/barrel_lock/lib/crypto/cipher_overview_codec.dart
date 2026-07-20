import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart';

import 'cipher_overview_data.dart';

/// 密码条目 [CipherEntry.overviewBlob] 编解码：JSON UTF-8 → ChaCha20-Poly1305。
final class CipherOverviewCodec {
  CipherOverviewCodec._();

  static Future<Uint8List> encrypt(CipherOverviewData data) async {
    final plain = utf8.encode(jsonEncode(data.toJson()));
    final payload = await AppCrypto.encrypt(plain);
    return Uint8List.fromList(payload.bytes);
  }

  static Future<CipherOverviewData> decrypt(Uint8List blob) async {
    final payload = EncryptedPayload(blob);
    final plain = await AppCrypto.decrypt(payload);
    final json = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
    return CipherOverviewData.fromJson(json);
  }

  /// 单条解密失败时返回占位，不向上抛出。
  static Future<CipherOverviewData> decryptOrFallback(Uint8List blob) async {
    try {
      return await decrypt(blob);
    } on Object {
      return CipherOverviewData.fallback;
    }
  }
}
