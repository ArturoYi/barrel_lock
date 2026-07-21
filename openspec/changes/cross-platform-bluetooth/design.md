## Context

- **已有**：`BackupBluetoothTransfer`（BLBT 512KB 逻辑帧）、`BackupBluetoothSessionMeta`（JSON 握手）、`BackupArchiveCodec`（BLBK）、同平台 Native P2P（iOS Multipeer / Android Nearby）、蓝牙共享页 + EventChannel 进度/发现事件
- **缺口**：Multipeer 与 Nearby 协议不互通；`data-migration` D7 明确首版不支持跨系统
- **约束**：MVVM-C + Riverpod 3；Native 不进 `core`；复用现有 import 路径；真机 + 前台传输

## Goals / Non-Goals

**Goals:**

- iOS ↔ Android 通过 **同一 BLE GATT 服务** 传输完整 BLBK 字节
- 发送/接收 UI 与现有蓝牙共享页一致（倒计时、状态、取消）
- 传输层与 BLBT 解耦：Native 只收发 GATT 字节；Dart 组 BLBG → BLBT → BLBK
- 明确 UUID、MTU 分片上限、验收标准与工期估算

**Non-Goals:**

- 移除或替换同平台 Multipeer/Nearby（**并存**）
- Web/Desktop BLE
- 后台/锁屏续传
- 压缩或增量备份
- Wi-Fi Aware / 热点桥接（备选，不实现）

## Decisions

### D1: 双层分片 — BLBG（GATT）+ BLBT（逻辑）

| 层 | Magic | 作用 | 典型大小 |
|----|-------|------|----------|
| **BLBT** | `BLBT` | 逻辑备份帧（已有） | 最大 512KB payload/帧 |
| **BLBG** | `BLBG` | GATT 物理写单元 | **≤ (negotiated_mtu − 16)**，默认目标 **512 字节 payload** |

**BLBG 帧布局**（little-endian）：

```
[magic BLBG: 4][u32 blbtFrameIndex][u32 gattChunkIndex][u32 gattChunkTotal][u32 payloadLen][payload]
```

- 一个 BLBT 帧可拆成多个 BLBG chunk；收端先按 `(blbtFrameIndex, gattChunkIndex)` 重组 BLBT，再 `decodeFrames`
- ** rationale**：BLE 单次 Write 受 MTU 限制（常见 185–512 有效 payload）；512KB BLBT 不能直接写 GATT

**BLBT `defaultChunkSize`**：跨平台 GATT 路径仍用 **512KB**（与 Nearby/Multipeer 一致），仅 GATT 层再拆 BLBG。

### D2: GATT UUID（128-bit，BarrelLock 专用）

| 资源 | UUID | 属性 |
|------|------|------|
| **Primary Service** | `A7B4C3D2-E5F6-4789-A012-3456789ABCDE` | BarrelLock Backup Transfer |
| **Control** | `A7B4C3D2-E5F6-4789-A012-3456789ABC01` | Write / Read — UTF-8 JSON 会话 meta（同 `BackupBluetoothSessionMeta` + `{"type":"end"}`） |
| **Data** | `A7B4C3D2-E5F6-4789-A012-3456789ABC02` | Write Without Response + Notify — 原始 BLBG 字节流 |

**角色约定**：

- **发送端（Central 发起连接）**：扫描 Service UUID → connect → 写 Control meta → 按序写 Data（BLBG chunks）→ 写 Control end
- **接收端（Peripheral 广播）**：启动 GATT Server 广播 Service → 接受连接 → Notify/Write 回调收 BLBG → 重组

（实现时可 Central/Peripheral 角色与 App「发送/接收」UI 角色对齐：接收端 Peripheral，发送端 Central。）

### D3: 传输模式路由（与同平台并存）

```
BackupBluetoothCompositeDelegate
├── mode: samePlatform → IosMultipeer / AndroidNearby（现有）
└── mode: crossPlatform → BleGattBackupDelegate（新）
```

- 角色选择 Sheet 增加第三项或二级：**「跨平台传输（iOS↔Android）」**
- `BluetoothBackupViewModel` 构造参数扩展：`BackupBluetoothTransportMode { samePlatform, crossPlatform }`
- 同平台路径 **零行为变更**

### D4: Flutter ↔ Native 通道

- 复用 EventChannel `com.barrellock/backup_p2p_events`（phase / peer / progress / error）
- 新增 MethodChannel `com.barrellock/backup_ble_gatt`：`transferSend` / `transferReceive` / `cancel`
- Dart：`BleGattBackupChannel` + `BleGattBackupDelegate implements BackupBluetoothDelegate`

### D5: MTU 与性能

- 连接后请求 **MTU 517**（Android `requestMtu`；iOS 自动协商）
- BLBG payload 默认 **512 字节**；若 MTU &lt; 530 则 `payload = mtu - 16`
- **50MB 备份估算**：~100 BLBT 帧 × ~1000 BLBG chunk ≈ 10 万+ GATT 写；**数分钟级**正常，UI 必须展示 progress
- 会话超时：**180s**（比同平台 120s 长，GATT 更慢）

### D6: 权限

- **Android**：已有 `BLUETOOTH_*` / `NEARBY_WIFI_DEVICES`；GATT 扫描需 `BLUETOOTH_SCAN`（已有）
- **iOS**：`NSBluetoothAlwaysUsageDescription`（已有）；CoreBluetooth 无需 Bonjour

## Risks / Trade-offs

| 风险 | 缓解 |
|------|------|
| 大附件传输极慢 | UI 进度 + 建议 &lt;50MB；超大包提示用文件导出 |
| BLE 连接不稳定 | 超时 180s；断线 fail + 可重试；BLBG 序号校验 |
| iOS 后台被杀 | 要求前台；OnDisconnect 清理 |
| Android 厂商 BLE 差异 | 真机矩阵验收；Write Without Response + 流控（chunk ack 可选 Phase 2） |
| 与同平台两套 Native 维护 | 共享 BLBT/Dart；Native 仅 GATT 壳 |

## Migration Plan

1. 合并后 **默认不改变** 同平台行为；跨平台为显式选项
2. 可先 **internal/TestFlight** 开启跨平台开关
3. 回滚：隐藏跨平台 UI 入口，保留 GATT 代码不注册 delegate

## Open Questions

1. 是否在 v1 加 **chunk ACK**（Control char `{type:"ack", blbtFrameIndex, gattChunkIndex}`）— 建议 **Phase D8.2** 若丢包率高再加
2. 发送端是否允许 **Android Central → iOS Peripheral** 双向对称 — 设计为 **对称**，验收双向

## 工期估算（1 名熟悉 Flutter + 双端 Native 开发者）

| 阶段 | 内容 | 估时 |
|------|------|------|
| **D8.0** | BLBG codec + 单元测试 + composite delegate 骨架 | **3–4 天** |
| **D8.1** | Android GATT Server/Client + Channel | **5–7 天** |
| **D8.2** | iOS CoreBluetooth GATT + Channel | **5–7 天** |
| **D8.3** | UI 模式选择 + 共享页适配 + Event 对齐 | **2–3 天** |
| **D8.4** | 双机矩阵验收（iOS→Android、Android→iOS、大/小包） | **3–5 天** |
| **合计** | | **约 3–4 周**（不含 ACK 重传增强） |
