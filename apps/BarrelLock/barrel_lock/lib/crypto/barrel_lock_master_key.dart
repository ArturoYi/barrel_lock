import 'dart:convert';

import 'package:core/core.dart';

/// BarrelLock 固定主密钥（32 字节 / 256-bit）。
///
/// 以 [value] 字符串为唯一配置源，[bytes] 由其 UTF-8 编码派生。
/// v1 开发阶段使用常量密钥，便于多设备调试与数据互通。
/// 生产环境须替换为用户口令 KDF 或平台安全存储派生的密钥。
abstract final class BarrelLockMasterKey {
  /// 主密钥明文（32 个 ASCII 字符 = 32 字节）。
  static const String value = 'BarrelLock-MasterKey-v1-Fixed32B';

  /// 供 [AppCrypto.init] 使用的字节形式。
  static List<int> get bytes => utf8.encode(value);

  /// Base64 编码，便于配置 / 日志引用（勿用于生产日志打印）。
  static String get base64 => base64Encode(bytes);

  static void ensureValid() {
    assert(
      bytes.length == AppCrypto.secretKeyLength,
      'BarrelLockMasterKey.value 编码后必须为 ${AppCrypto.secretKeyLength} 字节',
    );
  }
}
