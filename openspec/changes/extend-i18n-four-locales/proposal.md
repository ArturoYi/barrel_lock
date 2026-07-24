## Why

`add-i18n-module` 已落地 `packages/app_l10n` 与 zh/en 基础设施，但业务层仍依赖 `BuildContext` 取文案，`FastToast` / `FastLoading` 等无 Context 场景无法统一本地化；设置页语言入口藏在「外观」分组内且仅支持两种语言。产品现需覆盖简体/繁体中文、英语与阿拉伯语用户，并在 iOS/Android 原生层声明 locale 与权限说明文案，避免系统弹窗与 App 语言不一致。

## What Changes

- **BREAKING** 扩展 `AppLocalePreference` 与 SP 存储：跟随系统、简体中文、繁体中文、English、العربية；旧值 `zh` 迁移为 `zh_hans`
- 新增 **无 Context 全局访问**：`AppL10n.current`（或等价 API）与 `LocaleNotifier` 同步，供 ViewModel / Coordinator / 纯 Dart 层使用
- `FastToast` / `FastLoading` 增加 l10n 友好 API（内置常用文案 key 或 `AppLocalizations` 回调），默认消息随当前语言切换
- 设置页增加**独立「语言」导航项**（默认可读当前语言摘要），进入语言选择页/Sheet；默认偏好仍为跟随系统
- `app_l10n` 新增 ARB：`app_zh_TW.arb`（繁体）、`app_ar.arb`（阿拉伯语）；调整 locale 解析区分 `zh`/`zh_CN` 与 `zh_TW`；阿拉伯语启用 RTL
- iOS：声明 `CFBundleLocalizations`；为权限 key 提供 `InfoPlist.strings`（en、zh-Hans、zh-Hant、ar）
- Android：配置 `resConfigs` / locale 资源；补充各语言 `strings.xml`（应用 label、插件可见的权限 rationale 文案等）
- 将 `add-i18n-module` 未完成 M2 字符串迁移与本 change 任务对齐（按 Feature 分批，不阻塞本 change 核心交付）

## Capabilities

### New Capabilities

- `l10n-global-access`: 无 Context 的全局 `AppLocalizations` 访问、与 Riverpod locale 状态同步、启动/切换时更新
- `l10n-four-locales`: 四语言 ARB、gen-l10n、`localeResolutionCallback` 与 RTL 支持
- `settings-language-entry`: 设置 Tab 独立「语言」入口、选择 UI、即时生效与持久化
- `l10n-overlay-messages`: `FastToast` / `FastLoading` 接入当前 locale 的默认与便捷 API
- `native-platform-locales`: iOS/Android 原生 locale 声明与权限/系统可见文案多语言

### Modified Capabilities

（无 archive 存量 spec；本 change 以 delta spec 自洽，构建于 `add-i18n-module` 已交付部分之上）

## Impact

- **packages/app_l10n**：新 ARB、生成代码、`AppL10n` 全局 holder、`resolveLocale` 升级
- **packages/core**：`AppLocalePreference` 扩展、迁移逻辑、`ThemedApp` RTL
- **packages/fast_toast**、**packages/fast_loading**：可选 l10n delegate / 包装 API（依赖 `app_l10n` 或 core re-export）
- **apps/barrel_lock_ui**：语言选择页/Sheet；设置 Model 新增 `language` 导航项
- **apps/barrel_lock**：Coordinator 路由；ViewModel 改用 `AppL10n.current`
- **apps/ios**、**apps/android**：Info.plist / `strings.xml` 多语言资源
- **依赖**：确认 `flutter_localizations` 对 `ar` 的 Material/Cupertino 支持；阿拉伯语 UI 需抽查 RTL 布局
- **Out of scope**：完整 M3 六端 View 扫尾、Crowdin 集成、动态语言包下载
