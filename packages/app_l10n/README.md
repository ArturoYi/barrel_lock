# app_l10n

BarrelLock 多语言资源包（翻译 SSOT）。

## 支持语言

- 简体中文（`app_zh.arb`，模板）
- 繁体中文（`app_zh_TW.arb`）
- English（`app_en.arb`）
- العربية（`app_ar.arb`）

## 添加文案

1. 在 `lib/l10n/app_zh.arb` 添加 key（遵循前缀：`common_`、`settings_`、`tab_` 等）
2. 同步 `app_en.arb`、`app_zh_TW.arb`、`app_ar.arb`（可运行 `scripts/check_arb_parity.sh`）
3. 在本目录执行：

```bash
fvm flutter gen-l10n
```

4. 根目录执行 `melos run format`

## 使用

```dart
import 'package:core/core.dart'; // 或 package:app_l10n/app_l10n.dart

Text(context.l10n.common_cancel);
```

## 无 Context 访问

ViewModel / Coordinator / 后台回调：

```dart
AppL10n.current.common_save;
AppL10nHolder.update(const Locale('en'));
```

`LocaleNotifier` 与 `ThemedApp` 会在 locale 变化时同步 `AppL10nHolder`。

## Toast / Loading

在 `apps/barrel_lock` 使用 `OverlayL10n`：

```dart
import 'package:barrel_lock/barrel_lock.dart';

OverlayL10n.successToast((l) => l.cipher_addedToast);
OverlayL10n.showLoading(); // 默认 overlay_loading
```

## 语言切换

设置 → **通用** → **语言** → 专用选择页（跟随系统 + 四语言）。偏好由 `localeSettingsProvider` 持久化。

## 回退规则

系统语言不在支持列表时，回退至简体中文。`zh_TW` / Hant 映射繁体，其余 `zh*` 映射简体。

## RTL

阿拉伯语下 `ThemedApp` 显式设置 RTL；自定义布局请使用 `EdgeInsetsDirectional` / `AlignmentDirectional`。
