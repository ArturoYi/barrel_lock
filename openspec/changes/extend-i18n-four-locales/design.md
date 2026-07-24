## Context

### 已有基础（`add-i18n-module` 已交付 / 进行中）

| 组件 | 状态 |
|---|---|
| `packages/app_l10n` | ARB zh/en、`context.l10n`、`AppL10n.localizationsDelegates` |
| `LocaleNotifier` + SP | 仅 `system` / `zh` / `en` |
| 设置 UI | `LocaleSettingTile` 嵌在「外观」分组 SegmentedButton |
| `FastToast` / `FastLoading` | 接收调用方传入的 **已翻译字符串**，无 locale 感知 |
| iOS `Info.plist` | 权限说明为硬编码简体中文；无 `CFBundleLocalizations` |
| Android | 无 `values-*` 多语言资源 |

### 约束

- Monorepo：`app_l10n` 仍为翻译 SSOT；`core` re-export
- Riverpod 3.x：`LocaleNotifier` 为语言真源
- `fast_*` 包可被 `app_l10n` 依赖（或经 thin wrapper 避免循环）
- 六端 Android/iOS 为权限与系统弹窗的主要目标平台
- Flutter 3.44.2 + `flutter gen-l10n`

## Goals / Non-Goals

**Goals:**

- 四语言完整 ARB 与运行时切换：简体 `zh`/`zh_CN`、繁体 `zh_TW`、英语 `en`、阿拉伯语 `ar`
- 无 Context 访问：`AppL10n.current` 在 ViewModel/Coordinator/后台回调中取当前 `AppLocalizations`
- Toast/Loading 提供 `*L10n` 便捷 API 与内置默认文案（加载中、成功、失败等）
- 设置 Tab **独立「语言」入口**，展示当前选项摘要，进入专用选择页
- iOS/Android 原生声明支持语言；权限相关系统文案随 locale 显示
- 阿拉伯语基础 RTL：`MaterialApp` 正确设置 `locale` 与 text direction

**Non-Goals:**

- 一次性翻译全部 Feature 硬编码（延续 `add-i18n-module` M2 分批）
- 云端翻译、OTA 语言包
- Web/Desktop 原生权限字符串（本 change 聚焦 ios/android 工程目录）
- 阿拉伯语全量 UI 视觉验收（首版保证 RTL 不崩、核心路径可读）

## Decisions

### D1：四语言 Locale 与 ARB 文件

| 语言 | ARB 文件 | `Locale` | `AppLocalePreference` |
|---|---|---|---|
| 简体中文（模板） | `app_zh.arb` | `Locale('zh')` 或 `Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans')` | `zhHans` |
| 繁体中文 | `app_zh_TW.arb` | `Locale('zh', 'TW')` | `zhHant` |
| English | `app_en.arb` | `Locale('en')` | `en` |
| العربية | `app_ar.arb` | `Locale('ar')` | `ar` |

`l10n.yaml` 保持 `template-arb-file: app_zh.arb`；新增 locale 文件后 `flutter gen-l10n`。

**存储迁移**：SP 值 `'zh'` → `'zh_hans'`（读取时兼容旧值）。

### D2：Locale 解析升级

`AppL10n.resolveLocale` 改为 **完整匹配**（language + script + country），不再仅比 `languageCode`：

1. 用户固定偏好 → 对应 `Locale`
2. `system` → `PlatformDispatcher.instance.locale`，映射到最近支持项
3. 无法映射 → 回退 `Locale('zh')`（简体）

简体/繁体区分：`zh_TW`/`Hant` → 繁体；其余 `zh*` → 简体。

### D3：无 Context 全局访问 — `AppL10nHolder`

```dart
// packages/app_l10n/lib/src/app_l10n_holder.dart
final class AppL10nHolder {
  static AppLocalizations get current => _current;
  static Locale get locale => _locale;
  static void update(Locale locale) {
    _locale = locale;
    _current = lookupAppLocalizations(locale);
  }
}
```

- `LocaleNotifier.setPreference` 与 `ThemedApp` build 后调用 `AppL10nHolder.update(resolvedLocale)`
- 对外 export 别名：`AppL10n.current` → `AppL10nHolder.current`
- **测试**：`AppL10nHolder.update(const Locale('en'))` 后断言文案

**备选**：InheritedWidget — 无法覆盖无 Element 的 isolate/回调，不采用。

### D4：`FastToast` / `FastLoading` l10n 集成

**策略**：在 `packages/app_l10n`（或 `core` 薄封装）提供 overlay 扩展，避免 `fast_toast` 硬依赖业务 ARB：

```dart
extension FastToastL10n on FastToast {
  static void successSaved() =>
      FastToast.success(AppL10n.current.cipher_addedToast);
}

// 或通用：
FastToast.showL10n(String Function(AppLocalizations l) pick);
FastLoading.showL10n(String Function(AppLocalizations l) pick);
```

新增 ARB keys（四语言同步）：

- `overlay_loading` — 加载中…
- `overlay_success` — 操作成功
- `overlay_error` — 操作失败
- `overlay_please_wait` — 请稍候

