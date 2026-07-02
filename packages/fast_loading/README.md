# fast_loading

基于 Flutter **Overlay + OverlayEntry** 自研的全局 Loading 遮罩框架，对标 easy_loading / flutter_easyloading 的调用体验，**零第三方依赖**，面向 Flutter Bazaar monorepo 跨平台（Mobile / Web / Desktop）场景。

> **当前状态**：v0.1 — ref count + 根 Overlay 遮罩已实现。

---

## 核心本质

**全局 Loading 的本质是：在 App 根 Overlay 上维护「至多一个」全屏（或半屏）遮罩 Entry，由单例管理器用引用计数或 reentrant 令牌控制 show/dismiss，重复 `show` 不叠加，全部 `dismiss` 后才真正移除。**

与 `showDialog` + `CircularProgressIndicator` 的区别：

| 维度 | Dialog Loading | fast_loading |
|------|----------------|--------------|
| Context | 必须 | **无需 Context** |
| 实例数量 | 多次 show 多个 Dialog | **全局唯一遮罩** |
| 路由 | 受 Navigator 影响 | 根 Overlay，最顶层 |
| 调用场景 | Widget 内 | ViewModel / 网络层 / 工具类 |

---

## 设计目标

| 痛点 | fast_loading 解法 |
|------|-------------------|
| 网络层无法显示 Loading | 单例 `FastLoading.show()` 零 Context |
| 连续请求导致多层 Loading | 引用计数 / token，`show` 幂等，仅一层 UI |
| Loading 被 Dialog 盖住 | 根 Overlay **最高层级**（高于 Toast） |
| 样式不统一 | `LoadingStyle` / `LoadingConfig` 可配置指示器、文案、遮罩色 |
| 忘记 dismiss 泄漏 | `OverlayEntry` 与 controller 绑定，`dismissAll` 兜底 |

---

## 层级约定（与 fast_toast 协同）

自底向上：

```
普通页面 (Navigator pages)
    ↓
Dialog / BottomSheet (ModalRoute Overlay)
    ↓
fast_toast（Toast 层）
    ↓
fast_loading（全屏 Loading 遮罩，最顶层）
```

Loading 展示时：

- 遮罩默认拦截指针事件（`ModalBarrier` 语义）；
- 可选 `LoadingConfig.intercepting: false` 仅视觉提示不挡点击（少用）；
- Toast 队列建议暂停（由 `fast_toast` 读取 `FastLoading.isShowing`）。

---

## 分层架构

```
┌──────────────────────────────────────────────────────────────┐
│  Application Layer（Repository / Notifier / 工具类）           │
│  FastLoading.show / dismiss / dismissAll                      │
│  FastLoading.run<T>(future)  // 语法糖：自动 show/dismiss      │
└───────────────────────────┬──────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────┐
│  Facade Layer（对外 API）                                      │
│  FastLoading            → 单例门面                             │
│  FastLoadingOverlay     → 挂载到 MaterialApp 根节点（可与 Toast 合并布局） │
│  LoadingStyle / LoadingConfig                               │
└───────────────────────────┬──────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────┐
│  Core Layer（单例 + 引用计数）                                  │
│  LoadingController      → show/dismiss SSOT，ref count / token │
│  LoadingOverlayHost     → 单一 OverlayEntry 插入/更新/移除      │
└───────────────────────────┬──────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────┐
│  Presentation Layer（UI）                                     │
│  LoadingWidget          → 指示器 + 可选 message                │
│  LoadingBarrier         → 半透明遮罩 + AbsorbPointer           │
└──────────────────────────────────────────────────────────────┘
```

---

## 目录结构（规划）

```
packages/fast_loading/
├── lib/
│   ├── fast_loading.dart               # 包入口
│   └── src/
│       ├── api/
│       │   ├── fast_loading.dart       # 单例门面
│       │   └── fast_loading_overlay.dart
│       ├── domain/
│       │   ├── loading_config.dart         # 行为配置：message、拦截、样式引用
│       │   ├── loading_style.dart          # 样式组合 + Spec 导出
│       │   ├── loading_surface_spec.dart   # 容器布局常量（圆角、内边距等）
│       │   ├── loading_indicator_spec.dart # 指示器与文案排版常量
│       │   ├── loading_display_phase.dart
│       │   └── loading_dismiss_result.dart
│       ├── core/
│       │   ├── loading_controller.dart     # ref count + Entry 生命周期
│       │   └── loading_overlay_host.dart
│       └── presentation/
│           ├── loading_widget.dart
│           ├── loading_surface_widget.dart
│           ├── loading_body_widget.dart
│           └── loading_barrier.dart
├── test/
│   ├── loading_controller_test.dart
│   ├── loading_widget_test.dart
│   └── fast_loading_overlay_test.dart
├── README.md
└── pubspec.yaml
```

---

## 根 Overlay 挂载方案

### 推荐：与 `FastToastOverlay` 组合为统一 Host

App 层单一 `builder`，内部 Stack 固定 z-order：

