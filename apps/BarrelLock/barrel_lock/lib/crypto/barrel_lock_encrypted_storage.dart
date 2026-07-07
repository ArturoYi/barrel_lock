import 'package:core/core.dart';

/// BarrelLock 加密偏好存储，基于 [AppCrypto] + [SPStorage]。
///
/// 写入时自动加密，读取时自动解密；适合锁屏配置、敏感字段等。
final class BarrelLockEncryptedStorage {
  BarrelLockEncryptedStorage._();

  /// 加密并写入字符串。
  static Future<void> setString(String rawKey, String value) async {
    final encrypted = await AppCrypto.encryptString(value);
    await SPStorage.setString(rawKey, encrypted);
  }

  /// 读取并解密字符串；不存在时返回 `null`。
  ///
  /// 密文被篡改或密钥不匹配时抛 [SecretBoxAuthenticationError]。
  static Future<String?> getString(String rawKey) async {
    final stored = SPStorage.getString(rawKey);
    if (stored == null) {
      return null;
    }
    return AppCrypto.decryptString(stored);
  }

  /// 删除加密字段。
  static Future<void> remove(String rawKey) => SPStorage.remove(rawKey);
}
