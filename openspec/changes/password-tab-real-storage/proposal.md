## Why

首页「密码」Tab 当前依赖 `PasswordTabModel` 中的硬编码 vault 列表与 `_seedCiphers()` 假数据，无法反映用户真实保险库内容。`packages/core/lib/storage` 已提供 Drift 表结构与 `StorageRepositories`，但 App 启动尚未调用 `AppStorage.init()`，业务层也未接入仓储与 overview 解密，需要一次系统性替换以验证存储层设计并支撑后续新建/编辑密码流程。

## What Changes

- 在 `runBarrelLockApp` 启动链中补充 `AppStorage.init()`，与现有 `SPStorage.init` / `BarrelLockCrypto.init` 顺序对齐
- 新增 Riverpod 注入：`StorageRepositories`（及可选的仓储 Provider），供 `barrel_lock` feature 使用
- 删除 `PasswordTabModel` 中全部 mock vault、cipher seed 与硬编码 folder 名称映射
- 新增 `CipherOverviewCodec`（overview BLOB ↔ 列表展示字段），遵循「列表仅解密 overview_blob」规范
- 扩展仓储查询：按 vault 过滤 cipher、排除软删除（`deleted_at` / `is_trashed`）
- 将 `PasswordTabViewModel` 改为响应式数据源（`watchAll` Stream 或 `AsyncNotifier`），DB 变更自动刷新 UI
- 收藏切换、vault 切换、筛选/搜索改为基于真实解密后的 overview 数据
- 补充单元测试：codec 往返、空库展示、有数据分组

## Capabilities

### New Capabilities

- `app-storage-bootstrap`：App 启动初始化 SQLite 单例，并通过 Riverpod 暴露 `StorageRepositories`
- `cipher-overview-codec`：密码条目 overview BLOB 的 JSON 编解码与 `AppCrypto` 加解密封装
- `password-tab-storage`：密码 Tab Model/ViewModel 从仓储读取 vault/folder/cipher 并驱动现有 UI

### Modified Capabilities

（无：`openspec/specs/` 尚无存量 spec）

## Impact

- **packages/core**：可能新增仓储扩展查询（`CipherEntryRepository` / `VaultRepository` / `FolderRepository`）
- **apps/BarrelLock/barrel_lock**：`password_tab_model.dart`、`password_tab_view_model.dart`、新增 codec / provider / 可能的 repository 扩展
- **apps/BarrelLock/barrel_lock_ui**：`run_barrel_lock_app.dart` 增加 `AppStorage.init`
- **apps/BarrelLock/* 平台 View**：若 ViewModel 变为 `AsyncValue`，需处理 loading / error / empty 态（**BREAKING**：Provider 类型可能从 `Notifier` 变为 `AsyncNotifier`）
- **测试**：`password_tab` 相关测试须改用 `AppStorage.initForTesting()` + 内存库 seed，不再依赖 mock 常量 ID
