# Flutter 全平台原生生命周期监听架构需求文档（无第三方、不抹平原生）

## 1. 文档概述

### 1.1 设计目标

- **零第三方依赖**：不使用 `visibility_detector`、`window_manager` 等外部插件，全自研底层能力
- **不抹平平台原生状态**：完整保留各端系统原生生命周期 API 名称与语义，**禁止**映射为 Flutter `AppLifecycleState` 或任何跨平台统一枚举
- **全平台统一架构分层**：多端适配同一套抽象接口、**可复用 Channel 规范**、统一事件数据结构
- **精准区分多窗口场景**：完美支持 macOS 多窗口独立生命周期隔离，可精准定位事件所属窗口
- **解耦业务与底层平台差异**：底层负责采集透传，上层业务自主按需区分平台与原生状态

### 1.2 适用范围

Flutter 全平台项目（Android、iOS、Windows、macOS、Linux、Web），作为项目底层基础架构能力，统一管控应用/窗口/页面生命周期监听能力。

### 1.3 平台实现状态

| 平台 | 状态 | 说明 |
|------|------|------|
| Android | ✅ 已修正 | Process + Activity 双层，`ON_*` + `lifecycleScope` |
| iOS | ✅ 已修正 | UIApplicationDelegate 方法名一一对应 |
| macOS | ✅ 基本正确 | 已透传 `NSNotification.Name.rawValue` |
| Linux | ✅ 基本正确 | 已透传 GTK 窗口语义字符串 |
| Web | ✅ 基本正确 | 已透传浏览器 visibility / focus 语义字符串 |
| **Windows** | **📋 TODO** | **暂不实现**；Dart 侧回退 `NoopLifeCycleAdapter`，待后续单独补齐 Win32 原生插件 |

---

## 2. 核心架构设计规范

### 2.1 整体分层架构（四层架构）

自上而下分层，严格单向依赖，层级隔离不可跨层调用：

1. **业务门面层**：全局单例 `RawLifeCycleManager`，统一注册/移除监听、事件分发，无状态转换、无平台判断
2. **抽象适配层**：定义统一适配器基类 `LifeCycleAdapter`，强制所有平台实现统一接口
3. **平台实现层**：分平台独立实现监听逻辑，透传原生事件，**无任何跨平台状态抹平**
4. **系统原生层**：各端原生 API 采集生命周期事件，原样回传，不做翻译修改

### 2.2 统一核心数据结构（全局唯一）

所有平台事件输出统一结构体，仅 `rawState` 与 `extra` 内容因平台而异，**结构完全一致**：

- **平台来源**：`LifePlatformSource` — `android / ios / windows / macos / linux / web`
- **事件实体 `RawLifeCycleEvent`**
  - `source`：事件所属平台
  - `rawState`：**核心字段**，系统原生 API / 通知 / 回调的原始标识字符串（禁止翻译）
  - `extra`：扩展参数（生命周期作用域、窗口 ID、是否主窗口等）
- **统一回调**：`LifeCycleEventCallback`，业务层统一接收

#### 2.2.1 `extra` 扩展字段规范

| 字段 | 类型 | 说明 |
|------|------|------|
| `windowId` | `String?` | 桌面多窗口溯源标识 |
| `isMainWindow` | `bool?` | 是否主窗口 |
| `lifecycleScope` | `String?` | **移动端必填**：生命周期作用域，区分同平台不同层级（见 §4.1 / §4.2） |
| `metadata` | `Map` | 可选附加信息（窗口尺寸等） |

### 2.3 可复用 Channel 规范（SSOT）

通道命名由 `LifecycleChannelNames` 统一定义，**所有平台原生插件必须引用同一套名称**，禁止各端硬编码字符串：

