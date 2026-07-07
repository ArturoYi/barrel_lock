# fast_lifecycle 使用说明

全平台原生生命周期监听框架。底层透传各端 `rawState`，业务层可按需选择**差异版**或**抹平版**（对齐 `WidgetsBindingObserver` / `AppLifecycleState`）。

## 目录

- [快速开始](#快速开始)
- [架构分层](#架构分层)
- [初始化与销毁](#初始化与销毁)
- [差异版：平台原生 Mixin](#差异版平台原生-mixin)
- [抹平版：AppLifecycleState 对齐](#抹平版applifecyclestate-对齐)
- [读取当前状态](#读取当前状态)
- [BarrelLock 集成示例](#barrellock-集成示例)
- [各平台触发对照](#各平台触发对照)
- [Mixin 组合顺序](#mixin-组合顺序)
- [架构红线](#架构红线)

---

## 快速开始

```dart
import 'package:fast_lifecycle/fast_lifecycle.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 初始化原生监听
  await RawLifeCycleManager.instance.initialize();

  // 2. 启用全局状态快照（可选，便于随时读取当前相位）
  attachLifecycleStateTracking();

  runApp(const MyApp());
}
```

---

## 架构分层

```
系统原生层（Android Lifecycle / UIApplicationDelegate / NSNotification / GTK / dart:html）
        ↓ EventChannel / 纯 Dart
平台适配层（MobileLifecycleAdapter / DesktopLifecycleAdapter / WebLifecycleAdapter）
        ↓
RawLifeCycleManager（单例分发）
        ↓
┌─────────────────────┬──────────────────────────┐
│ 差异版 Mixin         │ 抹平版 FlatLifecycleMixin │
│ 保留平台 API 语义     │ 对齐 AppLifecycleState 四态 │
└─────────────────────┴──────────────────────────┘
```

- **差异版**：`IosAppLifecycleMixin`、`AndroidAppLifecycleMixin` 等，一一对应原生回调名。
- **抹平版**：`FlatLifecycleMixin`，映射为 `detached` / `inactive` / `resumed` / `paused`。

---

## 初始化与销毁

### 基础初始化

```dart
await RawLifeCycleManager.instance.initialize(
  options: const LifeCycleInitOptions(
    windowId: 'main',       // 桌面多窗口时传入唯一 ID
    isMainWindow: true,
  ),
);
```

### 桌面多窗口

Flutter 官方模型为 **一窗口一 Engine**。每个 Engine 在启动时独立调用 `initialize`，传入唯一 `windowId`。

### 销毁

```dart
detachLifecycleStateTracking();          // 若已 attach
await RawLifeCycleManager.instance.dispose();
```

### BarrelLock 封装

`barrel_lock` 已封装引导函数，在 `ThemedApp` 中自动调用：

```dart
import 'package:barrel_lock/barrel_lock.dart';

// 内部等价于：
await bootstrapBarrelLockLifecycle();
// ...
await disposeBarrelLockLifecycle();
```

---

## 差异版：平台原生 Mixin

### 绑定与使用

```dart
class AppLockHandler
    with LifecycleListenerBinding, IosAppLifecycleMixin, AndroidAppLifecycleMixin {
  void start() {
    bindPlatformLifecycle(); // 需在 initialize 之后
  }

  void stop() => unbindPlatformLifecycle();

  @override
  void onApplicationDidEnterBackground(RawLifeCycleEvent event) {
    // iOS 进入后台
  }

  @override
  void onActivityPause(RawLifeCycleEvent event) {
    // Android Activity 失焦（权限弹窗等）
  }

  @override
  void onProcessStop(RawLifeCycleEvent event) {
    // Android App 整体不可见
  }
}
```

### 平台常量（SSOT）

| 类 | 用途 |
|----|------|
| `IosAppLifecycleState` | `applicationDidBecomeActive` 等 |
| `AndroidAppLifecycleState` | `ON_RESUME` / `ON_PAUSE` 等 |
| `MacosAppLifecycleState` | `NSWindowDidBecomeKeyNotification` 等 |
| `LinuxAppLifecycleState` | `window_focus` 等 |
| `WebAppLifecycleState` | `visibilitychange_hidden` 等 |

### Android 双层注意

同一 `rawState`（如 `ON_PAUSE`）可能来自 `process` 或 `activity`，务必结合 `event.extra.lifecycleScope` 区分：

```dart
if (event.extra.lifecycleScope == LifecycleScope.activity &&
    event.rawState == AndroidAppLifecycleState.onPause) {
  // Activity 失焦，App 可能仍在前台
}
```

---

## 抹平版：AppLifecycleState 对齐

`FlatLifecycleMixin` 将各平台事件映射为与 `WidgetsBindingObserver.didChangeAppLifecycleState` 等价的四态：

| FlatLifecyclePhase | 语义 |
|--------------------|------|
| `detached` | 未附着视图 / 即将卸载 |
| `inactive` | 可见但不可交互（失焦、权限弹窗） |
| `resumed` | 前台可交互 |
| `paused` | 后台不可见 |

### 使用

```dart
class LockGuard with LifecycleListenerBinding, FlatLifecycleMixin {
  void start() => bindPlatformLifecycle();

  @override
  void onFlatPaused(RawLifeCycleEvent event) {
    // 等同 AppLifecycleState.paused → 触发 App Lock
  }

  @override
  void onAppLifecycleStateChanged(FlatLifecyclePhase state, RawLifeCycleEvent event) {
    // 统一入口，可对接现有 WidgetsBindingObserver 逻辑
    final flutterState = state.toAppLifecycleState;
  }
}
```

### 与 WidgetsBindingObserver 互操作

```dart
FlatLifecyclePhase phase = currentFlatLifecyclePhase;
AppLifecycleState? appState = phase.toAppLifecycleState;

// 反向
AppLifecycleState.resumed.toFlatLifecyclePhase; // FlatLifecyclePhase.resumed
```

---

## 读取当前状态

### 全局快捷方法（需先 `attachLifecycleStateTracking()`）

```dart
// 差异版：最近一次原生事件
currentPlatformLifecycle.rawState;        // e.g. applicationDidEnterBackground
currentPlatformLifecycle.lifecycleScope;  // e.g. process / activity / application

// 抹平版：当前跨平台相位
currentFlatLifecyclePhase;                // e.g. FlatLifecyclePhase.paused
```

### Extension

```dart
RawLifeCycleManager.instance.platformLifecycle;
RawLifeCycleManager.instance.flatLifecyclePhase;
```

### Mixin 实例内

```dart
// PlatformLifecycleStateMixin
currentPlatformRawState;
currentPlatformLifecycleScope;

// FlatLifecycleMixin
flatLifecyclePhase;
appLifecycleState;
isFlatResumed / isFlatPaused / isFlatInactive / isFlatDetached;
```

### LifecycleStateStore

```dart
LifecycleStateStore.instance.platform;  // PlatformLifecycleSnapshot
LifecycleStateStore.instance.flat;      // FlatLifecycleSnapshot
```

---

## BarrelLock 集成示例

`ThemedApp` 已在 `initState` / `dispose` 中调用生命周期引导，业务 Feature 可直接使用：

```dart
import 'package:barrel_lock/barrel_lock.dart';
import 'package:fast_lifecycle/fast_lifecycle.dart';

final class AppLockLifecycleBridge
    with LifecycleListenerBinding, FlatLifecycleMixin {
  AppLockLifecycleBridge() {
    bindPlatformLifecycle();
  }

  @override
  void onFlatPaused(RawLifeCycleEvent event) {
    // App 进入后台，结合 AppLock 偏好触发锁屏
    if (currentFlatLifecyclePhase == FlatLifecyclePhase.paused) {
      // ...
    }
  }
}
```

---

## 各平台触发对照

详见 `LifecycleTriggerReference` 与需求文档。摘要：

### iOS（单轨 Application）

```
didFinishLaunching → didBecomeActive ⇄ willResignActive → didEnterBackground → willEnterForeground
```

### Android（进程 + Activity 双轨）

- 按 Home：`Activity ON_PAUSE→ON_STOP` + `Process ON_PAUSE→ON_STOP`
- 权限弹窗：`Activity ON_PAUSE`，Process 可能仍 `ON_RESUME`

### Web（可见性 + 焦点复合）

| 条件 | 抹平相位 |
|------|----------|
| visible + focus | `resumed` |
| visible + blur | `inactive` |
| hidden | `paused` |
| beforeunload | `detached` |

### macOS / Linux（窗口轨）

窗口获焦/失焦/最小化/关闭 + macOS App 全局 Hide/Unhide。

---

## Mixin 组合顺序

推荐从左到右（事件分发：右侧 Mixin 先收到，再 `super` 传递）：

```dart
class Handler
    with
        LifecycleListenerBinding,    // 基础绑定
        IosAppLifecycleMixin,        // 平台差异回调
        AndroidAppLifecycleMixin,
        FlatLifecycleMixin,          // 抹平回调
        PlatformLifecycleStateMixin  // 记录原生快照（最后收到事件）
```

---

## 架构红线

1. **原生层禁止**将事件翻译为 Flutter 四态；翻译仅在 `FlatLifecycleMapper` 抹平层进行。
2. Android 必须分 `process` / `activity` 上报。
3. 移动端持续事件**禁止**用 MethodChannel 推送。
4. Web **禁止**引入 Flutter Channel。
5. 监听必须可 `dispose`，防止泄漏。
6. Windows 原生插件为 TODO，当前回退 `NoopLifeCycleAdapter`。

---

## 相关文件

| 路径 | 说明 |
|------|------|
| `lib/fast_lifecycle.dart` | 公共导出 |
| `lib/src/mixins/` | 差异版 + 抹平版 Mixin |
| `lib/src/domain/flat/` | 抹平映射器与相位定义 |
| `lib/src/state/` | LifecycleStateStore 与快捷读取 |
| `Flutter 全平台原生生命周期监听架构需求文档（无第三方、不抹平原生）.md` | 架构需求 SSOT |
