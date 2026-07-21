## Context

| 模块 | 现状 |
|------|------|
| `PasswordTabModel` | 已读 `vaults` / `folders` / `cipherEntries`，按 folder 分组展示 |
| `CipherAddModel` | 写 `cipherEntries`；无库时 `createDefaultVault()` 隐式建「我的保险库」 |
| `VaultSwitcherButton` | 仅切换，无「新建」 |
| `FolderRepository` | 读：`watchByVault`；写：未在 App 使用 |
| `cipher_add` | `saveCipher` 有 `folderUuid` 参数但未透传 |

约束：MVVM-C 分层、Riverpod 3、`StorageRepositories` 注入、名称 BLOB 用 `EncryptedNameCodec`。

## Goals / Non-Goals

**Goals:**

- 用户可在 Password Tab 主动创建保险库并自动选中
- 添加密码时可选择已有文件夹或新建，保存后首页分组正确
- 保留「无库时首次添加自动建默认库」兜底（委托 `VaultManageModel`）

**Non-Goals:**

- `CipherAttachmentRepository` 附件上传（独立 change）
- Vault/folder 改名、回收站、删除
- macOS/web/desktop 完整 UI（可沿用 iOS/Android 模式，空态最小实现）

## Decisions

### D1: 独立 `VaultManageModel` / `FolderManageModel`

**选择**：各建 `features/vault_manage/`、`features/folder_manage/`，不堆进 `PasswordTabModel`。

**理由**：写操作与 Tab 读逻辑解耦；`CipherAddModel` 与 Password Tab 均可复用。

### D2: 兜底建库仍保留，实现委托

`CipherAddModel.createDefaultVault()` → `VaultManageModel.createVault(name: '我的保险库')`，消除重复 insert 逻辑。

### D3: 文件夹 Provider 传参

新增 `cipherAddFolderIdProvider`（与 `cipherAddVaultIdProvider` 对称）。`null` = 未分组，不创建 fake folder 行。

### D4: 添加页文件夹 UI（首版）

Dropdown：「未分组」+ 当前 vault 下 folders + 「新建文件夹…」。新建用 dialog，成功后选中并刷新列表。

### D5: 新建保险库 UI（首版）

`VaultSwitcherButton` PopupMenu 末项「新建保险库」→ BottomSheet（名称输入）→ `VaultManageModel.createVault` → `PasswordTabViewModel.selectVault(newId)`。

空库：Password Tab 展示 CTA「创建保险库」，不强制走添加密码隐式建库。

## Risks / Trade-offs

- **[Risk] vaultId 未解析时 folder 列表为空** → 添加页先 `resolveVaultUuid` 或 watch 当前 `cipherAddVaultIdProvider`，无 vault 时隐藏 folder 选择
- **[Risk] 重复默认库** → `createVault` 仅用户显式触发；兜底逻辑仍检查 `watchActive()` 非空
- **[Trade-off] 无 folder 管理页** → 首版仅在添加页快捷新建

## Migration Plan

1. 落地 Model + 测试
2. 接入 Password Tab 建库 UI
3. 接入 cipher_add folder 选择与 save 透传
4. `melos run ci` 门禁

## Open Questions

1. ~~附件是否本 change~~ → 否，后续 change
2. 默认 vault 图标/颜色：首版固定 `iconName: person`，与现有兜底一致
