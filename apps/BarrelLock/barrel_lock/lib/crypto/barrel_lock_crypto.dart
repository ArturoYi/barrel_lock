import 'package:core/core.dart';

import 'master_key_store.dart';

/// BarrelLock 加解密引导入口。
///
/// 在 [SPStorage.init] 之后调用，完成主密钥加载与 [AppCrypto] 初始化。
final class BarrelLockCrypto {
  BarrelLockCrypto._();

  /// 加载固定主密钥，并初始化全局 [AppCrypto] 单例。
  static Future<void> init() async {
    AppCrypto.init(secretKeyBytes: MasterKeyStore.load());
  }
}
