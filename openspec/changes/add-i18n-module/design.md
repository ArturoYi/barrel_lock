## Context

### 当前状态

| 维度 | 现状 |
|---|---|
| UI 文案 | 硬编码中文/英文分散在 `apps/barrel_lock`、`apps/*/lib/pages/`、`packages/fast_*` |
| `MaterialApp` | `ThemedApp` 已接入主题（`themeSettingsProvider`），**无** `localizationsDelegates` / `locale` |
| 偏好存储 | `AppPreference` + `PreferenceKeys` 管理 theme；**无** locale key |
| 包结构 | Melos workspace；共享基础设施在 `packages/`（如 `core`、`app_fonts`） |

### 约束

- Monorepo：新包须登记根 `workspace:`，子包 `resolution: workspace`
- 状态管理：Riverpod 3.x，偏好层对齐 `ThemeNotifier` / `ThemeRepository` 模式
- 六端共享：`barrel_lock` Feature + 各平台 View；l10n 资源须可被 `barrel_lock`、`barrel_lock_ui`、`core` 依赖
- CI：`melos run ci` 必须通过；生成代码纳入版本库或 CI 生成（见 D2）

## Goals / Non-Goals

**Goals:**

- 独立 `packages/app_l10n` 作为翻译 SSOT，支持 `zh` / `en`
- 用户可在设置中选择「跟随系统 / 简体中文 / English」，即时生效并持久化
- `ThemedApp` 正确接线 Flutter 本地化；Widget 通过统一 API 取文案
- 首版完成基础设施 + 核心路径字符串迁移（设置、Tab、404、启动/锁屏等高频 UI）
- 为后续 Feature 迁移提供 ARB 命名规范与任务模板

**Non-Goals:**

- 一次性迁移全部 ~200+ 文件中的硬编码字符串
- `fast_toast` / `fast_dialog` 等通用包的内置默认文案（后续独立 change）
- RTL、复数/性别复杂语法专项（ARB 预留 `@plural` 能力即可）
- 云端翻译工作流、Crowdin/Lokalise 集成
- 用户数据（vault 名、密码标题）自动翻译

## Decisions

### D1：独立包 `packages/app_l10n`，不放入 `core`

```
packages/app_l10n/
├── lib/
│   ├── app_l10n.dart              # library + export
│   ├── l10n/
│   │   ├── app_zh.arb             # template locale
│   │   ├── app_en.arb
│   │   └── app_localizations.dart # flutter gen-l10n 生成
│   └── src/
│       └── app_l10n_x.dart        # BuildContext extension
├── l10n.yaml
└── pubspec.yaml
```

**理由**：翻译资源体积大、变更频繁，与 `core`（存储/加密/主题）职责分离；`app_fonts` 已有先例。

**备选**：放入 `core` — 耦合过重，拖慢 `core` analyze/test。

### D2：官方 `flutter gen-l10n` + ARB，不用第三方 i18n 框架

`pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any

flutter:
  generate: true
```

`l10n.yaml`:

```yaml
arb-dir: lib/l10n
template-arb-file: app_zh.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
nullable-getter: false
```

**理由**：Flutter 一等公民、Material/Cupertino 组件本地化兼容、`intl` 与日期/数字格式一致。

**备选**：`slang` / `easy_localization` — 额外依赖与代码风格偏离团队惯例。

**生成物策略**：**提交生成代码**到 git（与多数 Flutter 项目一致），避免 CI 未跑 `flutter gen-l10n` 导致 analyze 失败；本地改 ARB 后执行 `fvm flutter gen-l10n`（或在 `packages/app_l10n` 下 `flutter pub get` 触发）。

### D3：ARB key 命名与分层

| 前缀 | 用途 | 示例 |
|---|---|---|
| `common_` | 通用动作/状态 | `common_cancel`, `common_save`, `common_error` |
| `settings_` | 设置页 | `settings_language`, `settings_theme_mode` |
| `tab_` | 底部/主导航 | `tab_password`, `tab_settings` |
| `cipher_` | 密码相关 Feature | `cipher_add_title` |
| `migration_` | 数据迁移 | `migration_merge_import` |
| `support_` | 帮助/反馈 | `support_feedback_title` |

- 带参数用 ARB placeholders：`greeting(name)` → `"你好，{name}"`
- 同一语义只保留一个 key；View 禁止复制粘贴字面量

**Model/ViewModel 层**：优先在 View 层本地化；Model 返回 **message key + args** 或 enum，View 再 `context.l10n` 渲染（避免 Model 依赖 `BuildContext`）。

### D4：`core` 内 `locale/` 域，镜像 `theme/`

```dart
enum AppLocalePreference {
  system,  // 跟随系统
  zh,      // 简体中文
  en,      // English
}

final class LocaleSettings {
  final AppLocalePreference preference;
  Locale? get resolvedLocale => ...; // system 时读 PlatformDispatcher
}

class LocaleNotifier extends Notifier<LocaleSettings> { ... }
final localeSettingsProvider = NotifierProvider<LocaleNotifier, LocaleSettings>(...);
```

