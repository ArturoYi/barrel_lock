import 'dart:convert';

/// 密文载荷值对象。
///
/// 承载 ChaCha20-Poly1305 加密后的拼接字节，布局为：
///
/// ```
/// nonce (12 B) ‖ ciphertext (变长) ‖ MAC (16 B)
/// ```
///
/// 可通过 [toBase64] / [fromBase64] 与字符串存储互转。
/// 调用方请勿就地修改 [bytes]，以免破坏 MAC 校验。
final class EncryptedPayload {
  const EncryptedPayload(this.bytes);

  /// 原始拼接字节（nonce ‖ ciphertext ‖ MAC）。
  final List<int> bytes;

  /// 从标准 Base64 解码构建载荷。
  ///
  /// 非法 Base64 抛 [FormatException]。
  factory EncryptedPayload.fromBase64(String encoded) {
    return EncryptedPayload(base64Decode(encoded));
  }

  /// 编码为标准 Base64，便于 SP / JSON 字段存储。
  String toBase64() => base64Encode(bytes);
}
