## Why

密码 Tab 已能展示真实条目并跳转 `AppRoutes.detail(id)`，但详情页仍是占位实现（仅显示 ID 与返回按钮），无法查看解密后的完整凭据、复制字段或编辑元数据。添加密码（`cipher_add`）、文件夹/保险库管理、附件写入等能力已就绪，详情页成为「读—改—用」闭环的最后一块，需尽快补齐。

## What Changes

- 将现有 `features/detail/` 占位 Feature 升级为完整 **密码详情页** MVVM-C：按 `cipherUuid` 加载 `CipherEntry`，解密 `overview_blob` / `full_data_blob`，按 `CipherType` 渲染只读字段
- 实现 **快速复制**：用户名、密码、URL、卡号、备注等敏感/常用字段一键写入剪贴板，并给出 SnackBar 反馈
- 实现 **编辑模式**：复用 `cipher_add` 各类型表单状态与校验，保存时更新 `overview_blob`、`full_data_blob`、`updatedAt`（不新建 UUID）
- 实现 **更改文件夹**：同 vault 内选择「未分组」或已有文件夹，更新 `folder_uuid`；可选快捷新建文件夹
- 实现 **收藏切换**：调用既有 `CipherEntryRepository.setFavorite`
- 实现 **附件区**（银行卡/身份证件）：展示已有附件、预览、删除；支持追加新附件（复用 `AttachmentManageModel`）
- 实现 **删除条目**：软删除（`deletedAt`）并返回列表
- iOS / Android 优先交付完整竖屏 UI；其他平台注册路由 + 最小可读页

## Capabilities

### New Capabilities

- `cipher-detail-load`: 按 ID 加载 cipher、解密 overview/full_data、监听 DB 变更、处理不存在/已删除
- `cipher-detail-display`: 六种类型只读展示布局（标题、类型图标、字段分组、掩码/显隐密码）
- `cipher-detail-copy`: 字段级快速复制与剪贴板反馈
- `cipher-detail-edit`: 进入编辑、校验、更新 blob 与 folder/favorite 元数据
- `cipher-detail-folder`: 详情页更改文件夹（含未分组与快捷新建）
- `cipher-detail-attachment`: 详情页附件列表、预览、删除与追加
- `cipher-detail-delete`: 软删除并导航回退

### Modified Capabilities

（无 archive 存量 spec；本 change 以 delta spec 自洽）

## Impact

- **barrel_lock**：重构/扩展 `features/detail/` → 可保留路由名 `detail` 或别名 `cipher_detail`；新增 Model 读写在 `CipherAddModel` 对称层；扩展 `CipherEntryRepository` 若需 `updateFolder` / 软删除 helper
- **packages/core**：可能新增 cipher 软删除 / 更新 folder 仓储方法；无 schema 迁移
- **BarrelLock_ios / BarrelLock_android**：替换 `detail_page.dart` 占位为完整 UI；复用 `cipher_folder_selector`、附件组件模式
- **BarrelLock_macos / web / windows / linux**：路由不变，View 最小实现
- **既有 Feature 复用**：`CipherFullDataCodec`、`CipherOverviewCodec`、`FolderManageModel`、`AttachmentManageModel`、`CipherTypeCatalog`
- **Out of scope（后续 change）**：跨 vault 移动、TOTP 生成/刷新、版本历史、分享/导出单条