```dart
MaterialApp.router(
  builder: (context, child) {
    return FastOverlayHost(
      child: child ?? const SizedBox.shrink(),
    );
  },
);
```

`FastOverlayHost`（实现阶段可放在 `core` 或各 package 导出组合 Widget）：

```
Stack(
  children: [
    child,                    // 正常 App 内容
    // Toast 层（fast_toast）
    // Loading 层（fast_loading）— 最上
  ],
)
```

首版若不做合并 Widget，则 `FastLoadingOverlay` 独立挂载，**必须保证在 Toast Overlay 之上**（后声明的 Stack 子节点更高）。

### OverlayState 注册

与 `fast_toast` 相同模式：`GlobalKey<OverlayState>` 或专用 Overlay 子树，在 `initState` 注册、`dispose` 注销。

---

## 单例语义（引用计数）

### 问题

异步并发场景：

```dart
FastLoading.show();   // 请求 A
FastLoading.show();   // 请求 B — 不应出现第二个遮罩
// ...
FastLoading.dismiss(); // A 完成
FastLoading.dismiss(); // B 完成 — 此时才移除 UI
```

### 方案

| 方案 | 说明 |
|------|------|
| **引用计数（默认）** | `show()` `_ref++`，`dismiss()` `_ref--`，`_ref == 0` 时移除 Entry |
| Token | `show()` 返回 `LoadingToken`，仅持有 token 者可 dismiss（更严格） |
| 混合 | 门面用 ref count；高级 API 暴露 token |

首版实现 **引用计数**，API 简单；文档注明嵌套 async 必须成对 dismiss。

### 幂等

- 第一次 `show()`：创建 OverlayEntry + 插入；
- 后续 `show()`：仅 `_ref++`，**不重建** Entry（避免闪烁）；
- `dismissAll()`：`_ref = 0`，立即移除。

---

## 计划 API surface

### 挂载

```dart
FastLoadingOverlay(child: child)
// 或与 FastToastOverlay 组合的 FastOverlayHost
```

### 全局调用

```dart
FastLoading.show([String? message]);
FastLoading.show(config: LoadingConfig(message: '加载中…'));
FastLoading.dismiss();
FastLoading.dismissAll();

FastLoading.isShowing; // bool，供 fast_toast 暂停队列

// 语法糖
final data = await FastLoading.run(
  () => repository.fetch(),
  message: '加载中…',
);
```

### 配置模型（草案）

```dart
final class LoadingConfig {
  const LoadingConfig({
    this.message,
    this.intercepting = true,
    this.style,
  });
}

final class LoadingStyle {
  factory LoadingStyle.adaptive(); // Material 浮层 + CircularProgressIndicator

  // Spec：与 Theme 无关的布局常量
  LoadingSurfaceSpec surfaceSpec;   // 容器圆角、内边距、阴影
  LoadingIndicatorSpec indicatorSpec; // 指示器尺寸、文案间距与 textStyle

  // 顶层：Theme 覆盖与 Widget 逃生舱
  // indicatorColor, backgroundColor, barrierColor, indicator, loadingWidget ...
}
```

---

## 动画与可访问性

- 可选短 fade-in（≤ 150ms），避免每次 show 闪烁；
- `Semantics(label: message ?? 'Loading')`，`ModalBarrier` 语义；
- `intercepting: true` 时使用 `AbsorbPointer` 或 `ModalBarrier` 吞掉点击，防止重复提交。

---

## 扩展路线

| 阶段 | 能力 |
|------|------|
| v0.1 | 全屏遮罩 + 默认指示器 + ref count |
| v0.2 | 自定义 `Widget` 指示器、局部 Loading（非全屏） |
| v0.3 | 确定性进度 `FastLoading.progress(0.0..1.0)` |
| v0.4 | 与 `core` 主题色联动（可选依赖） |

---

## 依赖约束

- **运行时**：仅 `flutter` SDK；
- **不依赖** `fast_toast`（避免循环）；`isShowing` 供对方查询即可；
- 业务 App 负责挂载顺序：Loading 层在 Toast 层之上。

---

## 测试策略

| 层级 | 测什么 |
|------|--------|
| `LoadingController` | ref count、幂等 show、dismissAll |
| Widget | show 后面板存在、dismiss 后消失、连续 show 仅一个 Entry |
| 集成 | Notifier 内 `FastLoading.run` 异常时仍 dismiss（finally） |

---

## 接入清单（实现后）

1. workspace 登记 `packages/fast_loading`
2. `ThemedApp.builder` 挂载 Overlay Host（Loading 在最上）
3. Repository 层 `await FastLoading.run(() => api.call())`

---

## 与 fast_toast 的关系

| 包 | 职责 | 实例策略 |
|----|------|----------|
| fast_toast | 轻量反馈 | 队列，多条串行 |
| fast_loading | 阻塞式等待 | 单例，ref count |

两者 API 对称（均无 Context），文档与 z-index 约定一致，package 间零硬依赖。

---

## License

Private — Flutter Bazaar monorepo.