| 常量 | 值 | 用途 |
|------|-----|------|
| `eventChannel` | `fast_lifecycle/events` | 唯一事件推送通道（流式） |
| `controlChannel` | `fast_lifecycle/control` | 移动端启停控制（**禁止**推送持续事件） |
| `methodStartListening` | `startListening` | MethodChannel 启动监听 |
| `methodStopListening` | `stopListening` | MethodChannel 停止监听 |
| `eventChannelForWindow(id)` | `fast_lifecycle/events/{id}` | 可选：按窗口隔离物理通道（当前以 Engine 隔离为主） |

**EventChannel 标准载荷**（字段名由 `NativePayloadKeys` 统一定义，Kotlin / Swift / C++ 必须一致）：

```json
{
  "source": "ios",
  "rawState": "applicationDidBecomeActive",
  "extra": {
    "lifecycleScope": "application",
    "windowId": null,
    "isMainWindow": true,
    "metadata": {}
  }
}
```

### 2.4 抽象适配器规范

所有平台适配器必须实现 `LifeCycleAdapter`：

- `listen()`：初始化监听，收到事件后通过回调 **原样** 分发
- `dispose()`：销毁监听、释放 Channel、移除原生订阅

**强制约束**：

- Dart 适配层 **禁止** 对 `rawState` 做 if/switch 映射或重命名
- 原生采集层 **禁止** 将平台事件翻译为 Flutter `AppLifecycleState` 或其他跨平台枚举

### 2.5 平台生命周期抽象层（Base + Mixin 模式）

> **这是与当前错误实现的核心差异。**

当前实现将 Android `Lifecycle.Event`、iOS `NSNotification` **错误地** 统一翻译为 `resumed / inactive / paused / detached`（Flutter Engine 语义），导致：

- Android **进程生命周期** 与 **Activity 页面生命周期** 的差异被抹平
- iOS `applicationWillEnterForeground` 等独有回调被丢弃
- 业务层无法按原平台 API 编写精准逻辑

**正确做法**：为每个平台定义一层**平台专属生命周期抽象**，通过 **Base 抽象类 + Mixin** 统一「注册 / 注销 / 发射事件」流程，但 **保留各平台原生回调的差异语义**。

#### 2.5.1 抽象层职责划分

