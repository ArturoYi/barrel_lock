# Flutter 全平台原生生命周期监听架构需求文档（无第三方、不抹平原生）

## 1\. 文档概述

### 1\.1 设计目标

- **零第三方依赖**：不使用 `visibility_detector`、`window_manager` 等外部插件，全自研底层能力

- **不抹平平台原生状态**：完整保留 Android / iOS / macOS / Windows / Linux / Web 系统原生生命周期事件名，不做统一枚举映射

- **全平台统一架构分层**：多端适配同一套抽象接口、通信通道规范、事件数据结构

- **精准区分多窗口场景**：完美支持 macOS/Windows 多窗口独立生命周期隔离，可精准定位事件所属窗口

- **解耦业务与底层平台差异**：底层负责采集透传，上层业务自主按需区分平台与原生状态

### 1\.2 适用范围

Flutter 全平台项目（Android、iOS、Windows、macOS、Linux、Web），作为项目底层基础架构能力，统一管控应用/窗口/页面生命周期监听能力。

## 2\. 核心架构设计规范

### 2\.1 整体分层架构（四层架构）

自上而下分层，严格单向依赖，层级隔离不可跨层调用

1. **业务门面层**：全局单例管理器，统一注册/移除监听、事件分发，无状态转换、无平台判断

2. **抽象适配层**：定义统一适配器基类，强制所有平台实现统一接口

3. **平台实现层**：分平台独立实现监听逻辑，透传原生事件，无任何状态抹平

4. **系统原生层**：各端原生API采集生命周期事件，原样回传，不做翻译修改

### 2\.2 统一核心数据结构（全局唯一）

所有平台事件输出统一结构体，仅原生状态值差异化，结构完全一致

- **平台来源枚举**：精准标记事件所属端 `android / ios / windows / macos / linux / web`

- **事件实体 RawLifeCycleEvent**

    - source：LifePlatformSource 平台来源

    - rawState：系统原生原始事件字符串（核心：不抹平、不修改、不统一）

    - extra：扩展参数（窗口ID、是否主窗口、窗口尺寸等）

- **统一回调**：全局唯一事件分发回调，业务层统一接收

### 2\.3 抽象适配器规范

所有平台适配器必须继承统一基类，强制实现两个核心方法

- `listen()`：初始化监听，接收原生事件并透传分发

- `dispose()`：销毁监听、释放通道、移除原生订阅，杜绝内存泄漏

**强制约束**：所有适配器**禁止**对 rawState 做 if/switch 状态映射、命名修改。

## 3\. 全平台通信通道选型规范（架构强制标准）

严格区分各平台通道类型，统一通信范式，杜绝混用、滥用通道

|平台|通道方案|用途分工|核心约束|
|---|---|---|---|
|Android / iOS|EventChannel\(主\) \+ MethodChannel\(辅\)|EventChannel：流式持续推送原生生命周期状态MethodChannel：启停监听控制指令|禁止用MethodChannel推送持续事件|
|Windows/macOS/Linux|自研原生插件 EventChannel|推送窗口独立事件、App全局事件，携带窗口ID|不依赖window\_manager，纯自研原生能力|
|Web|无Flutter Channel，纯dart:html|监听浏览器visibility、focus、blur原生事件|禁止引入任何Method/EventChannel代码|

## 4\. 各平台原生事件透传规则（不抹平核心规则）

### 4\.1 移动端 Android / iOS

完全透传系统原生 `AppLifecycleState` 原始字符串：

- resumed、inactive、paused、detached

### 4\.2 Web 端

完全透传浏览器原生事件语义，自定义原生语义化字符串（无修改）：

- visibilitychange\_hidden、visibilitychange\_visible

- window\_focus、window\_blur

### 4\.3 桌面端 Windows / Linux

透传窗口原生事件：

- window\_minimize、window\_restore、window\_focus、window\_blur、window\_close

### 4\.4 macOS 专属规则（重点：多窗口隔离）

直接透传 **NSWindow / NSApplication 系统原生通知名**，不做任何重命名，严格区分单窗口事件与App全局事件

#### 4\.4\.1 单窗口独立事件（分窗口隔离触发）

- NSWindowDidBecomeKeyNotification（窗口获焦）

- NSWindowDidResignKeyNotification（窗口失焦）

- NSWindowDidMiniaturizeNotification（窗口最小化）

- NSWindowDidDeminiaturizeNotification（窗口还原）

- NSWindowWillCloseNotification（窗口即将关闭）

#### 4\.4\.2 App 全局事件（全窗口统一触发）

- NSApplicationDidHideNotification（App整体隐藏切后台）

- NSApplicationDidUnhideNotification（App恢复前台）

## 5\. macOS 多窗口核心处理规范（架构重点）

### 5\.1 底层机制

- Flutter 多窗口采用 **一窗口一Engine一NSWindow** 官方标准模式

- 每个窗口绑定独立 EventChannel，通道携带唯一窗口标识，事件完全隔离

- 所有事件上报携带 `windowId`、`isMainWindow` 扩展参数

### 5\.2 典型多窗口场景事件规则

1. **App内切换窗口A→B**：A窗口失焦事件、B窗口获焦事件，分别携带各自windowId

2. **单窗口最小化**：仅目标窗口触发最小化事件，其他窗口无响应

3. **App切后台**：所有窗口触发失焦事件 \+ 全局App隐藏事件

4. **子窗口关闭**：仅当前窗口触发关闭事件，同步销毁对应Channel订阅与原生监听

### 5\.3 多窗口避坑约束

- 禁止多窗口共用同一个EventChannel、同一个windowId

- 窗口销毁必须同步移除NSWindow通知监听、取消流订阅，杜绝内存泄漏

- 全局App事件需在上层做事件去重，避免多Engine重复推送

## 6\. 业务层使用规范

- 业务层仅依赖全局单例 `RawLifeCycleManager`，无任何平台硬编码判断

- 业务自主通过`source(平台) + rawState(原生状态) + windowId(窗口标识)` 做差异化逻辑

- 底层不提供任何统一状态枚举、不封装通用逻辑，完全放权上层业务

## 7\. 架构红线（CodeReview 强制卡点）

1. 所有平台**禁止抹平、翻译、重命名原生事件状态**

2. 移动端生命周期推送**禁止使用MethodChannel**，必须使用EventChannel

3. Web 层禁止引入任何 Flutter Channel 相关代码

4. 桌面端禁止依赖任何第三方窗口/生命周期插件，必须自研原生EventChannel能力

5. 所有监听必须实现dispose销毁逻辑，禁止内存泄漏

6. 多窗口事件必须携带唯一windowId，保证事件可溯源

## 8\. 架构优势总结

- **无信息丢失**：完整保留各平台系统原生生命周期语义，无二次映射损耗

- **多窗口精准可控**：完美支持macOS/Windows多窗口隔离，解决官方方案与第三方插件的混乱问题

- **架构统一规整**：移动端、桌面端统一EventChannel规范，Web独立适配，分层清晰

- **零第三方依赖**：完全自主可控，无版本兼容、插件废弃风险

- **可扩展性极强**：新增平台事件、窗口属性仅需底层适配，上层业务无改动

- **调试友好**：日志可直接输出系统原生状态，问题定位高效无歧义

> （注：部分内容可能由 AI 生成）
