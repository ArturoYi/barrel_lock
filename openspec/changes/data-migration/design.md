## Context

| 模块 | 现状 |
|------|------|
| `DataMigrationPage` (iOS/Android) | 列表 UI 就绪，绑定 `dataMigrationViewModelProvider` |
| `DataMigrationModel` | 定义 5 个 action：`export_file` / `import_file` / `bluetooth_share` / `backup` / `restore` |
| `DataMigrationViewModel` | `onActionTap` → `FastToast.show('功能开发中')` |
| `StorageRepositories` | `vaults` / `folders` / `cipherEntries` / `cipherAttachments` / `backupLogs` 均已接入 Drift |
| `backup_log` 表 | 字段含 `backup_path`、`backup_password_salt`、`vault_version`；尚无写入逻辑 |
| `BarrelLockMasterKey` | v1 固定密钥，便于同包跨设备恢复；生产须换 KDF |
| 附件 | `cipher-attachment` change 已将 BLOB 入库，备份须包含 `cipher_attachment` 行 |

约束：MVVM-C、Riverpod 3、`AppCrypto` ChaCha20-Poly1305、路由仅用 `fast_navigator`。

## Goals / Non-Goals

**Goals:**

- 提供可渐进交付的 4 步实现路径：① 备份包格式 → ② 本地备份/恢复 → ③ 文件导出/导入 → ④ 蓝牙（可选 defer）
- 备份内容为**已加密 BLOB 的透传打包**，不在备份层二次解密业务数据
- 导入支持 **merge**（按 UUID  upsert，保留本地独有项）与 **replace**（清空业务表后写入）
- 每次本地/文件备份写入 `backup_log`，恢复页可展示元数据

**Non-Goals:**

- 云同步、WebDAV、iCloud 自动备份
- 备份包独立口令（`backup_password_salt` 首版写占位随机 salt，UI 不收集口令）
- 跨不同主密钥的迁移（需未来「导出密钥」change）
- 蓝牙/NFC 协议细节（Phase 4 或独立 change）
- 桌面/Web 平台文件选择器（首版 iOS + Android）

## Decisions

### D1: 备份包格式 — JSON 容器 + 外层加密（`.blbak`）

**结构（解密后 JSON）**:

```json
{
  "formatVersion": 1,
  "appSchemaVersion": 1,
  "exportedAt": "ISO8601",
  "tables": {
    "vault": [ /* Vault row maps, BLOB fields base64 in JSON transport only */ ],
    "folder": [],
    "cipher": [],
    "cipher_attachment": []
  },
  "checksum": "sha256(hex of canonical tables JSON)"
}
```

**文件布局**: `[4 byte magic "BLBK"][4 byte formatVersion LE][EncryptedPayload from AppCrypto.encrypt(utf8 json)]`

**理由**:

1. 与 `EncryptedPayload` / `AppCrypto` 一致，复用现有 crypto 栈
2. JSON 便于版本演进、单元测试 round-trip；BLOB 字段在 JSON 层用 base64 **仅作传输**，落库仍写原始 BLOB（符合表设计「禁止 Base64 入库」）
3. 外层再加密一层，防止备份文件被直接读取表结构

**备选**: SQLite 文件直拷 — 简单但含 Drift 内部状态、跨 schema 版本难控；**不采用**。

### D2: Model 分层

| 层 | 职责 |
|----|------|
| `BackupArchiveCodec` | 读写 `.blbak` 字节、校验 magic/checksum/formatVersion |
| `BackupManageModel` | 从 `StorageRepositories` 快照 → 打包；解包 → merge/replace 写回；写 `backup_log` |
| `DataMigrationViewModel` | 编排 action、busy/error 状态、触发 Coordinator |
| `DataMigrationCoordinator` | 打开子页 / Sheet：`BackupListSheet`、`ImportConfirmSheet`、系统 share |

本地备份目录：`path_provider` → `{appDocuments}/backups/{logId}.blbak`。

### D3: 导入策略

| 模式 | 行为 |
|------|------|
| **merge** | 按主键 UUID upsert；目标库有而包无的行保留 |
| **replace** | `deleteAll` on vault/folder/cipher/attachment（或事务内 truncate 业务表），再 insert 包内全量 |

导入前 MUST 校验 `formatVersion` 与 `appSchemaVersion <= DatabaseSchemaVersion.current`；更高版本拒绝并提示升级 App。

### D4: UI 分阶段交付

| Phase | Action IDs | 交付物 |
|-------|------------|--------|
| **1** | — | `BackupArchiveCodec` + `BackupManageModel` + 单元测试 |
| **2** | `backup`, `restore` | 本地目录备份、备份列表 Sheet、恢复确认 |
| **3** | `export_file`, `import_file` | `file_picker` + 可选 `share_plus`、导入 merge/replace 对话框 |
| **4** | `bluetooth_share` | 占位改「即将推出」或启动 `data-migration-bluetooth` 子 change |

`DataMigrationPage` 本身可不变；子流程用 Coordinator push 新 route 或 `FastDialog` / BottomSheet。

### D5: 平台依赖

