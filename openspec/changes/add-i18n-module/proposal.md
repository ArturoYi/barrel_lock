## Why

BarrelLock 当前 UI 文案以硬编码中文/英文字符串分散在 `barrel_lock`、六端 View 与部分 `packages/` 中，无法切换语言，也不利于协作维护与 CI 校验缺失翻译。随着产品面向更广用户群，需要抽离独立多语言模块、统一接入 Flutter 本地化体系，并为后续逐模块迁移提供稳定基础设施。

## What Changes

- 新建 workspace 包 `packages/app_l10n`：集中维护 ARB 资源、`flutter gen-l10n` 代码生成与统一 export
- 在 `packages/core` 增加语言偏好（跟随系统 / 简体中文 / English），持久化至 SP，Riverpod `LocaleNotifier` 对齐现有 `ThemeNotifier` 模式
- 扩展 `ThemedApp`（`MaterialApp.router`）：注入 `localizationsDelegates`、`supportedLocales`、`locale` 与 `localeResolutionCallback`
- 设置页增加「语言」入口，切换后即时生效（无需重启）
- 提供 `BuildContext` 便捷访问（如 `context.l10n`）与命名规范，禁止业务层继续硬编码用户可见文案
- 首版迁移范围：`barrel_lock` 共享 Feature 与 `barrel_lock_ui` 壳层的高频 UI；六端 View 与 `fast_*` 包分阶段跟进（tasks 中分里程碑）
- 首版支持语言：**简体中文（zh）**、**English（en）**；默认跟随系统，系统语言不在支持列表时回退 **zh**

## Capabilities

### New Capabilities

- `app-l10n`: 独立 l10n 包结构、ARB 资源、代码生成、`AppLocalizations` API 与 workspace 登记
- `locale-preference`: 语言偏好域模型、SP 持久化、Riverpod 状态与设置页切换
- `localized-app-shell`: `ThemedApp` / 根 Widget 本地化接线、`localeResolutionCallback` 与 `context.l10n` 访问约定

### Modified Capabilities

（无 archive 存量 spec；本 change 以 delta spec 自洽）

## Impact

- **packages/app_l10n**（新）：ARB、`l10n.yaml`、生成代码、`app_l10n.dart` 入口
- **packages/core**：`PreferenceKeys`、`AppPreference`、新 `locale/` 域（settings + notifier）；可选在 `core.dart` re-export `app_l10n`
- **apps/barrel_lock**：`ThemedApp` 接线；Feature 层逐步替换硬编码字符串
- **apps/barrel_lock_ui**：`runBarrelLockApp` 启动链若需 locale 引导则扩展
- **六端 apps/**：设置页语言 Tile；各 `lib/pages/` View 字符串迁移（分阶段）
- **根 pubspec.yaml**：`workspace:` 登记 `packages/app_l10n`
- **CI / 开发**：`melos run format`；可选 ARB 完整性检查脚本；文档更新 `.cursor/rules`
- **Out of scope（本 change）**：RTL 布局专项、翻译管理平台集成、用户自定义翻译、数据库内用户数据（vault 名等）的自动翻译
