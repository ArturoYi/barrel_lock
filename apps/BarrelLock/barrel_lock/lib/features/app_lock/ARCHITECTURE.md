# app_lock 架构决策记录

## overlay/ 包归属（P2 评估）

### 背景

`features/app_lock/overlay/` 内含 Flutter Widget（`AppLockOverlay`、PIN 面板等），与项目 MVVM-C 约定中「View 在各平台 app」不完全一致。

### 选项

| 方案 | 优点 | 缺点 |
|------|------|------|
| **A. 保留在 `barrel_lock`**（当前） | 与 `BarrelLockGlobalOverlays` Shell SSOT 同包；六平台零重复装配 | `barrel_lock` 依赖 Flutter Widget；平台 UI 定制需 override 或 fork |
| **B. 迁至 `barrel_lock_ui`** | 共享 UI 包语义更清晰 | `barrel_lock_ui` 现仅含启动页；需新建 overlay 子模块并处理对 VM Provider 的依赖 |
| **C. 迁至各平台 Shell** | 平台 UI 差异最大自由度 | 六端复制 `AppLockOverlay` + PIN 面板，违背 DRY |

### 决策：**暂缓迁移，保留方案 A**

理由：

1. Overlay 是 **Shell 基础设施**，不是路由页 View；与 `BarrelLockGlobalOverlays`、`AppLockSessionLifecycleBinder` 同属应用壳层。
2. PIN 面板当前六平台一致，无差异化需求。
3. `barrel_lock_ui` 体量过小，迁入需先建立 UI 包对 `barrel_lock` VM 的稳定依赖契约，收益不足以抵消拆分成本。

### 触发重新评估的条件

- 某平台需要不同的锁屏/PIN 交互（如 Web 不用 `BackdropFilter`）
- `barrel_lock_ui` 成长为正式共享 UI 层并收录多个 feature 的 Shell 组件
- 需要将 `barrel_lock` 纯 Dart 化以供非 Flutter 消费者引用

### 若未来迁移的推荐路径

1. 新建 `barrel_lock_ui/lib/shell/app_lock_overlay/`
2. `barrel_lock` 仅保留 Provider 契约与状态机
3. `BarrelLockGlobalOverlays` 改 import `barrel_lock_ui`
4. 各平台 `ThemedApp` 装配不变

## hasFallbackPin 同步（P1 已落地）

- **持久化**：`AppLockModel` 仅存 `enabled`
- **PIN SSOT**：`AppIdentityAuth.hasAppPin`
- **读模型**：`AppLockPreferencesRepository.load()` 读时派生 `hasFallbackPin`
- **写网关**：`enableWithFallbackPin` / `saveFallbackPin` / `clearFallbackPin` / `setEnabled`

禁止 ViewModel 直接 `copyWith(hasFallbackPin: …)` 写盘。