```
┌─────────────────────────────────────────────────────────┐
│  BaseLifecycleEmitter（各端共享的「发射」基类）           │
│  - buildPayload(rawState, extra)                        │
│  - emit(rawState, extra) → EventChannel                 │
│  - startListening() / stopListening()                   │
└─────────────────────────────────────────────────────────┘
         ▲                    ▲                    ▲
         │                    │                    │
┌────────┴────────┐  ┌────────┴────────┐  ┌────────┴────────┐
│ iOS AppLifecycle│  │ Android Process │  │ Android Activity│
│ Mixin / Tracker │  │ LifecycleMixin  │  │ LifecycleMixin  │
│ （UIApplication │  │ （ProcessLifecycle│  │ （Activity      │
│  Delegate 回调）│  │  Owner 回调）    │  │  Lifecycle 回调）│
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

- **Base 抽象类**：封装 Channel 订阅、载荷构造、`emit()` 去重策略、资源释放
- **Mixin / 子类**：仅实现「收到哪个原生回调 → 发射哪个 `rawState`」，**一一对应，零翻译**
- **Dart 侧**：只解析 Map，不做二次映射

#### 2.5.2 Mixin 调用约定

各平台 Tracker 通过 Mixin 接入 Base 发射能力，典型模式：

```kotlin
// Android 示例（示意）
internal class AndroidLifecycleTracker(
    private val emitter: LifecycleEventEmitter,
) : DefaultLifecycleObserver, ProcessLifecycleMixin, ActivityLifecycleMixin {

    // ProcessLifecycleMixin 实现
    override fun onProcessStart() {
        emitter.emit("ON_START", extra = mapOf("lifecycleScope" to "process"))
    }

    // ActivityLifecycleMixin 实现
    override fun onActivityResume() {
        emitter.emit("ON_RESUME", extra = mapOf("lifecycleScope" to "activity"))
    }
}
```

```swift
// iOS 示例（示意）
final class IOSAppLifecycleTracker: LifecycleEventEmitter {
    // 直接对应 UIApplicationDelegate 方法名作为 rawState
    func applicationDidBecomeActive(_ application: UIApplication) {
        emit(rawState: "applicationDidBecomeActive",
             extra: ["lifecycleScope": "application"])
    }
}
```

---

## 3. 全平台通信通道选型规范

| 平台 | 通道方案 | 用途分工 | 核心约束 |
|------|----------|----------|----------|
| Android / iOS | EventChannel（主）+ MethodChannel（辅） | EventChannel 流式推送；MethodChannel 仅启停控制 | 禁止用 MethodChannel 推送持续事件 |
| macOS / Linux | 自研原生插件 EventChannel | 推送窗口 / App 事件，携带 windowId | 不依赖 window_manager |
| **Windows** | **📋 TODO** | 计划 EventChannel + Win32 窗口消息 | **暂不实现** |
| Web | 无 Flutter Channel，纯 `dart:html` | visibility / focus / blur | 禁止引入 Channel 代码 |

---

## 4. 各平台原生事件透传规则（不抹平核心规则）

> **红线**：`rawState` 必须是该平台开发者文档中的 **API 名 / 事件名 / 通知名**，禁止映射为 Flutter 四态或其他跨平台命名。

### 4.1 iOS — `UIApplicationDelegate` 一一对应

`rawState` 使用 **UIApplicationDelegate 方法名**（camelCase），`extra.lifecycleScope = "application"`：

| UIApplicationDelegate 回调 | rawState | 说明 |
|---------------------------|----------|------|
| `application(_:didFinishLaunchingWithOptions:)` | `applicationDidFinishLaunching` | 启动完成 |
| `applicationDidBecomeActive(_:)` | `applicationDidBecomeActive` | 进入活跃 |
| `applicationWillResignActive(_:)` | `applicationWillResignActive` | 即将失活 |
| `applicationDidEnterBackground(_:)` | `applicationDidEnterBackground` | 进入后台 |
| `applicationWillEnterForeground(_:)` | `applicationWillEnterForeground` | 即将前台 |
| `applicationWillTerminate(_:)` | `applicationWillTerminate` | App 终止（极少触发） |

**禁止**：

```swift
// ❌ 错误：映射为 Flutter AppLifecycleState
(UIApplication.didBecomeActiveNotification, "resumed")
```

**正确**：

```swift
// ✅ 正确：方法名即 rawState
emit(rawState: "applicationDidBecomeActive")
```

实现方式：通过 `UIApplicationDelegate` 转发或 `NSNotificationCenter` 监听后，**以 Delegate 方法名作为 rawState 发射**，不做中间翻译。

### 4.2 Android — 进程 + Activity 双层生命周期

Android 必须 **分两层独立上报**，通过 `extra.lifecycleScope` 区分：

#### 4.2.1 进程生命周期（`lifecycleScope = "process"`）

监听 `ProcessLifecycleOwner`，`rawState` 使用 `androidx.lifecycle.Lifecycle.Event` 名：

| Lifecycle.Event | rawState | 说明 |
|-----------------|----------|------|
| `ON_CREATE` | `ON_CREATE` | 进程创建 |
| `ON_START` | `ON_START` | 进程进入前台可见 |
| `ON_RESUME` | `ON_RESUME` | 进程可交互 |
| `ON_PAUSE` | `ON_PAUSE` | 进程失去焦点 |
| `ON_STOP` | `ON_STOP` | 进程不可见 |
| `ON_DESTROY` | `ON_DESTROY` | 进程销毁 |

#### 4.2.2 Activity 页面生命周期（`lifecycleScope = "activity"`）

监听当前 Flutter `Activity.lifecycle`，`rawState` 同样使用 `Lifecycle.Event` 名：

| Lifecycle.Event | rawState | 说明 |
|-----------------|----------|------|
| `ON_CREATE` | `ON_CREATE` | Activity 创建 |
| `ON_START` | `ON_START` | Activity 可见 |
| `ON_RESUME` | `ON_RESUME` | Activity 可交互 |
| `ON_PAUSE` | `ON_PAUSE` | Activity 失去焦点 |
| `ON_STOP` | `ON_STOP` | Activity 不可见 |
| `ON_DESTROY` | `ON_DESTROY` | Activity 销毁 |

**禁止**：

```kotlin
// ❌ 错误：将 ON_RESUME 翻译为 "resumed"
emitIfChanged("resumed")
```

**正确**：

```kotlin
// ✅ 正确：保留 Lifecycle.Event 原名 + 作用域
emitter.emit(
    rawState = "ON_RESUME",
    extra = mapOf("lifecycleScope" to "activity"),
)
```

> 同一时刻可能先后收到 `process.ON_PAUSE` 与 `activity.ON_PAUSE`，**这正是需要保留的平台差异**，业务层按 `lifecycleScope` 区分处理。

### 4.3 Web 端

完全透传浏览器原生事件语义字符串：

- `visibilitychange_hidden` / `visibilitychange_visible`
- `window_focus` / `window_blur`

### 4.4 桌面端 Linux

透传窗口原生事件：

- `window_minimize` / `window_restore` / `window_focus` / `window_blur` / `window_close`

### 4.5 macOS（多窗口隔离）

直接透传 **NSWindow / NSApplication 系统原生通知名**：

**单窗口事件**（`extra.lifecycleScope = "window"`）：

- `NSWindowDidBecomeKeyNotification`
- `NSWindowDidResignKeyNotification`
- `NSWindowDidMiniaturizeNotification`
- `NSWindowDidDeminiaturizeNotification`
- `NSWindowWillCloseNotification`

**App 全局事件**（`extra.lifecycleScope = "application"`）：

- `NSApplicationDidHideNotification`
- `NSApplicationDidUnhideNotification`

### 4.6 Windows — 📋 TODO（暂不实现）

计划透传 Win32 窗口消息语义（待设计）：

- `window_minimize` / `window_restore` / `window_focus` / `window_blur` / `window_close`

当前阶段：Dart 工厂在 Windows 平台返回 `NoopLifeCycleAdapter`，不注册原生插件，避免半成品阻塞其他平台交付。

---

## 5. macOS 多窗口核心处理规范

### 5.1 底层机制

- Flutter 多窗口采用 **一窗口一 Engine 一 NSWindow** 官方标准模式
- 每个 Engine 拥有独立插件实例与独立 EventChannel 连接
- 所有事件上报携带 `windowId`、`isMainWindow` 扩展参数

### 5.2 典型多窗口场景

1. **App 内切换窗口 A→B**：A 失焦 + B 获焦，各自携带 windowId
2. **单窗口最小化**：仅目标窗口触发最小化事件
3. **App 切后台**：各窗口失焦 + 全局 `NSApplicationDidHideNotification`
4. **子窗口关闭**：仅当前窗口触发关闭事件，同步销毁 Channel 订阅

### 5.3 多窗口避坑约束

- 禁止多窗口共用同一个 EventChannel、同一个 windowId
- 窗口销毁必须同步移除 NSWindow 通知监听、取消流订阅
- 全局 App 事件需在上层做事件去重，避免多 Engine 重复推送

---

## 6. 业务层使用规范

### 6.1 初始化

在 App 启动时（每个 Flutter Engine 各调用一次）初始化：

```dart
import 'package:fast_lifecycle/fast_lifecycle.dart';

