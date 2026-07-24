## 1. 创建 `packages/app_l10n` 包（M0）

- [x] 1.1 新建 `packages/app_l10n/pubspec.yaml`：`resolution: workspace`；依赖 `flutter`、`flutter_localizations`、`intl`；`flutter: generate: true`
- [x] 1.2 新建 `l10n.yaml`：`template-arb-file: app_zh.arb`，`output-class: AppLocalizations`，`nullable-getter: false`
- [x] 1.3 新建 `lib/l10n/app_zh.arb`（模板）与 `app_en.arb`，初始 keys：`common_cancel`、`common_save`、`common_confirm`、`common_error`、`settings_language`、`settings_language_follow_system`、`locale_follow_system`
- [x] 1.4 执行 `fvm flutter gen-l10n`（在 `packages/app_l10n` 目录），提交生成文件 `app_localizations.dart` 及 `app_localizations_*.dart`
- [x] 1.5 新建 `lib/app_l10n.dart`（library export）与 `lib/src/app_l10n_x.dart`（`extension AppL10nX on BuildContext`）
- [x] 1.6 实现 `AppLocalizations.resolveLocale(Locale? deviceLocale, Iterable<Locale> supported, Locale? appPreferenceLocale)` 或在 extension 文件中提供 `resolveLocale` 静态方法（system / zh / en + 回退 zh）
- [x] 1.7 根 `pubspec.yaml` 的 `workspace:` 追加 `packages/app_l10n`；根目录 `dart pub get`
- [x] 1.8 新建 `analysis_options.yaml`（include flutter_lints）；`melos run format` + `melos run analyze` 验证新包

## 2. `core` 语言偏好域（M0）

- [x] 2.1 `PreferenceKeys` 新增 `localePreference`；更新 `allKeys` 白名单
- [x] 2.2 `AppPreference` 新增 `getLocalePreference()` / `setLocalePreference(String)`（存 `'system'|'zh'|'en'`）
- [x] 2.3 新建 `packages/core/lib/locale/domain/app_locale_preference.dart`：enum + `fromStorage` / `storageValue` + `resolvedLocale(Locale deviceLocale)`
- [x] 2.4 新建 `locale_settings.dart`、`locale_repository.dart`、`locale_repository_impl.dart`（镜像 theme 层）
- [x] 2.5 新建 `locale_notifier.dart` + `localeSettingsProvider`（`setPreference` 持久化并更新 state）
- [x] 2.6 在 `core.dart` export locale 域 + `app_l10n` 包（`export 'package:app_l10n/app_l10n.dart'`）
- [x] 2.7 `packages/core/pubspec.yaml` 添加 `app_l10n: path: ../app_l10n`；`dart pub get`
- [x] 2.8 新建 `packages/core/test/locale_settings_test.dart`：默认 system、save/load、resolvedLocale 回退逻辑

## 3. `ThemedApp` 本地化接线（M0）

- [x] 3.1 `themed_app.dart`：`ref.watch(localeSettingsProvider)` 计算 `Locale? activeLocale`
- [x] 3.2 `MaterialApp.router` / `MaterialApp` 增加 `locale`、`localizationsDelegates`、`supportedLocales`、`localeResolutionCallback`
- [x] 3.3 确认切换 locale 不重建 `RouterConfig`（`AppRouter.routerConfig` 仍为单例）
- [x] 3.4 手动验证：系统中文 / 系统英文 / 固定 zh / 固定 en 四种组合下 App 正常启动

## 4. 设置页语言 UI（M0）

- [x] 4.1 iOS：新建 `apps/ios/lib/pages/settings/widgets/locale_setting_tile.dart`（`SegmentedButton<AppLocalePreference>`，对齐 `ThemeSettingTile` 布局）
- [x] 4.2 Android：镜像 4.1 至 `apps/android/lib/pages/settings/widgets/`
- [x] 4.3 macOS / Windows / Linux / Web：各端 settings 目录添加 `LocaleSettingTile` 并嵌入设置页
- [x] 4.4 ARB 补充设置相关 keys：`settings_appearance`（若拆分分组）、`settings_theme_mode` 等（与 theme tile 迁移配合）
- [x] 4.5 验证：切换语言后设置页与 Tab 即时刷新

