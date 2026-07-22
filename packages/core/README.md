# core

BarrelLock monorepo **基础设施**（主题/偏好/存储等，不含页面 View）。

## 职责

| 模块 | 路径 | 说明 |
|---|---|---|
| 偏好 | `lib/preference/` | SPStorage、AppPreference、PreferenceKeys |
| 加解密 | `lib/crypto/` | AppCrypto、ChaCha20-Poly1305 AEAD（见 [USAGE.md](lib/crypto/USAGE.md)） |
| 设备信息 | `lib/app_device_info/` | AppDeviceInfoReader、AppDeviceInfo |
| 主题 | `lib/theme/` | 配色、字体、ThemeNotifier |
| UI 框架 | re-export | fast_dialog / fast_loading / fast_toast / app_fonts |
| 状态 | re-export | flutter_riverpod |

## SP 初始化

```dart
await SPStorage.init(
  appNamespace: 'barrel_lock',
  env: 'prod',
  managedKeys: [...PreferenceKeys.allKeys, ...productKeys],
);
```

`clearAll` / `exportAll` 仅操作 `managedKeys` 白名单。

## 设备信息初始化

```dart
await AppDeviceInfo.init();
// 设置页只读展示
final label = AppDeviceInfo.versionLabel; // 1.2.3 (456)
```

`AppDeviceInfoReader` 为底层封装；业务请使用 `AppDeviceInfo`。

## 加解密初始化

```dart
// 32 字节主密钥由 App 层从安全存储 / KDF 获取
AppCrypto.init(secretKeyBytes: masterKey);

final cipher = await AppCrypto.encryptString('敏感配置');
final plain = await AppCrypto.decryptString(cipher);
```

完整说明、异常处理与密钥管理建议见 [`lib/crypto/USAGE.md`](lib/crypto/USAGE.md)。

## 产品层请使用

- 路由 / 壳：`apps/barrel_lock/`
- 启动入口：`apps/barrel_lock_ui/`
- 页面 View：各平台 `lib/pages/`
