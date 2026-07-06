# core

Flutter Bazaar monorepo **跨产品基础设施**（不含具体 App 业务）。

## 职责

| 模块 | 路径 | 说明 |
|---|---|---|
| 偏好 | `lib/preference/` | SPStorage、AppPreference、PreferenceKeys |
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

## 产品层请使用

- 路由 / 壳：`apps/BarrelLock/barrel_lock/`
- 启动入口：`apps/BarrelLock/barrel_lock_ui/`
- 页面 View：各平台 `lib/pages/`