- `path_provider` — 本地备份目录（workspace 已有传递依赖）
- `file_picker` — 选 `.blbak` 导入、选保存位置导出
- `share_plus` — 导出后系统分享（可选，iOS/Android app `pubspec.yaml` 新增）

注入方式：在 barrel_lock 定义 `BackupFileDelegate` abstract interface，iOS/Android app 通过 Riverpod override 注入，避免 barrel_lock 直接依赖 Flutter 插件。

### D7: 蓝牙迁移 — 平台 P2P + 共享 BLBK（Phase 4 选型结论）

**选择**：不复用 BLE GATT 自定义服务；采用各平台原生 P2P API，经 `BackupBluetoothDelegate` 注入：

| 平台 | API | Flutter 集成 |
|------|-----|----------------|
| Android | [Nearby Connections](https://developers.google.com/nearby/connections/overview) | App 层 `nearby_connections` 插件（**不进 core**，Android 专用） |
| iOS | [MultipeerConnectivity](https://developer.apple.com/documentation/multipeerconnectivity) | App 层 Platform Channel 或专用插件（**不进 core**） |

**传输 payload**：仍为完整 `.blbak` 字节；大文件在 delegate 内按 512KB 分片，帧格式由 `BackupBluetoothTransfer`（纯 Dart，barrel_lock）统一编解码。

**导入路径**：收端 bytes → `BackupArchiveCodec.decode` → 复用现有 `ImportModePickerRequest` / `restoreFromBytes`（与文件导入一致）。

**限制（首版 UI 须说明）**：

- Android ↔ iOS **不能**互传（底层协议不同，行业通用限制）
- 需**真机**、双方 App 在前台；模拟器不支持
- 传输内容为已加密 BLBK，但仍需用户确认对端可信

**权限**：Android `BLUETOOTH_*` / `NEARBY_WIFI_DEVICES` / 定位（旧 API）；iOS `NSBluetoothAlwaysUsageDescription`、`NSLocalNetworkUsageDescription`、`NSBonjourServices`。

**备选 BLE GATT**：仅适合 &lt;100KB；附件备份不适用 → **不采用**。

### D8: 跨平台蓝牙（后续阶段）

**现状（Phase 4 v1）**：iOS 使用 MultipeerConnectivity，Android 使用 Nearby Connections；二者 discovery / framing 不互通，故 **iOS↔Android 暂不支持**。

**共享层（已实现）**：`BackupBluetoothTransfer`（BLBT 帧）+ `BackupBluetoothSessionMeta`（JSON 握手）+ `BackupArchiveCodec`（BLBK 载荷）与底层传输 **解耦**。各平台 delegate 只负责「连上对端 + 按序收发 Data」。

**跨平台路径（规划）**：

1. **首选**：双方统一 **BLE GATT 自定义服务**（或 Wi-Fi Aware 抽象），Dart 仍只编解码 BLBT；Android / iOS native 各实现同一 GATT UUID 与 MTU 分片。
2. **备选**：一端 Multipeer / Nearby 作热点，对端通过 companion 协议桥接（复杂度高，非首版）。
3. **产品文案**：同平台可用；跨平台提示「请先用导出到文件」直至 D8 落地。

**验收**：D8 完成后以 **iOS send → Android receive**（及反向）BLBT round-trip 为门禁；单元测试仍覆盖纯 Dart 编解码。

### D6: `backup_log` 写入

创建备份（本地或导出到固定路径）时 insert 一行：

- `logId` = 新 UUID
- `backupTime` / `createdAt` = now
- `backupPath` = 绝对路径或 null（仅 memory export 时可 null）
- `backupPasswordSalt` = 随机 16 字节（占位，未来口令加密用）
- `vaultVersion` = `DatabaseSchemaVersion.current`
- `isEncrypted` = true
- `note` = 用户可选备注（Phase 2 可 null）

## Risks / Trade-offs

| 风险 | 缓解 |
|------|------|
| 大库 + 附件导致备份包过大、内存峰值 | 首版全量内存打包；文档注明建议 &lt;50MB；后续可做 streaming |
| replace 误删 | 二次确认 + 导入前自动创建本地快照 |
| schema 升级后旧包无法导入 | 校验 `appSchemaVersion`；未来加 migration adapter |
| 固定主密钥泄露则备份可解密 | 与当前 v1 一致；文档提醒生产换 KDF |
| 蓝牙复杂度高阻塞主线 | Phase 4 独立 defer，spec 保留占位 |

## Migration Plan

1. 合并 Phase 1–2 后可独立发布「本地备份/恢复」
2. Phase 3 不破坏 Phase 2 数据路径
3. 无 DB schema 变更（首版）；若后续加 `backup_log` 索引再开 migration
4. 回滚：删除 `backups/` 目录与相关代码；`backup_log` 行可保留

## Open Questions

1. 本地备份保留份数上限（默认 5）— 已在 Phase 2 实现 `pruneOldBackups`
2. merge 时 vault/folder 树冲突（同名不同 UUID）— 首版仅 UUID 级 upsert，不做名称合并
3. ~~蓝牙采用 BLE GATT vs Multipeer/Nearby~~ — **已决**：见 D7
