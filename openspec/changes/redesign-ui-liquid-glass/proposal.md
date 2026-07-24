## Why

BarrelLock 当前 UI 以 Material 3 默认色板与分散在各平台 View 的卡片/渐变样式为主，缺少统一的设计语言；密码箱、工具类应用用户普遍期望「通透、可信、精致」的视觉体验，而 iOS 26 / Android 16 方向上的液态玻璃（Liquid Glass）与轻拟态（Neumorphism 的克制变体）已成为主流参考。在 i18n 与共享 Feature 层趋于稳定后，需要一次系统性的视觉重构：先定规范与组件库，再分阶段替换界面，避免六端重复实现与风格漂移。

## What Changes

- 建立 **BarrelLock Glass Design Language**：设计原则、层级模型、明暗主题语义、无障碍与性能边界（何时用 blur、何时降级）
- 扩展 `packages/core` 主题体系：设计 Token（颜色、圆角、模糊、阴影、间距）、`ThemeExtension`（Glass / Neumorphic surfaces），与现有 `AppColorScheme`、`ThemeNotifier` 对齐
- 新建或扩展共享 UI 层（优先 `apps/barrel_lock_ui` + 可选 `packages/app_glass_ui`）：可复用组件（玻璃面板、拟态按钮、列表单元、输入框、导航栏/Tab 栏、设置分组等）
- 统一 **应用壳层**：启动页、Home Tab、设置布局、全局背景与滚动行为；收敛 Android/iOS 已存在的 `settings_gradient_background`、`vault_search_bar` 等重复实现
- 更新 `fast_dialog` / `fast_loading` / `fast_toast` 的视觉样式 API，使其默认贴合 Glass 规范（保留可覆盖）
- 制定 **分阶段迁移路线图**：Shell → 密码 Tab → 详情/编辑 → 设置与支持 → 桌面/Web 宽屏适配
- 文档与工程约束：Figma/Token 对照表（可选）、Storybook 式预览页或 `debug` 路由、`.cursor/rules` 设计约定
- **BREAKING（视觉）**：大量 Widget 树与 `ThemeData` 默认值变更；对外 API 以 additive 为主（新组件 + ThemeExtension），旧样式标记 deprecated 后移除

## Capabilities

### New Capabilities

- `glass-design-language`: 视觉原则、信息层级、明暗语义、安全/隐私场景的 UI 表达、性能与无障碍要求
- `glass-design-tokens`: 颜色/字体/圆角/间距/模糊/阴影/动效 Token 定义与 `AppColorScheme` 映射规则
- `glass-theme-extensions`: `ThemeExtension`、与 `AppTheme` / `ThemedApp` 接线、主题切换与种子色联动
- `glass-component-library`: 共享 Glass/Neumorphic 组件 catalog、组合模式与使用禁忌
- `glass-app-shell`: 根背景、导航、Tab、设置分栏/滚动壳层的结构与行为要求
- `overlay-glass-styles`: Dialog/Toast/Loading 遮罩与面板的 Glass 化样式与降级策略
- `ui-migration-rollout`: 分里程碑迁移范围、验收标准、六端 View 与 `barrel_lock` Feature 的分工

### Modified Capabilities

（无 archive 存量 spec；本 change 以 delta spec 自洽）

## Impact

- **packages/core**：`theme/` 扩展 Token 与 ThemeExtension；可能新增 `presentation/glass_*`
- **apps/barrel_lock_ui**：组件库主体、预览/示例页 export
- **apps/barrel_lock**：Feature 内共享 Widget 逐步迁到 ui kit；`ThemedApp` 背景与 extension 注入
- **六端 apps/**：`lib/pages/` View 分批替换布局与装饰；删除重复 gradient/glass 片段
- **packages/fast_dialog、fast_loading、fast_toast**：默认样式与可选 Glass preset
- **packages/app_fonts**：确认 Glass 排版层级与字重是否需增补
- **CI**：`melos run analyze`；可选 golden/widget 测试；性能回归关注 blur 层数
- **Out of scope（首版）**：品牌插画系统、营销官网、完整 Figma 组件库交付（可后续迭代）；不改变业务逻辑与路由架构
