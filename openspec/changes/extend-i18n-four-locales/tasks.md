## 1. 四语言 ARB 与 Locale 域扩展

- [x] 1.1 **BREAKING** 扩展 `AppLocalePreference`：`system`、`zhHans`、`zhHant`、`en`、`ar`；`storageValue` 与 `fixedLocale`；`fromStorage` 兼容旧值 `'zh'` → `zhHans`
- [x] 1.2 新建 `app_zh_TW.arb`、`app_ar.arb`；从 `app_zh.arb` / `app_en.arb` 复制并翻译/转换全部现有 key（与 `app_en.arb` parity）
- [x] 1.3 新增 overlay keys：`overlay_loading`、`overlay_success`、`overlay_error`、`overlay_please_wait`（四语言）
- [x] 1.4 新增 settings keys：`settings_language_summary_system`、`settings_language_summary_zh_hans`、`settings_language_summary_zh_hant`、`settings_language_summary_en`、`settings_language_summary_ar`
- [x] 1.5 更新 `l10n.yaml`（如需 `preferred-supported-locales`）；`fvm flutter gen-l10n`；提交生成代码
- [x] 1.6 重写 `AppL10n.resolveLocale`：完整 Locale 匹配；`zh_TW`/Hant → 繁体；其余 `zh` → 简体；不支持 → 简体回退
- [x] 1.7 更新 `packages/core/test/locale_settings_test.dart`：五档偏好 + 迁移 + `fixedLocale`

## 2. 无 Context 全局访问（`AppL10nHolder`）

- [x] 2.1 新建 `packages/app_l10n/lib/src/app_l10n_holder.dart`：`update(Locale)`、`current`、`locale`
- [x] 2.2 `app_l10n.dart` export；对外 `AppL10n.current` 别名
- [x] 2.3 `LocaleNotifier.setPreference` 与 `ThemedApp.build` 在 resolved locale 变化时调用 `AppL10nHolder.update`
- [x] 2.4 启动链（`runBarrelLockApp` / 首帧）初始化 holder，避免首屏 Toast 取到错误语言
- [x] 2.5 新建 `packages/app_l10n/test/app_l10n_holder_test.dart`：切换 locale 后 `current` 文案变化

## 3. RTL 与 MaterialApp 接线

- [x] 3.1 `ThemedApp`：阿拉伯语 locale 时确保 RTL（`builder` 或 locale 驱动 Directionality）
- [ ] 3.2 验证 Tab / 设置列表 / Toast 在 `ar` 下不溢出、可点击
- [x] 3.3 文档注明：自定义 Row 需使用 `EdgeInsetsDirectional` / `AlignmentDirectional`

## 4. 设置页独立「语言」入口

- [x] 4.1 `SettingsTabModel` 新增 nav item `id: 'language'`（独立分组「通用」或置于外观之前）
- [x] 4.2 `barrel_lock_l10n.dart` 增加 `settingsLanguageSummary(AppLocalePreference)` 等映射
- [x] 4.3 新建路由 `/settings/language`：`LanguageSettingsRoute` + `AppRouteBuilders` + 六端 `app_router_config`
- [x] 4.4 新建 Feature `features/language_settings/`（Model/VM/Coordinator）或轻量 VM + 共享 Page
- [x] 4.5 新建 `barrel_lock_ui` 或 `barrel_lock` 共享 `LanguageSettingsPage`（五档 Radio/ListTile，语言自称显示）
- [x] 4.6 iOS/Android 设置列表展示语言项 subtitle（当前摘要）；点击导航至语言页
- [x] 4.7 **移除** `LocaleSettingTile` 内 SegmentedButton（外观分组仅保留 `ThemeSettingTile`）
- [x] 4.8 桌面端 Settings Tab 同步：语言入口 + 语言页（或 Sheet）

## 5. Toast / Loading l10n 集成

- [x] 5.1 新建 `apps/barrel_lock/lib/l10n/overlay_l10n.dart`：`FastToastL10n` / `FastLoadingL10n` 扩展
- [x] 5.2 实现 `FastToast.showL10n(String Function(AppLocalizations) pick)` 及 `successL10n` / `errorL10n` 便捷方法
- [x] 5.3 实现 `FastLoading.showL10n` / `show()` 无参默认 `overlay_loading`
- [x] 5.4 在 `barrel_lock.dart` export `overlay_l10n.dart`
- [x] 5.5 迁移高频调用：data_migration toasts、support_feedback toasts、cipher_add 保存成功等（至少 5 处示范）
- [x] 5.6 文档：`packages/app_l10n/README.md` 补充无 Context 与 overlay 用法

## 6. iOS 原生多语言

- [x] 6.1 `Info.plist` 添加 `CFBundleLocalizations`：`en`、`zh-Hans`、`zh-Hant`、`ar`
- [x] 6.2 创建 `en.lproj`、`zh-Hans.lproj`、`zh-Hant.lproj`、`ar.lproj` 及 `InfoPlist.strings`
- [x] 6.3 四语言翻译权限 key：`NSFaceIDUsageDescription`、`NSCameraUsageDescription`、`NSPhotoLibraryUsageDescription`、`NSBluetoothAlwaysUsageDescription`、`NSLocalNetworkUsageDescription`
- [x] 6.4 Xcode 工程注册 `.lproj`（`project.pbxproj`）；真机验证英/繁/阿权限弹窗文案
- [x] 6.5 （可选）`CFBundleDisplayName` 本地化 `InfoPlist.strings`

## 7. Android 原生多语言

- [x] 7.1 `android/app/build.gradle` 配置 `resConfigs "en", "zh-rCN", "zh-rTW", "ar"`
- [x] 7.2 创建 `res/values-en`、`values-zh-rCN`、`values-zh-rTW`、`values-ar/strings.xml`
- [x] 7.3 `app_name` 四语言；Manifest `android:label="@string/app_name"`
- [x] 7.4 若存在 Kotlin 层 permission rationale / 自定义对话框，改用 `@string/` 并四语言翻译
- [ ] 7.5 验证切换系统语言后桌面图标名与权限相关原生文案

## 8. 测试与 CI

- [x] 8.1 扩展 `app_l10n_test`：四 locale lookup、resolveLocale 简繁区分、阿语 RTL smoke（Widget）
- [x] 8.2 新建 `scripts/check_arb_parity.sh`：校验 `app_zh.arb` 与 en/zh_TW/ar key 集合一致
- [x] 8.3 全仓库 `melos run ci` 通过
- [ ] 8.4 手动测试矩阵：5 偏好 × 权限弹窗（相机/相册/Face ID/蓝牙）× iOS + Android

## 9. 文档与 OpenSpec 衔接

- [x] 9.1 更新 `.cursor/rules/project-context-mdc.mdc`：四语言、`AppL10n.current`、overlay API
- [x] 9.2 在 `add-i18n-module/tasks.md` 注明 M2 剩余项可并入本 change 或后续 PR

## 10. 与 `add-i18n-module` 的衔接（可选并行）

- [ ] 10.1 继续 `add-i18n-module` 任务 6.1–6.4、6.6（Feature 字符串迁移），新文案必须同步四 ARB
- [ ] 10.2 完成 `add-i18n-module` 任务 10.1–10.3（M3/M4）时同样遵循四语言 parity