## 5. 壳层与导航字符串迁移（M1）

- [x] 5.1 ARB 添加 Tab keys：`tab_password`、`tab_settings`（及现有 Home Tab 若有多项）
- [x] 5.2 迁移各平台 Home / Tab 相关 View 中的 Tab 标签为 `context.l10n`
- [x] 5.3 迁移 `unknown_route_page.dart` 404 文案为 l10n key（如 `error_page_not_found`）
- [x] 5.4 ARB 添加通用 keys：`common_back`、`common_delete`、`common_edit`、`common_loading`、`common_retry`
- [x] 5.5 迁移 `ThemeSettingTile` 内硬编码（「主题模式」「跟随系统」「浅色」「深色」「主题色」「字体大小」）至 l10n
- [x] 5.6 迁移设置页分组标题与子页入口文案（iOS 优先，其他端跟进）

## 6. 核心 Feature 字符串迁移（M2）

- [ ] 6.1 **app_lock**：PIN 设置、错误提示、生物识别文案 → ARB + View 替换
- [ ] 6.2 **cipher_add**：AppBar 标题、字段 label、校验错误 → ARB；ViewModel 返回 error code，View 映射 l10n
- [ ] 6.3 **password_tab**：空态、保险库切换、添加按钮 → l10n
- [ ] 6.4 **backup_manage / data_migration**：进度、按钮、危险操作确认 → l10n（`migration_*` 前缀）
- [x] 6.5 **support**：反馈页标题与表单 label → l10n；**暂不迁移** `support_document_content.dart` 长文档正文（M4 follow-up）
- [ ] 6.6 **barrel_lock ViewModel 扫尾**：将仍向 UI 传递中文字面量的 `errorMessage` 改为 enum/code + View 侧 l10n

## 7. 依赖与消费方接入

- [x] 7.1 `apps/barrel_lock/pubspec.yaml` 确认通过 `core` 间接或直接依赖 `app_l10n`
- [x] 7.2 `apps/barrel_lock_ui/pubspec.yaml` 若壳层需直接引用则添加依赖
- [x] 7.3 各平台 app `pubspec.yaml` 无需重复依赖（经 `barrel_lock` / `core` 传递即可）；若 analyze 报错再补 path 依赖

## 8. 测试与 CI

- [x] 8.1 `packages/app_l10n/test/`：验证 `supportedLocales`、resolve 回退、`lookupAppLocalizations` 英文/中文
- [x] 8.2 Widget smoke test：`MaterialApp` + `locale: en` 下 `context.l10n.commonCancel` 显示 `Cancel`（或对应译文）
- [x] 8.3 全仓库 `melos run ci` 通过
- [ ] 8.4 （可选）脚本 `scripts/check_arb_parity.sh`：校验 `app_zh.arb` 与 `app_en.arb` key 集合一致

## 9. 文档与规范

- [x] 9.1 更新 `.cursor/rules/project-context-mdc.mdc` 或新建 i18n rule：禁止硬编码用户可见文案、key 命名前缀、Model 返回 code 约定
- [x] 9.2 README 或 `packages/app_l10n/README.md` 说明：如何添加 key、跑 gen-l10n、语言切换行为

## 10. 后续里程碑（本 change 不阻塞 apply，可拆 follow-up PR）

> M2 剩余项（6.1–6.4、6.6）可并入 `extend-i18n-four-locales` 或后续 PR；新文案须同步四 ARB（zh / zh_TW / en / ar）。

- [ ] 10.1 **M3**：扫尾六端 `apps/*/lib/pages/` 剩余硬编码字符串
- [ ] 10.2 **M4**：`support_document_content` 改为 `assets/docs/{locale}/` 或分块 ARB
- [ ] 10.3 **M4**：`packages/fast_toast`、`fast_dialog`、`fast_loading` 默认文案参数化或内置 l10n delegate
