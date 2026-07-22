import 'dart:convert';
import 'dart:typed_data';

import 'package:core/core.dart';

/// vault / folder 名称 BLOB 编解码，JSON 形状 `{"name":"<plaintext>"}`。
final class EncryptedNameCodec {
  EncryptedNameCodec._();

  static Future<Uint8List> encrypt(String name) async {
    final plain = utf8.encode(jsonEncode({'name': name}));
    final payload = await AppCrypto.encrypt(plain);
    return Uint8List.fromList(payload.bytes);
  }

  static Future<String> decrypt(Uint8List blob) async {
    final payload = EncryptedPayload(blob);
    final plain = await AppCrypto.decrypt(payload);
    final json = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
    return json['name'] as String? ?? '';
  }

  static Future<String> decryptOrFallback(Uint8List blob) async {
    try {
      return await decrypt(blob);
    } on Object {
      return '';
    }
  }
}
