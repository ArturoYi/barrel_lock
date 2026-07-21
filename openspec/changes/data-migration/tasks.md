## 1. Phase 1 — 备份包格式（backup-archive）

- [x] 1.1 新建 `barrel_lock/lib/features/backup_manage/backup_archive_codec.dart`：magic `BLBK`、formatVersion、`AppCrypto` 外层加密
- [x] 1.2 定义 `BackupSnapshot` / table DTO（vault/folder/cipher/cipher_attachment），BLOB 字段 JSON 传输用 base64
- [x] 1.3 实现 `encode` / `decode` + SHA-256 checksum 校验
- [x] 1.4 拒绝 unsupported `formatVersion` / 过高 `appSchemaVersion`
- [x] 1.5 `test/backup_archive_codec_test.dart`：round-trip、篡改拒绝、空库、含 attachment

## 2. Phase 1 — BackupManageModel（backup-manage）

- [x] 2.1 新建 `backup_manage_model.dart`：注入 `StorageRepositories`
- [x] 2.2 `createSnapshotBytes()`：聚合四表只读快照
- [x] 2.3 `createLocalBackup()`：`path_provider` 写 `{documents}/backups/{logId}.blbak` + insert `backup_log`
- [x] 2.4 `watchRecentBackups()`：封装 `backupLogs.watchAll()` 排序
- [x] 2.5 `restoreFromBytes(bytes, mode: merge|replace)`：事务内 merge upsert 或 replace deleteAll+insert
- [x] 2.6 `restoreFromLocalBackup(logId, mode)`：读文件后委托 2.5
- [x] 2.7 可选：`pruneOldBackups(maxCount: 5)` 删最旧文件与 log 行
- [x] 2.8 export + `barrel_lock.dart`；`test/backup_manage_model_test.dart`

## 3. Phase 2 — 本地备份/恢复 UI（data-migration-local-backup）

- [x] 3.1 扩展 `DataMigrationViewState`：busy、lastError、可选 `recentBackups` stream
- [x] 3.2 `DataMigrationViewModel`：`onActionTap('backup')` → `createLocalBackup`；`'restore'` → 打开列表
- [x] 3.3 `DataMigrationCoordinator`：`openRestoreSheet` / push 备份列表子页
- [x] 3.4 iOS/Android 新建 `BackupRestoreSheet`（或 subpage）：列表、merge/replace 确认、危险色 replace 文案
- [x] 3.5 替换 `onActionTap` 中 backup/restore 的 Toast 占位
- [x] 3.6 手动验收：备份 → 改一条 cipher → merge 恢复 / replace 恢复

## 4. Phase 3 — 文件导出/导入（data-migration-file-transfer）

- [x] 4.1 在 barrel_lock 定义 `BackupFileDelegate`（saveBytes / pickBytes / shareBytes）抽象 + Provider
- [x] 4.2 iOS/Android 实现 delegate（`file_picker` + 可选 `share_plus`）；登记 app `pubspec.yaml`
- [x] 4.3 `onActionTap('export_file')`：snapshot → delegate 保存/分享
- [x] 4.4 `onActionTap('import_file')`：delegate 选文件 → 校验 → merge/replace 对话框 → restore
- [x] 4.5 replace 导入前可选自动 `createLocalBackup()` 安全快照
- [x] 4.6 手动验收：导出 `.blbak` → 删库或换设备路径 → 导入 merge

## 5. Phase 4 — 蓝牙（data-migration-bluetooth）

- [x] 5.1 将 `bluetooth_share` 占位改为明确「即将推出」文案（若 Phase 4 未做）
- [x] 5.2 选型：Android Nearby Connections + iOS MultipeerConnectivity（见 `design.md` D7）
- [x] 5.3 `BackupBluetoothDelegate` + `backupBluetoothDelegateProvider`（barrel_lock）
- [x] 5.4 `BackupBluetoothTransfer` 分片协议 BLBT + 单元测试
- [x] 5.5 `DataMigrationViewModel`：`BluetoothRolePickerRequest` / send / receive → 复用 import 流程
- [x] 5.6 iOS/Android `bluetooth_backup_sheet.dart` + `DataMigrationPage` 接入
- [x] 5.7 平台 stub：`AndroidBackupBluetoothDelegate` / `IosBackupBluetoothDelegate` + main override
- [x] 5.8 Android：接入 `nearby_connections`（广告/发现/连接/按帧 sendPayload）
- [x] 5.9 iOS：接入 MultipeerConnectivity（Platform Channel 或插件）+ Info.plist 权限
- [ ] 5.10 双机验收：同平台 send → receive → merge 导入

## 6. 质量门禁

- [ ] 6.1 `melos run format`
- [ ] 6.2 `melos run analyze`（core + barrel_lock + 改动 app）
- [ ] 6.3 `melos run test`（新增 backup 相关测试）

## 7. 关联后续（非阻塞）

- [ ] 7.1 `clear_data` Model 接入真实 `StorageRepositories.deleteAll`（与 replace 复用）
- [ ] 7.2 文档：`密码App数据表设计.md` 补充 `.blbak` 格式说明一节