Future<void> bootstrapLifecycle() async {
  await RawLifeCycleManager.instance.initialize(
    options: const LifeCycleInitOptions(
      windowId: 'main',       // 桌面多窗口时传入唯一 ID
      isMainWindow: true,
    ),
  );
}
```

### 6.2 注册监听

```dart
void onLifecycleEvent(RawLifeCycleEvent event) {
  // 按平台 + 原生状态 + 作用域 做差异化逻辑
  switch (event.source) {
    case LifePlatformSource.ios:
      _handleIOS(event);
    case LifePlatformSource.android:
      _handleAndroid(event);
    case LifePlatformSource.macos:
      _handleMacOS(event);
    default:
      break;
  }
}

void _handleIOS(RawLifeCycleEvent event) {
  switch (event.rawState) {
    case 'applicationDidEnterBackground':
      // 进入后台，触发 App Lock 等
      break;
    case 'applicationWillEnterForeground':
      // 即将回前台
      break;
    default:
      break;
  }
}

void _handleAndroid(RawLifeCycleEvent event) {
  final scope = event.extra.lifecycleScope; // "process" | "activity"
  if (scope == 'activity' && event.rawState == 'ON_PAUSE') {
    // Activity 失焦
  }
  if (scope == 'process' && event.rawState == 'ON_STOP') {
    // App 整体不可见
  }
}

