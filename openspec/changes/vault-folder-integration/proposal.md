## Why

添加密码流程已能隐式创建默认保险库并写入 `cipher`，但用户无法主动新建/管理保险库；`FolderRepository` 已在密码 Tab 读侧使用，却缺少写入与 `cipher_add` 关联，导致所有新条目 `folder_uuid` 恒为 NULL。需要补齐 vault/folder 写路径，使多库与文件夹分组具备完整产品闭环。

## What Changes

- 新增 `VaultManageModel`：显式创建保险库（名称加密写入 `vault` 表），`CipherAddModel` 兜底建库委托该 Model
- 密码 Tab 保险库切换器增加「新建保险库」入口；空库态引导创建首个保险库
- 新增 `FolderManageModel`：创建文件夹、按 vault 监听 active folders
- `cipher_add` 增加文件夹选择（含「未分组」与快捷新建），保存时写入 `folder_uuid`
- 单元测试覆盖 vault/folder 写入与 cipher 关联

## Capabilities

### New Capabilities

- `vault-manage`: 用户主动创建保险库、Password Tab 切换与空态引导
- `folder-manage`: 文件夹创建与按 vault 查询
- `cipher-add-folder`: 添加密码页选择/新建文件夹并持久化 `folder_uuid`

### Modified Capabilities

（无 archive 存量 spec；本 change 以 delta spec 自洽）

## Impact

- **barrel_lock**：新 features `vault_manage/`、`folder_manage/`；扩展 `cipher_add` Model/ViewModel/Provider
- **BarrelLock_ios / BarrelLock_android**：`VaultSwitcherButton`、添加页文件夹 UI、空库引导
- **packages/core**：仓储 API 不变（沿用 `VaultRepository` / `FolderRepository`）
- **Out of scope**：`CipherAttachmentRepository`、备份日志、vault 改名/回收（后续 change）
