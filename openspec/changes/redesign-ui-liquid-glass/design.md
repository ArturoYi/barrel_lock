## Context

### 当前状态

| 区域 | 现状 |
|---|---|
| 主题 | `packages/core`：`AppTheme`（M3 `ColorScheme.fromSeed`）、`AppTypography`、`AppColorScheme` 种子色、`ThemeNotifier` |
| 壳层 | `ThemedApp` 注入主题与 l10n；无全局环境背景层 |
| 重复 UI | Android/iOS 各自 `settings_gradient_background`；密码 Tab `vault_search_bar` 等局部 `BackdropFilter` |
|  overlay | `fast_dialog` 已有 blur 遮罩概念；Toast/Loading 样式与 App 主题弱耦合 |
| 架构 | MVVM-C：装饰在六端 View；共享逻辑在 `barrel_lock`；壳组件在 `barrel_lock_ui` |

### 约束

- Monorepo：视觉 SSOT 应在 `packages/` + `barrel_lock_ui`，禁止六端复制装饰代码
- Flutter 3.44.2（FVM）；Impeller 为主渲染路径，但仍需 Web/低端机降级
- 保持 `fast_navigator`、Riverpod、现有设置项（主题模式/种子色/语言）行为不变
- 无障碍：AA 对比度、减少动态效果、RTL（阿拉伯语）不破坏玻璃边框与阴影方向
- i18n：仅换肤，不引入硬编码文案

### 参考方向（产品语义）

**液态玻璃**：半透明材质 + 背景模糊 + 细描边 + 环境色折射感 → 传达「透明、可审计的安全」。  
**轻拟态**：低对比双阴影 / 内凹浅槽 → 传达「可触、精密工具」；与玻璃分层使用，避免 2019 式重拟态。

---

## Goals / Non-Goals

**Goals:**

- 可执行的 **Design Language + Token + 组件** 三层规范，开发只需组合 catalog 即可达标
- `ThemeExtension` 驱动明暗与种子色联动，与现有 `ThemeSettings` 无缝
- 统一 **AmbientBackground + Glass Shell**，删除平台重复渐变/模糊片段
- Overlay 三件套默认 Glass preset，Web/降级路径明确
- 分里程碑迁移（M0–M5），每阶段可合并、可演示

**Non-Goals:**

- 重写业务逻辑、路由、ViewModel 协议
- 引入 Skia 外 native shader 或第三方 UI 框架
- 首版交付完整 Figma 库（可后续补）；不做营销站
- 全量 golden 覆盖每个屏幕（M5 仅要求关键 primitive + 抽测）

---

## Decisions

### D1：分层架构 — Token 在 core，组件在 barrel_lock_ui

| 层 | 位置 | 内容 |
|---|---|---|
| Token 与 ThemeExtension | `packages/core/lib/theme/glass/` | `GlassTokens`, `NeumorphicTokens`, resolver, `BuildContext` 扩展 |
| 组件 | `apps/barrel_lock_ui/lib/glass/` | `GlassPanel`, `AmbientBackground`, … |
| 预览 | `barrel_lock_ui` 或 `barrel_lock` debug 路由 | Glass Gallery 页 |
| Overlay preset | `packages/core/.../glass_overlay_presets.dart` 或 thin `packages/app_glass_theme` | 供 `fast_*` 依赖 |

**理由**：core 已被全员依赖，放 Token 零新增 workspace 包；组件依赖 Flutter Widget，放 `barrel_lock_ui` 与现有 settings tiles 一致。  
**备选**：新建 `packages/app_glass` — 更清晰边界，但多一个 workspace 登记与 export 链；若组件膨胀 >~30 文件再拆包。

### D2：液态玻璃实现模式（Flutter）

标准 **Glass Surface** 栈（从底到顶）：

1. `ClipRRect`（token 圆角）
2. 可选 `BackdropFilter`（`ImageFilter.blur(sigmaX/Y: tokens.glassPanelSigma)`）
3. `DecoratedBox`：半透明白/黑填充（亮度相关）+ 1px `glassBorder` + 可选内高光 gradient（线性，opacity < 0.12）
4. 内容 `Padding`

**Navigation bar / Tab**：单层 blur；列表 **禁止** 每个 cell 独立 blur（性能）。

**AmbientBackground**：`Stack` 底层 — 多 stop `LinearGradient` + 可选低 opacity 噪声 PNG（`barrel_lock_ui` assets）；不模糊。

### D3：轻拟态实现模式

**Neumorphic Outset**（按钮）：

- 背景：与父 glass 协调的 `surfaceTint`
- `boxShadow`: highlight（负 offset，低 spread）+ ambient shadow（正 offset）
- 按压：`AnimatedScale` 0.98 + shadow 收缩

**Neumorphic Inset**（PIN/输入槽）：

- 内阴影用 **双层**：外层 inset border + 内层 `Container` 略深 4% 模拟凹槽（Flutter 无 CSS inset shadow，用视觉近似）

