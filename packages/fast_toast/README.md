# fast_toast

基于 Flutter **Overlay + OverlayEntry** 自研的全局 Toast 框架，对标 fluttertoast / oktoast 的调用体验，**零第三方依赖**，面向 BarrelLock monorepo 跨平台（Mobile / Web / Desktop）场景。

> **当前状态**：架构设计阶段，API 尚未实现。本文档为实现规格说明（SSOT）。

---

## 核心本质

**全局 Toast 的本质是：在 App 根 Overlay 上维护一条「待展示消息队列」，由单例管理器按 FIFO 逐条插入/移除 OverlayEntry，业务层只投递 `ToastRequest`，不持有 BuildContext，也不关心页面栈与 Dialog 生命周期。**

与 `ScaffoldMessenger.showSnackBar` 的区别：

| 维度 | SnackBar | fast_toast |
|------|----------|------------|
| 挂载点 | 当前 Scaffold | App 根 Overlay |
| Context | 需要 Scaffold 祖先 | **无需 Context** |
| 与路由关系 | 随页面切换可能丢失 | 根节点挂载，不受栈影响 |
| 多条消息 | 默认覆盖或堆叠 | **队列串行，不重叠** |
| 层级 | 页面内 | 高于普通页 / Dialog，低于 Loading |

---

## 设计目标

| 痛点 | fast_toast 解法 |
|------|-----------------|
| ViewModel / Notifier 无法弹 Toast | 单例 `FastToast` 全局 API，零 Context |
| 多条 Toast 重叠闪烁 | 内存队列 + 单槽展示，上一条结束再播下一条 |
| 页面 pop 后 Toast 消失 | 根 Overlay 挂载，与 Navigator 栈解耦 |
| Dialog 内操作需要反馈 | Overlay 层级高于 ModalRoute |
| 样式硬编码 | `ToastStyle` / `ToastConfig` 可配置类型、时长、位置、圆角、字体 |
| 第三方包体积与行为不可控 | 纯 Flutter SDK，`OverlayEntry` + `AnimationController` |

---

## 层级约定（与 fast_loading 协同）

自底向上：

```
普通页面 (Navigator pages)
    ↓
Dialog / BottomSheet (ModalRoute Overlay)
    ↓
fast_toast（全局 Toast 层）
    ↓
fast_loading（全屏 Loading 遮罩，最顶层）
```

Toast 必须低于 Loading，避免 Loading 期间 Toast 抢焦点；Loading 展示时 Toast 队列**暂停 dequeue**（可选策略，见下文）。

---

## 分层架构

```
┌──────────────────────────────────────────────────────────────┐
│  Application Layer（业务 App / ViewModel / Notifier）         │
│  FastToast.show / success / error / info                      │
│  FastToast.dismiss / dismissAll                               │
└───────────────────────────┬──────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────┐
│  Facade Layer（对外 API）                                      │
│  FastToast              → 单例门面，静态方法入口                 │
│  FastToastOverlay       → 挂载到 MaterialApp 根节点             │
│  ToastStyle / ToastConfig / ToastPosition / ToastType         │
└───────────────────────────┬──────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────┐
│  Core Layer（队列 + 生命周期）                                  │
│  ToastController        → 队列调度、单槽展示、延时销毁           │
│  ToastQueue             → FIFO 请求队列（不可变入队）            │
│  ToastOverlayHost       → 根 OverlayState 持有与 Entry 插入     │
└───────────────────────────┬──────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────┐
│  Presentation Layer（UI）                                     │
│  ToastWidget            → 单条 Toast 布局（图标 + 文案）         │
│  ToastAnimator          → 入出场动画（fade / slide 可配置）      │
└──────────────────────────────────────────────────────────────┘
```

---

## 目录结构（规划）

```
packages/fast_toast/
├── lib/
│   ├── fast_toast.dart                 # 包入口，统一 export
│   └── src/
│       ├── api/
│       │   ├── fast_toast.dart         # 单例门面
│       │   └── fast_toast_overlay.dart # App 根挂载 Widget
│       ├── domain/
│       │   ├── toast_request.dart      # 入队请求（message、type、config）
│       │   ├── toast_type.dart         # success / error / info / custom
│       │   ├── toast_config.dart       # 时长、位置、动画、是否可点击关闭
│       │   ├── toast_style.dart        # 颜色、圆角、字体、图标
│       │   └── toast_position.dart     # top / center / bottom + offset
│       ├── core/
│       │   ├── toast_controller.dart   # 队列调度 SSOT
│       │   ├── toast_queue.dart        # FIFO 队列
│       │   └── toast_overlay_host.dart # OverlayEntry 管理
│       └── presentation/
│           ├── toast_widget.dart
│           └── toast_animator.dart
├── test/
│   ├── toast_queue_test.dart
│   └── toast_controller_test.dart
├── README.md
└── pubspec.yaml
```

---

## 根 Overlay 挂载方案

### 推荐：`MaterialApp.builder` 包裹

在 `ThemedApp`（`packages/core`）或各 App `main.dart` 中接入：

