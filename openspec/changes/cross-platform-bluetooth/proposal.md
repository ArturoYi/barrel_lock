## Why

`data-migration` Phase 4 已实现同平台 P2P（iOS Multipeer / Android Nearby），但 **iOS↔Android 无法互传**——底层 discovery 与链路协议不兼容。用户换机跨系统时只能走「导出文件」，体验断层。`data-migration` design D8 已规划统一 **BLE GATT** 作为跨平台传输层；在 BLBT/BLBK 共享层已就绪的前提下，现单独立项推进 D8。

## What Changes

- 定义 BarrelLock 跨平台 **BLE GATT 备份服务**（固定 Service/Characteristic UUID、GATT 分片格式 `BLBG`、与现有 BLBT 帧衔接）
- iOS（CoreBluetooth）与 Android（BluetoothLe GATT）各实现 **GATT Server/Client** 原生层，经 MethodChannel + EventChannel 注入
- 扩展 `BackupBluetoothDelegate` 或新增 **传输模式路由**：「同系统附近连接」（现有 Nearby/Multipeer）与「跨平台蓝牙」（GATT）
- 蓝牙共享页 / 角色选择 UI：支持跨平台文案与倒计时；同平台路径保持不变
- GATT 路径仍传输完整 `.blbak` 字节，收端复用 `BackupArchiveCodec.decode` + merge/replace 导入
- 双机验收门禁：**iOS send → Android receive** 与 **Android send → iOS receive**
- 大备份包（含 attachment）通过 **GATT MTU 分片 + BLBT 512KB 逻辑帧** 双层拆分；文档注明建议 &lt;50MB、传输耗时预期

## Capabilities

### New Capabilities

- `ble-gatt-backup-transport`: BLE GATT 服务 UUID、特征值、BLBG 分片协议、MTU 协商、iOS/Android native 传输与 Dart 编解码
- `cross-platform-bluetooth-ui`: 传输模式选择（同系统 / 跨平台）、共享页状态与权限提示、失败/超时 UX

### Modified Capabilities

- `data-migration-bluetooth`: 在 Phase 4 同平台 P2P 基础上 **ADD** 跨平台 GATT 传输需求；更新「仅同系统」限制文案为「默认同系统；跨平台需选 GATT 模式」

## Impact

- **barrel_lock**：`BackupBluetoothTransfer` 可选 GATT 分片 helper；`BackupBluetoothDelegate` 路由或 composite；EventChannel 事件复用/扩展
- **BarrelLock_ios**：CoreBluetooth GATT peripheral/central；Info.plist 已有蓝牙权限可复用；**不**替换 Multipeer 实现
- **BarrelLock_android**：`BluetoothLeAdvertiser` / GATT server+client；与 Nearby 实现并存
- **Out of scope**：桌面/Web 蓝牙、后台传输、多设备广播、替换文件导入路径、修改 BLBK 格式