暗色主题：降低 shadow opacity，提高 border 可见度，避免「脏灰浮块」。

### D4：Token 数值（初版锚点，实现时可微调 ±10%）

| Token | Light | Dark |
|---|---|---|
| `glassBarSigma` | 18–24 | 12–18 |
| `glassPanelSigma` | 12–16 | 8–12 |
| `modalSigma` | 24–30 | 16–22 |
| `glassFillOpacity` | 0.55–0.72 (white base) | 0.35–0.50 (black base) |
| `hairlineBorder` | 1 logical px, white 18% | white 8% |
| `radiusLg` | 20 | 20 |
| `neumorphicDepth` | 4 | 3 |

种子色：glass 边框与 ambient 副色取 `ColorScheme.primary` / `tertiary` 的 HSL 偏移，**不**替换 M3 语义色。

### D5：GlassQuality 与降级

```dart
enum GlassQuality { full, reduced }

GlassQuality resolveGlassQuality(BuildContext context) {
  // kIsWeb → reduced; debug override; optional Future: MediaQuery.devicePixelRatio heuristic
}
```

`reduced`：无 `BackdropFilter`，提高 fill opacity + 静态 noise；布局与圆角不变。

### D6：与 Material 3 关系

保留 `useMaterial3: true`；`ColorScheme` 仍 from seed。Glass 是 **extension 层**，不 fork M3 component themes 全集。  
`NavigationBar` / `AppBar`：优先 **自定义 shell** 包一层 glass，而非深度 override `NavigationBarTheme` 全部字段（减少升级摩擦）。

### D7：Overlay 接线

- 在 `runBarrelLockApp` 或 `ThemedApp` 初始化时注册全局 `DialogStyle` / `LoadingStyle` / `ToastStyle` 工厂，读取 `GlassTokens`
- `fast_dialog` 的 `DialogMask` 继续用 `BackdropFilter`，sigma 来自 preset
- 保持 API additive：`FastDialog.show(..., style: DialogStyle.glass)` 默认 glass

### D8：六端与宽屏

- Mobile：Bottom tab + glass bar
- Tablet/Desktop（macOS/web/windows/linux）：settings 已有 split view — master 用 `GlassPanel` 列表容器，detail 用 inset well 分组
- 密码 Tab landscape：侧栏 vault 列表 glass panel（已有 layout 文件，换皮）

### D9：测试与文档

- Widget test：`GlassPanel` light/dark golden 或 property：decoration sigma 来自 extension
- Debug：`AppRoutes.glassGallery`（仅 debug/profile）或在 settings 开发项
- 更新 `.cursor/rules/project-context-mdc.mdc`：玻璃组件 import、禁止 View 内 magic blur

---

## Risks / Trade-offs

| 风险 | 缓解 |
|---|---|
| `BackdropFilter` 掉帧 | 限制同屏 blur 层数；列表 cell 不用 blur；RepaintBoundary；滚动时 optional 关闭次级 blur |
| Web 模糊不一致 | 默认 `GlassQuality.reduced` on web |
| 拟态在 OLED 暗色发糊 | 暗色 tokens 降 shadow、加 border；PIN 槽用 inset well 而非强 extrude |
| 与种子色/主题切换闪烁 | Token resolver 纯函数；切换时 `AnimatedTheme` 200ms |
| 六端 drift | M1 强制删 duplicate background；CR 检查 `BackdropFilter` 仅出现在 catalog |
| RTL 阴影方向 | neumorphic highlight 始终沿 logical top-start；用 `Directionality` 测试 ar locale |

---

## Migration Plan

1. **M0**：core extensions + 5–8 核心组件 + Glass Gallery + 文档规则  
2. **M1**：`AmbientBackground` 接入 `ThemedApp`；Home/Settings shell；删 duplicate gradient  
3. **M2**：Password tab（list/search/vault switcher）  
4. **M3**：Cipher detail/add/edit + attachments  
5. **M4**：Settings 全链路 + support/migration  
6. **M5**：Overlay presets + 删 deprecated 装饰 + widget tests  

**Rollback**：主题 extension 可 feature-flag（`ThemeData` 回退旧 scaffold 色）；按 milestone revert PR，不一次性 big-bang。

---

## Open Questions

1. 是否在 M0 拆 `packages/app_glass_theme` 以避免 core 体积感（倾向：M0 不拆，M5 评估）  
2. Ambient 噪声资源是否用矢量渐变即可，还是加 512² noise asset（倾向：首版纯渐变，noise 可选）  
3. iOS 是否对齐 Liquid Glass 大圆角（连续曲线）— Flutter 3.44 `RoundedSuperellipseBorder` 可用性需 spike（M1 前决定 tab bar 形状）  
4. Windows 亚克力：是否调用 `flutter_acrylic` 等插件（倾向：首版纯 Flutter 栈，不引 native）
