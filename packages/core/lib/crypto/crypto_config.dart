import 'package:cryptography/cryptography.dart';

/// ChaCha20-Poly1305 AEAD 密钥配置。
///
/// 由 [AppCrypto.init] 在 App 启动时注入一次；业务层不应直接访问此类。
///
/// ## 密钥约束
///
/// - 长度固定 32 字节（256-bit），对应 RFC 8439 ChaCha20-Poly1305
/// - 密钥材料由调用方传入，本类仅持有 [SecretKey] 引用，不做持久化
/// - [reset] 仅用于测试 teardown，生产环境勿调用
final class CryptoConfig {
  CryptoConfig._();

  /// ChaCha20-Poly1305 标准密钥长度（256-bit）。
  static const int secretKeyLength = 32;

  static SecretKey? _secretKey;

  /// 注入对称密钥，进程生命周期内仅允许调用一次。
  ///
  /// 重复调用抛 [StateError]；长度不符抛 [ArgumentError]。
  static void init({required List<int> secretKeyBytes}) {
    if (_secretKey != null) {
      throw StateError('CryptoConfig 已初始化，禁止重复 init');
    }
    if (secretKeyBytes.length != secretKeyLength) {
      throw ArgumentError.value(
        secretKeyBytes.length,
        'secretKeyBytes',
        'ChaCha20-Poly1305 要求 $secretKeyLength 字节（256-bit）密钥',
      );
    }
    // SecretKey 为不透明句柄，避免调用方反复读取原始字节。
    _secretKey = SecretKey(secretKeyBytes);
  }

  /// 当前会话密钥；未 [init] 时抛 [StateError]。
  static SecretKey get secretKey {
    if (_secretKey == null) {
      throw StateError('CryptoConfig 未初始化，请在 main 先执行 AppCrypto.init()');
    }
    return _secretKey!;
  }

  /// 测试专用：释放密钥引用（不保证安全擦除内存）。
  static void reset() {
    _secretKey = null;
  }
}
