/// 存储层常量，与 [密码App数据表设计.md](密码App数据表设计.md) 对齐。
library;

/// 密码条目 [CipherEntries.type] 枚举。
abstract final class CipherType {
  static const int websiteLogin = 1;
  static const int bankCard = 2;
  static const int identityDocument = 3;
  static const int secureNote = 4;
  static const int sshKey = 5;
  static const int appAccount = 6;
}
