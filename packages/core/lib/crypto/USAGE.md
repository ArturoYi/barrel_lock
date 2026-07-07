# AppCrypto 使用说明

`packages/core/lib/crypto/` 提供基于 [cryptography](https://pub.dev/packages/cryptography) 的 ChaCha20-Poly1305 AEAD 加解密能力，对外唯一入口为 `AppCrypto`。

## 架构概览

```
App 启动层（密钥派生 / 安全存储）
        │
        ▼
   AppCrypto.init(secretKeyBytes)     ← 业务唯一入口
        │
        ├── ChaCha20Poly1305Cipher     ← 算法实现（内部）
        ├── CryptoConfig               ← 密钥单例（内部）
        └── EncryptedPayload           ← 密文值对象
```

| 层 | 类 | 职责 |
|---|---|---|
| Facade | `AppCrypto` | 初始化、加解密 API |
| Domain | `EncryptedPayload` | 密文载体（nonce ‖ ciphertext ‖ MAC） |
| Infrastructure | `ChaCha20Poly1305Cipher` | 封装 `Chacha20.poly1305Aead()` |
| Config | `CryptoConfig` | 32 字节密钥校验与持有 |

## 算法说明

- **算法**：`Chacha20.poly1305Aead()`（RFC 8439 AEAD_CHACHA20_POLY1305）
- **密钥**：256-bit（32 字节），由 App 层传入，core **不持久化**密钥
- **Nonce**：每次加密自动生成 12 字节随机 nonce（勿复用）
- **认证**：Poly1305 MAC（16 字节），解密时自动校验完整性；篡改或密钥错误会认证失败

### 密文字节布局

```
┌──────────────┬─────────────────┬─────────────┐
│ nonce (12 B) │ ciphertext (变长) │ MAC (16 B)  │
└──────────────┴─────────────────┴─────────────┘
```

字符串 API 将上述拼接字节做 **标准 Base64** 编码，便于写入 SharedPreferences / JSON。

## 快速开始

### 1. 引入

```dart
import 'package:core/core.dart';
```

### 2. 启动时初始化（一次）

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 密钥由 App 负责：安全存储读取、Argon2id/HKDF 派生等
  final masterKey = await loadOrDeriveMasterKey(); // 必须 32 字节
  AppCrypto.init(secretKeyBytes: masterKey);

  await SPStorage.init(...);
  runApp(const ProviderScope(child: MyApp()));
}
```

`init` 内部会调用 `FlutterCryptography.registerWith()`，在 Android / iOS / macOS 上优先使用系统原生 Crypto API。

### 3. 加解密

**字节流**（适合二进制、Drift BLOB）：

```dart
import 'dart:convert';

final payload = await AppCrypto.encrypt(utf8.encode('secret data'));
final plain = await AppCrypto.decrypt(payload);
final text = utf8.decode(plain);
```

**字符串 + Base64**（适合 SP / JSON 字段）：

```dart
final cipher = await AppCrypto.encryptString('敏感配置项');
await SPStorage.setString('encrypted_setting', cipher);

final stored = SPStorage.getString('encrypted_setting');
if (stored != null) {
  final plain = await AppCrypto.decryptString(stored);
}
```

**密文持久化**（`EncryptedPayload` ↔ Base64）：

```dart
final payload = await AppCrypto.encrypt([1, 2, 3]);
final base64 = payload.toBase64();          // 落库
final restored = EncryptedPayload.fromBase64(base64);
final bytes = await AppCrypto.decrypt(restored);
```

## API 参考

| 方法 | 说明 |
|---|---|
| `AppCrypto.secretKeyLength` | 常量 `32` |
| `AppCrypto.init({required List<int> secretKeyBytes})` | 注入密钥，仅允许一次 |
| `AppCrypto.encrypt(List<int>)` | 加密字节，返回 `EncryptedPayload` |
| `AppCrypto.decrypt(EncryptedPayload)` | 解密字节 |
| `AppCrypto.encryptString(String)` | 加密字符串，返回 Base64 |
| `AppCrypto.decryptString(String)` | 解密 Base64 字符串 |
| `AppCrypto.reset()` | **仅测试**：释放单例状态 |

## 异常与错误处理

| 场景 | 异常 |
|---|---|
| 未调用 `init` 就加解密 | `StateError` |
| 密钥长度不是 32 字节 | `ArgumentError` |
| 重复 `init` | `StateError` |
| 密文被篡改 / 密钥不匹配 | `SecretBoxAuthenticationError`¹ |
| Base64 格式非法 | `FormatException` |
| 密文长度不足 | `ArgumentError` |

¹ `SecretBoxAuthenticationError` 定义在 `package:cryptography`，如需类型化捕获：

```dart
import 'package:cryptography/cryptography.dart';

try {
  await AppCrypto.decrypt(payload);
} on SecretBoxAuthenticationError {
  // 密文不可信
}
```

## 密钥管理建议（App 层职责）

core 只消费 32 字节对称密钥，**不负责**以下工作，需在 App / 产品层实现：

1. **首次启动**：生成随机 32 字节主密钥，写入平台安全存储（Keychain / Keystore / TPM 等）
2. **用户口令**：用 Argon2id 等 KDF 从口令派生密钥，勿直接哈希口令当密钥
3. **密钥轮换**：需自定义版本号字段，旧数据用旧密钥解密后再用新密钥加密
4. **内存清理**：Dart 无安全擦除 API；敏感 `List<int>` 用毕尽快置空引用，降低残留窗口

## 安全注意事项

- **禁止**硬编码密钥或把密钥提交进仓库
- **禁止**复用 nonce；本模块每次加密自动生成，调用方勿手动拼 nonce
- **禁止**在日志中打印密钥、明文或完整密文
- 当前版本**不支持 AAD**（附加认证数据）；若需绑定上下文（如 userId），后续版本可扩展
- 极高吞吐场景可考虑升级为 `Xchacha20.poly1305Aead()`（24 字节 nonce，随机 nonce 碰撞风险更低）

## 测试

```bash
cd packages/core
fvm flutter test test/crypto_test.dart
```

测试中使用确定性随机源保证可重复：

```dart
Cryptography.instance = Cryptography.instance.withRandom(
  SecureRandom.forTesting(seed: 42),
);
AppCrypto.reset();
AppCrypto.init(secretKeyBytes: List<int>.filled(32, 7));
```

## 依赖

```yaml
cryptography: ^2.9.0
cryptography_flutter: ^2.3.4  # Flutter 平台原生加速
```
