## Why

设置页「数据迁移」已预留 5 个入口（导出文件、从文件导入、蓝牙共享、本地备份、恢复备份），UI 与 MVVM-C 骨架就绪，但 `DataMigrationViewModel.onActionTap` 仍仅弹出「功能开发中」。与此同时 `vault` / `folder` / `cipher` / `cipher_attachment` 已接入真实存储，`backup_log` 表与 `BackupLogRepository` 也已定义，具备实现加密备份/恢复的基础。用户换机、误删恢复、跨设备迁移需要一套可渐进交付的能力，而非一次性大改。

## What Changes

- 定义 BarrelLock 加密备份包格式（`.blbak`），打包全量密码库密文（含附件 BLOB）及 schema 版本元数据
- 新增 `BackupManageModel`：创建备份、校验包、合并/覆盖导入、写入 `backup_log`
- 实现「本地备份 / 恢复备份」：应用沙盒内保留快照，列表展示最近备份，一键还原
- 实现「导出到文件 / 从文件导入」：系统文件选择器 + 可选 Share Sheet；导入前二次确认（合并 vs 覆盖）
- 扩展 `DataMigrationViewModel` / Coordinator：各 action 跳转子流程或弹 Sheet，替换 Toast 占位
- iOS / Android 接入 `file_picker`（及导出时的 `share_plus` 可选）；平台权限与错误提示
- 「蓝牙共享」首版仅保留入口占位或明确 defer 至独立 change（复杂度高、需 Nearby/蓝牙协议选型）
- 单元测试覆盖打包/解包 round-trip、损坏包拒绝、合并策略

## Capabilities

### New Capabilities

- `backup-archive`: 加密备份包格式、序列化/反序列化、完整性校验（checksum / schema version）
- `backup-manage`: Model 层创建/列举/删除本地备份、导入合并与覆盖策略、写 `backup_log`
- `data-migration-local-backup`: 数据迁移页「本地备份」「恢复备份」子流程与 UI 状态机
- `data-migration-file-transfer`: 数据迁移页「导出到文件」「从文件导入」与系统文件交互
- `data-migration-bluetooth`: 附近设备蓝牙传输（**Phase 4 / 可选 defer**，独立 spec 便于后续实现）

### Modified Capabilities

（无 archive 存量 spec；本 change 以 delta spec 自洽）

## Impact

- **packages/core**：可选扩展 `BackupLogRepository`（按时间排序、最近一条）；备份包 IO 主要在 barrel_lock
- **barrel_lock**：新 feature `backup_manage/`；扩展 `data_migration` VM/Coordinator/Model；`clear_data` 后续可复用 wipe API
- **BarrelLock_ios / BarrelLock_android**：数据迁移子页或 BottomSheet（备份列表、导入确认）；`file_picker` / `share_plus` 依赖
- **Out of scope（首版）**：云同步、增量备份、跨主密钥迁移（用户须使用相同 `BarrelLockMasterKey` 或后续口令 KDF change）、桌面/Web 蓝牙、备份包口令二次加密 UI（可预留 `backup_password_salt` 字段）