`FastLoading.show()` 无 message 时默认 `overlay_loading`；`FastToast` 文档引导业务使用 `showL10n` 或显式 `AppL10n.current`。

**依赖方向**：`app_l10n` 依赖 `fast_toast` / `fast_loading` **不推荐**（反向耦合）。采用 **`core` 或 `barrel_lock` 扩展方法** re-export，或 `app_l10n` 仅提供 `AppL10n` + 业务层 wrapper。推荐：

```
packages/app_l10n        → AppL10nHolder
apps/barrel_lock/lib/l10n/overlay_l10n.dart → FastToast/FastLoading 扩展
```

### D5：设置页独立「语言」入口

- `SettingsTabModel` 新增分组或在「外观」前增加 **通用** 分组，含 nav item `id: 'language'`
- 点击 → `LanguageSettingsCoordinator` → 路由 `/settings/language`
- UI：`LanguageSettingsPage`（各平台 View 或共享 `barrel_lock_ui`）
  - 列表：`RadioListTile` / `ListTile` 五档（跟随系统 + 四语言）
  - 副标题显示 native 语言名（简体中文 / 繁體中文 / English / العربية）
- 从「外观」内联 `LocaleSettingTile` **移除** SegmentedButton（避免重复），保留或迁移为仅主题

### D6：RTL（阿拉伯语）

```dart
MaterialApp.router(
  locale: resolvedLocale,
  // builder 内根据 locale.languageCode == 'ar' 设置 Directionality.rtl
  // 或使用 Localizations.localeOf(context) + material 内置支持
)
```

`ThemedApp` builder 外层检测 `Directionality.of`；阿拉伯语下抽查 Tab、设置列表、Toast 对齐。

### D7：iOS 原生多语言

**Info.plist** 增加：

```xml
<key>CFBundleLocalizations</key>
<array>
  <string>en</string>
  <string>zh-Hans</string>
  <string>zh-Hant</string>
  <string>ar</string>
</array>
```

**本地化权限字符串**（每种语言 `Runner/*.lproj/InfoPlist.strings`）：

| Key | 用途 |
|---|---|
| `NSFaceIDUsageDescription` | 生物识别 |
| `NSCameraUsageDescription` | 拍照 |
| `NSPhotoLibraryUsageDescription` | 相册 |
| `NSBluetoothAlwaysUsageDescription` | 蓝牙 |
| `NSLocalNetworkUsageDescription` | 本地网络 |

Xcode 工程注册 `zh-Hans.lproj`、`zh-Hant.lproj`、`en.lproj`、`ar.lproj`（Flutter 创建或手动添加）。

### D8：Android 原生多语言

`android/app/build.gradle`：

```gradle
android {
  defaultConfig {
    resConfigs "en", "zh-rCN", "zh-rTW", "ar"
  }
}
```

资源目录：

```
res/values/strings.xml           # 默认（简体或 en，与产品默认一致）
res/values-en/strings.xml
res/values-zh-rCN/strings.xml
res/values-zh-rTW/strings.xml
res/values-ar/strings.xml
```

内容至少包含：

- `app_name`（与 `android:label` 一致）
- 若 Kotlin/Swift 层或插件需要 rationale 文案，统一放 `strings.xml` 供原生代码 `@string/...` 引用

Manifest 中 `<application android:label="@string/app_name">`。

## Risks / Trade-offs

| 风险 | 缓解 |
|---|---|
| 四语言 ARB 量大、翻译质量 | 首版可简体为源、繁体由简体转换+人工校对要点；阿语核心路径优先 |
| 全局 `AppL10nHolder` 与测试污染 | 测试 teardown 重置 locale；文档说明仅在主 isolate 使用 |
| RTL 布局错位 | 阿语冒烟测试；复杂自定义 Row 后续迭代 |
| iOS lproj 与 Flutter gen-l10n 重复维护 | 权限文案仅放原生；Flutter UI 仅 ARB |
| **BREAKING** SP `zh` → `zh_hans` | `fromStorage` 兼容读取 |

## Migration Plan

1. 扩展 `AppLocalePreference` + 存储迁移 + `AppL10nHolder`
2. 添加 `app_zh_TW.arb`、`app_ar.arb`；补全四语言 keys；`gen-l10n`
3. 升级 `resolveLocale` + `ThemedApp` RTL
4. 设置页语言入口 + 路由 + 移除重复 Tile
5. `overlay_l10n.dart` + 迁移高频 Toast/Loading 调用
6. iOS/Android 原生资源与工程配置
7. `melos run ci`；真机验证权限弹窗语言

## Open Questions

1. **繁体翻译源**：是否接受 OpenCC 简→繁批量转换后人工抽检？→ 建议 tasks 中标注「简转繁 + 抽检」。
2. **Android 权限 rationale**：若全由 Flutter 插件处理，原生 `strings.xml` 仅 app_name；若自定义 MethodChannel 弹 rationale，再补 key。→ 首版覆盖 manifest label + 文档列出的 iOS 权限；Android 按需扩展。
