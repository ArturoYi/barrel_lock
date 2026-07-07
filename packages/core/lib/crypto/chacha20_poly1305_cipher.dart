import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'crypto_config.dart';
import 'encrypted_payload.dart';

/// ChaCha20-Poly1305（AEAD）加解密实现。
///
/// 封装 [package:cryptography] 的 [Chacha20.poly1305Aead]：
///
/// - 加密：自动生成随机 nonce，输出 [SecretBox.concatenation]
/// - 解密：从拼接字节还原 [SecretBox] 并校验 Poly1305 MAC
///
/// 本类为内部实现，业务层请使用 [AppCrypto]。
final class ChaCha20Poly1305Cipher {
  ChaCha20Poly1305Cipher._();

  /// AEAD 算法单例；nonce 长度 12 字节，MAC 长度 16 字节。
  static final Cipher _algorithm = Chacha20.poly1305Aead();

  /// 加密字节序列，nonce 由算法自动随机生成。
  static Future<EncryptedPayload> encrypt(List<int> plainText) async {
    final secretBox = await _algorithm.encrypt(
      plainText,
      secretKey: CryptoConfig.secretKey,
    );
    return EncryptedPayload(secretBox.concatenation());
  }

  /// 解密载荷；认证失败抛 [SecretBoxAuthenticationError]。
  static Future<List<int>> decrypt(EncryptedPayload payload) async {
    final secretBox = SecretBox.fromConcatenation(
      payload.bytes,
      nonceLength: _algorithm.nonceLength,
      macLength: _algorithm.macAlgorithm.macLength,
    );
    return _algorithm.decrypt(secretBox, secretKey: CryptoConfig.secretKey);
  }

  /// 加密 UTF-8 字符串，返回标准 Base64 密文。
  static Future<String> encryptToBase64(String plainText) async {
    final secretBox = await _algorithm.encryptString(
      plainText,
      secretKey: CryptoConfig.secretKey,
    );
    return base64Encode(secretBox.concatenation());
  }

  /// 解密 Base64 密文为 UTF-8 字符串。
  ///
  /// 非法 Base64 抛 [FormatException]；认证失败抛 [SecretBoxAuthenticationError]。
  static Future<String> decryptFromBase64(String encryptedBase64) async {
    final bytes = base64Decode(encryptedBase64);
    final secretBox = SecretBox.fromConcatenation(
      bytes,
      nonceLength: _algorithm.nonceLength,
      macLength: _algorithm.macAlgorithm.macLength,
    );
    return _algorithm.decryptString(
      secretBox,
      secretKey: CryptoConfig.secretKey,
    );
  }
}
