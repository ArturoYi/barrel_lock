import 'barrel_lock_master_key.dart';

/// 主密钥存取入口。
///
/// 当前返回固定常量 [BarrelLockMasterKey.bytes]；
/// 后续可在此切换为 Keychain / Keystore 或 KDF 派生实现。
final class MasterKeyStore {
  MasterKeyStore._();

  /// 返回应用主密钥（32 字节）。
  static List<int> load() {
    BarrelLockMasterKey.ensureValid();
    return List<int>.from(BarrelLockMasterKey.bytes);
  }
}