// 注册 / 移除
RawLifeCycleManager.instance.addListener(onLifecycleEvent);
// RawLifeCycleManager.instance.removeListener(onLifecycleEvent);
```

### 6.3 销毁

```dart
await RawLifeCycleManager.instance.dispose();
```

### 6.4 使用原则

- 业务层依赖 `RawLifeCycleManager` 单例，**不在 Widget 内直接操作 Channel**
- 通过 `source + rawState + extra.lifecycleScope + windowId` 组合判断，**禁止**假设存在跨平台统一状态
- 底层不提供任何统一状态枚举，完全放权上层业务
- 桌面多窗口：每个 Engine 独立 `initialize`，传入唯一 `windowId`

---

## 7. 架构红线（CodeReview 强制卡点）

1. 所有平台 **禁止抹平、翻译、重命名** 原生事件状态（**尤其禁止映射为 Flutter AppLifecycleState 四态**）
2. Android 必须 **分 process / activity 双层** 上报，通过 `extra.lifecycleScope` 区分
3. iOS 必须使用 **UIApplicationDelegate 方法名** 作为 rawState，覆盖全部六个回调
4. 移动端持续事件推送 **禁止** 使用 MethodChannel，必须使用 EventChannel
5. Web 层禁止引入任何 Flutter Channel 相关代码
6. 桌面端禁止依赖任何第三方窗口/生命周期插件
7. 所有监听必须实现 `dispose` 销毁逻辑，禁止内存泄漏
8. 多窗口事件必须携带唯一 `windowId`，保证事件可溯源
9. Channel 名称必须从 `LifecycleChannelNames` 引用，禁止硬编码

---

## 8. 待修正项（相对当前代码）

| 模块 | 状态 | 说明 |
|------|------|------|
| `AppLifecycleTracker.kt` | ✅ 已修正 | Process + Activity 双层，`ON_*` + `lifecycleScope` |
| `FastLifecyclePlugin.swift` (iOS) | ✅ 已修正 | UIApplicationDelegate 六个方法名一一对应 |
| `LifeCycleEventExtra` | ✅ 已修正 | 新增 `lifecycleScope` |
| macOS / Linux / Web | ✅ 已补充 | 各端 extra 携带对应 `lifecycleScope` |
| Windows | 📋 TODO | 保持 TODO，暂不交付 |

---

## 9. 架构优势总结

- **无信息丢失**：完整保留各平台系统原生生命周期语义，无二次映射损耗
- **双层精准**：Android process/activity、iOS 六回调、macOS 窗口/App 事件均可独立处理
- **多窗口精准可控**：macOS 多窗口隔离，事件可溯源
- **架构统一规整**：可复用 Channel + Base/Mixin 抽象，平台差异仅在 Mixin 层
- **零第三方依赖**：完全自主可控
- **调试友好**：日志直接输出原生 API 名，问题定位无歧义