- `PreferenceKeys.localePreference` → SP 字符串 `'system' | 'zh' | 'en'`
- `LocaleRepository` / `LocaleRepositoryImpl` 对齐 `ThemeRepositoryImpl`
- `core.dart` re-export `app_l10n` + locale providers（消费方 `import 'package:core/core.dart'` 即可）

### D5：`ThemedApp` 本地化接线

```dart
MaterialApp.router(
  locale: settings.resolvedLocale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  localeResolutionCallback: AppLocalizations.resolveLocale,
  // ...existing theme/router
)
```

`AppLocalizations.resolveLocale`（在 `app_l10n` 实现）：

1. 若用户选 `zh` / `en` → 返回对应 `Locale`
2. 若 `system` → 用 `WidgetsBinding.instance.platformDispatcher.locale`
3. 不支持的语言 → 回退 `Locale('zh')`

`AppLocalizations.localizationsDelegates` 包含：

- `AppLocalizations.delegate`
- `GlobalMaterialLocalizations.delegate`
- `GlobalWidgetsLocalizations.delegate`
- `GlobalCupertinoLocalizations.delegate`

### D6：`BuildContext` 扩展

```dart
// packages/app_l10n/lib/src/app_l10n_x.dart
extension AppL10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
```

Widget 用法：`Text(context.l10n.settingsLanguage)`。

**无 Context 场景**（如 isolate、纯 Dart test）：注入 `AppLocalizations` 或使用 lookup 函数 `lookupAppLocalizations(locale)`。

### D7：分阶段字符串迁移

| 阶段 | 范围 | 目标 |
|---|---|---|
| **M0 基础设施** | `app_l10n` + `core/locale` + `ThemedApp` + 设置语言 Tile | 可切换语言，UI 部分生效 |
| **M1 壳层与导航** | Tab 标签、404、通用按钮、设置分组标题 | 主导航全本地化 |
| **M2 核心 Feature** | `cipher_add`、`password_tab`、`app_lock`、`backup_manage` | 主流程无硬编码中文 |
| **M3 六端 View 扫尾** | `apps/*/lib/pages/` 剩余字面量 | 各端 View 对齐 |
| **M4 长文案** | `support_document_content` 等 Markdown/帮助 | 按文档块拆分 key 或独立 `.md` per locale（后续细化） |

本 change **实现 M0–M2**；M3–M4 在 tasks 中列后续项，可在 follow-up change 完成。

### D8：设置页语言 UI

对齐 `ThemeSettingTile`：`LocaleSettingTile`（各平台 settings 目录），`SegmentedButton<AppLocalePreference>` 三档。

显示名用 **各语言自称**（非全部走 l10n，避免循环）：

- 跟随系统 → 仍用 l10n key `locale_follow_system`
- 简体中文 → 固定 `'简体中文'`
- English → 固定 `'English'`

## Risks / Trade-offs

| 风险 | 缓解 |
|---|---|
| 大 MR 若一次性替换全部字符串 | 分阶段 M0–M4；PR 可按 milestone 拆分 |
| ViewModel 错误信息硬编码 | 规范：返回 error code enum，View 映射 l10n |
| 生成代码与 ARB 不同步 | 改 ARB 后必跑 gen-l10n；可选 CI script 检查 |
| `MaterialApp` 重建导致路由状态丢失 | `locale` 变更仅触发 `ThemedApp` rebuild；`RouterConfig` 保持同一实例 |
| 六端 View 重复 Tile | 首版各端复制 `LocaleSettingTile`（与 theme 一致）；后续可抽到 `barrel_lock_ui` |
| 帮助文档等大段中文 | M4 单独处理；首版保留中文或拆 key |

## Migration Plan

1. 创建 `app_l10n` 包 + 登记 workspace + `dart pub get`
2. 添加 `core` locale 域 + `PreferenceKeys` 扩展（旧用户默认 `system`）
3. 接线 `ThemedApp`；验证系统语言 en/zh 切换
4. 添加 `LocaleSettingTile` + 初始 ARB keys
5. 按 M1→M2 逐 Feature 替换字符串；每批跑 `melos run ci`
6. **Rollback**：移除 `locale` 接线与 Tile；SP key 可保留（无害）

## Open Questions

1. **M4 帮助文档**：长 Markdown 是继续 ARB 多 key，还是 `assets/docs/{locale}/` 分文件？→ 建议 follow-up 用 assets，本 change 不动 `support_document_content.dart` 正文。
2. **默认回退语言**：产品确认默认 `zh`（大陆用户为主）— 已在 proposal 采纳。
3. **`barrel_lock_ui` 是否 export l10n**：通过 `core` re-export 即可，无需重复。
