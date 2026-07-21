## Context

| 项 | 现状 |
|---|---|
| 路由 | `AppRoutes.detail(id: cipherUuid)` 已注册，path `/detail/:id` |
| Feature 骨架 | `barrel_lock/lib/features/detail/` — Model 仅持 `id`，ViewModel 仅 `pop()` |
| View | 各平台 `lib/pages/detail_page.dart` — 占位 UI |
| 入口 | `PasswordTabCoordinator.openCipherDetail(cipherId)`，列表项点击触发 |
| 上游能力 | `cipher_add`（六种类型写入）、`FolderManageModel`、`AttachmentManageModel`、`CipherFullDataCodec` / `CipherOverviewCodec` 已就绪 |
| 仓储 | `CipherEntryRepository` 已有 `findById`、`update`、`setFavorite`；无专用软删除 / 改 folder helper |

约束：MVVM-C 分层、Riverpod 3.x、`fast_navigator` 路由 SSOT 在 `barrel_lock/lib/router/`。

## Goals / Non-Goals

**Goals:**

- 用户从密码 Tab 进入详情后可**查看**解密后的完整字段（按类型）
- 支持**快速复制**常用字段到剪贴板
- 支持**编辑**并保存（更新 blob，不新建 UUID）
- 支持**更改文件夹**、**收藏**、**软删除**
- 银行卡/身份证件支持**附件**查看与管理
- iOS/Android 完整竖屏 UI；其他平台最小可读页

**Non-Goals:**

- 跨 vault 移动条目、vault 切换
- TOTP 生成/验证码展示（仅 `hasTotp` 占位提示）
- 条目版本历史、单条导出/分享
- SSH Key 类型（catalog 未启用表单，详情页遇 SSH 显示「暂不支持」）
- 详情页改保险库（`vault_uuid` 不变）

## Decisions

### D1：沿用 `detail` 路由与 Feature 目录，扩展而非新建 `cipher_detail`

**选择**：保留 `AppRoutes.detail(id:)` 与 `features/detail/`，将占位实现替换为完整 MVVM-C。

**理由**：Coordinator 与六平台路由已 wired；改名成本高且无用户可见收益。

**备选**：新建 `cipher_detail` 路由 — 需同步改 Coordinator 与 6 个 `app_router_config`， rejected。

### D2：Model 层新增 `CipherDetailModel`，读写与 `CipherAddModel` 对称

**选择**：`CipherDetailModel` 负责 `loadCipherDetail(cipherUuid)`、`updateCipher(...)`、`softDelete(cipherUuid)`、`updateFolder(cipherUuid, folderUuid)`；解密/加密复用现有 Codec。

**理由**：添加与详情生命周期不同（insert vs update），分离 Model 保持单一职责；可抽取私有 `_buildOverviewAndFullData`  helper 减少重复。

**备选**：扩展 `CipherAddModel` 增加 edit 方法 — 职责混杂，rejected。

### D3：编辑态复用 `cipher_add` 表单 State 与校验，不复制字段定义

**选择**：`DetailViewModel` 进入编辑时，用 `CipherAddFormStateFactory.fromPayload(overview, fullData)`（新增 factory）填充表单；保存调用 `CipherDetailModel.updateCipher`。

**理由**：六种类型字段 SSOT 已在 `form/`；避免详情/添加双份校验逻辑。

**备选**：详情页独立 EditState — 维护成本 double，rejected。

### D4：只读态与编辑态同一页面，AppBar 切换「编辑 / 完成 / 取消」

**选择**：`DetailViewState` 含 `isEditing`；只读态展示带复制按钮的字段行；编辑态嵌入与 `cipher_add` 相同的 form sections。

**理由**：移动端常见模式，减少路由栈深度。

### D5：文件夹更改 — 只读态行内「更改」打开 BottomSheet，编辑态复用 `CipherFolderSelector`

**选择**：只读态快捷改 folder 走 `CipherDetailModel.updateFolder` + `FolderManageModel.watchSummariesByVault`；编辑态 folder 随 save 一并提交。

**理由**：用户期望「未进编辑也能改分组」；与添加页 UI 一致。

### D6：快速复制使用 `Clipboard.setData` + SnackBar，密码默认掩码

**选择**：每字段行右侧 copy icon；密码字段默认 `••••••` + 显隐 toggle；复制后 SnackBar「已复制」。

**理由**：与密码管理器惯例一致；不在剪贴板历史做额外加密（OS 级）。

### D7：软删除写 `deletedAt`，列表自动消失

**选择**：`CipherDetailModel.softDelete` 设置 `deletedAt = now()`、`localModified = true`；密码 Tab 已有 `deletedAt.isNull()` 过滤。

**理由**：与现有列表查询一致；可恢复留待后续 change。

### D8：仓储扩展最小化

**选择**：优先在 Model 内 `findById` → 改字段 → `update`；若重复则加 `CipherEntryRepository.softDelete` / `updateFolderUuid` 薄封装。

**理由**：避免过度抽象；两方法各 5 行。

## Risks / Trade-offs

| 风险 | 缓解 |
|---|---|
| 编辑保存时 overview/full_data 不一致 | 更新时同一事务内重算两个 blob；单测覆盖 round-trip |
| 大附件预览内存 | 沿用 add 页限制 5MB；预览用 `loadDecryptedBytes` 按需加载 |
| 并发编辑（列表与详情） | `watchById` 或 save 前比对 `updatedAt`，冲突提示刷新 |
| 六种类型 UI 工作量大 | 先 websiteLogin 完整交付，其余类型只读+复制+编辑复用 form section |
| 剪贴板敏感数据残留 | 文档说明 OS 剪贴板行为；可选后续「30s 清除」 |

## Migration Plan

1. 实现 `CipherDetailModel` + 单元测试（load/update/delete）
2. 扩展 `DetailViewModel` / Coordinator；替换 iOS/Android View
3. 其他平台最小页（只读标题 + 返回）
4. 无 DB migration；发布后即可用

回滚：保留路由，可 revert 到占位页而不损数据。

## Open Questions

- 删除前是否二次确认 Dialog？→ **是**（Destructive 标准模式）
- 编辑保存成功后留详情还是 pop？→ **留详情并回到只读态**（列表仍会通过 watch 刷新）
- 是否记录 `lastUsedAt` 于打开详情？→ **Out of scope**（`recent` 筛选后续 change）