```dart
MaterialApp.router(
  // ...
  builder: (context, child) {
    return FastToastOverlay(
      child: child ?? const SizedBox.shrink(),
    );
  },
);
```

`FastToastOverlay` 职责：

1. 在 `initState` 向子树注入 `Overlay`，或使用 `Overlay` + 独立 `GlobalKey<OverlayState>`；
2. 将 `OverlayState` 注册到 `ToastOverlayHost` / `FastToast.instance`；
3. `dispose` 时注销，防止泄漏。

### 备选：`NavigatorObserver` + 根 Navigator Key

与 `fast_navigator` 共存时，可复用 App 级 `navigatorKey.currentState!.overlay`，但须保证 key 在 `MaterialApp` 创建后可用。优先 **builder 方案**，与路由框架解耦。

---

## 队列语义

### 入队

- `FastToast.show(...)` 构造 `ToastRequest` 入队；
- 若当前无展示中的 Toast，立即 `dequeue` 并插入 `OverlayEntry`；
- 若已有展示，仅入队等待。

### 出队与销毁

- 默认 `duration` 到期后播放退场动画 → `remove` OverlayEntry → `dequeue` 下一条；
- 支持 `dismiss()` 手动关闭当前条；
- `dismissAll()` 清空队列并移除当前 Entry。

### 与 Loading 的协作

| 策略 | 行为 |
|------|------|
| **默认（推荐）** | `FastLoading.isShowing == true` 时暂停 dequeue；Loading 关闭后继续 |
| 可选 | Loading 期间仍允许 error Toast（通过 `ToastConfig.bypassLoadingPause`） |

与 `fast_loading` **不互相依赖**：通过可选回调 / 全局注册表 / `OverlayLayerRegistry`（后续 core 层）协调；首版可用静态 bool 钩子注入。

---

## 计划 API  surface

### 初始化

```dart
// 在 MaterialApp.builder 中挂载一次
FastToastOverlay(child: child)
```

### 全局调用（无 Context）

```dart
FastToast.show('保存成功');
FastToast.success('保存成功');
FastToast.error('网络异常');
FastToast.info('已复制');

FastToast.show(
  '自定义',
  config: ToastConfig(
    duration: Duration(seconds: 3),
    position: ToastPosition.bottom(offset: 48),
  ),
  style: ToastStyle.success(),
);

FastToast.dismiss();      // 关闭当前
FastToast.dismissAll();   // 清空队列
```

### 配置模型（草案）

```dart
enum ToastType { success, error, info, custom }

final class ToastConfig {
  const ToastConfig({
    this.duration = const Duration(milliseconds: 2000),
    this.position = ToastPosition.center,
    this.animation = ToastAnimation.fadeSlide,
    this.dismissible = false,
    this.bypassLoadingPause = false,
  });
}

final class ToastStyle {
  // backgroundColor, textStyle, borderRadius, icon, padding ...
  factory ToastStyle.success({TextStyle? textStyle});
  factory ToastStyle.error({TextStyle? textStyle});
  factory ToastStyle.info({TextStyle? textStyle});
}
```

---

## 动画与可访问性

- 入出场：`FadeTransition` + 可选 `SlideTransition`（自 `ToastPosition` 方向滑入）；
- 使用 `AnimationController`，Entry `remove` 前必须 `dispose` controller；
- Semantics：`liveRegion: true`，读屏可播报 message；
- 避免 `IgnorePointer` 挡全屏，Toast 区域外点击穿透（不拦截路由操作）。

---

## 扩展路线

| 阶段 | 能力 |
|------|------|
| v0.1 | 纯文本 Toast + 三态样式 + 队列 |
| v0.2 | 图文 Toast（`Widget? leading`） |
| v0.3 | 进度 Toast（不确定进度条，仍走队列或占单槽） |
| v0.4 | 主题联动 `AppTheme` / `AppTypography`（依赖 core，可选） |

---

## 依赖约束

- **运行时**：仅 `flutter` SDK；
- **不依赖** `fast_navigator` / `core` / `Riverpod`（保持 overlay 基础库纯粹）；
- 业务 App 负责在 `ThemedApp` 挂载 `FastToastOverlay`。

---

## 测试策略

| 层级 | 测什么 |
|------|--------|
| `ToastQueue` | FIFO、clear、dismissAll |
| `ToastController` | 单槽、延时、dequeue 顺序、Loading 暂停 |
| Widget | `pumpWidget` + 假 OverlayHost，断言文案与动画结束后面板消失 |
| 集成 | BarrelLock App builder 挂载后 Notifier 内调用无 Context |

---

## 接入清单（实现后）

1. 根 `pubspec.yaml` workspace 已登记 `packages/fast_toast`
2. 消费方 `dependencies: fast_toast: path: ...`
3. `ThemedApp` / `MaterialApp.builder` 包裹 `FastToastOverlay`
4. ViewModel 内 `FastToast.success('...')`

---

## 与 fast_loading 的关系

- **独立 package**，各自单例，各自 Overlay 层；
- 文档层级约定保持一致；
- 不在 package 间硬依赖，通过 App 层或后续 `fast_overlay_core`（可选）统一 z-index。

---

## License

Private — BarrelLock monorepo.
