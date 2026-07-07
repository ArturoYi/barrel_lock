import 'package:cryptography_flutter/cryptography_flutter.dart';

import 'chacha20_poly1305_cipher.dart';
import 'crypto_config.dart';
import 'encrypted_payload.dart';

/// 全局加解密单例门面，App 启动时初始化一次。
///
/// ## 算法
///
/// ChaCha20-Poly1305 AEAD（RFC 8439）：机密性 + 完整性一体，解密时自动验 MAC。
///
/// ## 初始化
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   AppCrypto.init(secretKeyBytes: await loadMasterKey());
///   runApp(const ProviderScope(child: MyApp()));
/// }
/// ```
///
/// ## 使用
///
/// ```dart
/// // 字节
/// final payload = await AppCrypto.encrypt(utf8.encode('secret'));
/// final plain = await AppCrypto.decrypt(payload);
///
/// // 字符串（Base64，适合 SP）
/// final cipher = await AppCrypto.encryptString('敏感项');
/// final text = await AppCrypto.decryptString(cipher);
/// ```
///
/// 详细说明见 [USAGE.md](USAGE.md)。
///
/// ## 安全边界
///
/// - 密钥派生、安全存储、轮换策略由 **App 层** 负责
/// - core 不持久化密钥，不记录明文/密文日志
/// - 认证失败时抛 [SecretBoxAuthenticationError]（来自 `package:cryptography`）
final class AppCrypto {
  AppCrypto._();

  /// ChaCha20-Poly1305 标准密钥长度（256-bit）。
  static const int secretKeyLength = CryptoConfig.secretKeyLength;

  /// 初始化全局加解密单例。
  ///
  /// [secretKeyBytes] 必须为 [secretKeyLength] 字节，由 App 从安全存储或 KDF 派生。
  /// 进程内仅允许调用一次；重复调用抛 [StateError]。
  ///
  /// 内部会注册 [FlutterCryptography] 以启用平台原生加速。
  static void init({required List<int> secretKeyBytes}) {
    FlutterCryptography.registerWith();
    CryptoConfig.init(secretKeyBytes: secretKeyBytes);
  }

  /// 加密字节序列。
  ///
  /// 返回含随机 nonce 的 [EncryptedPayload]，同一明文每次加密结果不同。
  static Future<EncryptedPayload> encrypt(List<int> plainText) {
    return ChaCha20Poly1305Cipher.encrypt(plainText);
  }

  /// 解密 [EncryptedPayload] 为原始字节。
  ///
  /// 密文被篡改或密钥不匹配时抛 [SecretBoxAuthenticationError]。
  static Future<List<int>> decrypt(EncryptedPayload payload) {
    return ChaCha20Poly1305Cipher.decrypt(payload);
  }

  /// 加密字符串，返回标准 Base64 密文（便于 SP / JSON 存储）。
  static Future<String> encryptString(String plainText) {
    return ChaCha20Poly1305Cipher.encryptToBase64(plainText);
  }

  /// 解密 [encryptString] 产出的 Base64 密文。
  static Future<String> decryptString(String encryptedBase64) {
    return ChaCha20Poly1305Cipher.decryptFromBase64(encryptedBase64);
  }

  /// 测试专用：释放单例状态，允许后续重新 [init]。
  static void reset() {
    CryptoConfig.reset();
  }
}
