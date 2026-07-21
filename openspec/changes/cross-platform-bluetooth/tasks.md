## 1. Phase D8.0 — BLBG 协议与 Dart 层（ble-gatt-backup-transport）

- [x] 1.1 新建 `backup_ble_gatt_transfer.dart`：`BLBG` magic、encode/decode chunk、BLBT↔BLBG 拆分/重组
- [x] 1.2 单元测试：单 BLBT 帧多 chunk round-trip、乱序/丢 chunk 拒绝、空包与 1MB 逻辑帧
- [x] 1.3 新建 `BleGattBackupChannel` MethodChannel + 复用 `BackupP2pEventChannel`
- [x] 1.4 新建 `BleGattBackupDelegate implements BackupBluetoothDelegate`
- [x] 1.5 新建 `BackupBluetoothCompositeDelegate`：`BackupBluetoothTransportMode` 路由 samePlatform / crossPlatform
- [x] 1.6 扩展 `BackupBluetoothTransfer` 或 helper：GATT 路径 payload 上限 `(mtu - 16)` 默认 512

## 2. Phase D8.1 — Android CoreBluetooth GATT（ble-gatt-backup-transport）

- [x] 2.1 新建 `BackupBleGattHandler.kt`：Peripheral（接收）+ Central（发送）
- [x] 2.2 实现 Service/Characteristic UUID（design D2）；Control JSON meta/end；Data BLBG 流
- [x] 2.3 MTU 请求 517；按 MTU 计算 BLBG payload 上限
- [x] 2.4 EventChannel：discovering / connected / progress / error（对齐现有事件名）
- [x] 2.5 `MainActivity` 注册 Channel；权限复用现有 Nearby 蓝牙权限
- [x] 2.6 Android `BleGattBackupDelegate` 或 composite 注入 `main.dart`

## 3. Phase D8.2 — iOS CoreBluetooth GATT（ble-gatt-backup-transport）

- [x] 3.1 新建 `BackupBleGattHandler.swift`：CBPeripheralManager（接收）+ CBCentralManager（发送）
- [x] 3.2 同上 UUID / Control / Data / BLBG 收发
- [x] 3.3 注册 MethodChannel + EventChannel（`AppDelegate` 或独立 Plugin）
- [x] 3.4 iOS composite delegate 注入；**保留**现有 Multipeer 实现

## 4. Phase D8.3 — UI 与 VM（cross-platform-bluetooth-ui）

- [x] 4.1 扩展 `BluetoothBackupRoute` / 角色 Sheet：同系统 vs 跨平台（send/receive 共 4 或 2+2 入口）
- [x] 4.2 `BluetoothBackupViewModel` 增加 `BackupBluetoothTransportMode` family 参数或 provider
- [x] 4.3 跨平台 copy：180s 倒计时、进度、前台提示；同平台 copy 不变
- [x] 4.4 iOS / Android 共享页或平台页接入 composite delegate
- [x] 4.5 更新 `data_migration` 入口 subtitle（可选）：说明支持跨平台 BLE

## 5. Phase D8.4 — 验收与门禁（data-migration-bluetooth）

- [ ] 5.1 双机：iOS send → Android receive → merge 导入
- [ ] 5.2 双机：Android send → iOS receive → merge 导入
- [ ] 5.3 小包（空库）与中含 attachment 的包（记录耗时）
- [ ] 5.4 超时 / 取消 / 权限拒绝 UX
- [ ] 5.5 `melos run ci`（barrel_lock + ios/android 改动包）

## 6. 可选后续（非阻塞）

- [ ] 6.1 Control char ACK 重传（design Open Question #1）
- [ ] 6.2 同步 `data-migration` design D8 到 main spec archive
