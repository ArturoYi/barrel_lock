## Why

密码 Tab 已接入真实 SQLite 存储并具备「添加」入口，但 `PasswordTabCoordinator.openAddPassword()` 仍跳转占位页 `detail(id: 'new')`，无法写入 `cipher` / `vault` 表。用户在没有保险库或密码条目时无法完成第一条数据的创建，添加密码成为当前产品闭环的关键缺口。

## What Changes

- 新增「添加密码」独立路由与 MVVM-C Feature（`cipher_add`），替代 detail 占位跳转
- 新增 `CipherFullDataCodec`，与现有 `CipherOverviewCodec` 对称，分别写入 `full_data_blob` / `overview_blob`
- 扩展仓储：创建 vault（首条数据时自动建默认库）、插入 cipher
- 实现 `CipherType.websiteLogin` 添加表单：名称、**网站用户名**、**网站密码**、网站 URL、备注（均为 vault 内第三方凭据，非 App 账号）
- 保存成功后 `AppRouter.pop`，密码 Tab 通过既有 `watchDataChanges` 自动刷新列表
- iOS / Android 优先交付完整竖屏表单 UI；其他平台可先提供最小占位页 + 路由注册

## Capabilities

### New Capabilities

- `cipher-full-data-codec`：`full_data_blob` JSON 编解码与加密封装
- `cipher-add-routing`：`AppRoutes.cipherAdd`、平台 `app_router_config`、Coordinator 跳转
- `add-password-page`：添加密码页 MVVM-C（表单校验、vault 引导、持久化、导航）
- `vault-bootstrap-on-add`：无 vault 时于首次添加自动创建默认保险库

### Modified Capabilities

- `password-tab-add-navigation`（变更 spec，基于 `password-tab-real-storage` 行为）：「添加」按钮 MUST 打开添加密码页而非 detail 占位

### Modified Capabilities (from prior change artifacts — delta only)

（无正式 archive 的 `openspec/specs/` 存量；navigation 变更写入本 change 的 `password-tab-add-navigation` spec）

## Impact

- **packages/core**：新增 `uuid` 依赖、`AppIds.newUuid()` 并经 `core.dart` 导出；仓储 CRUD 不变
- **barrel_lock**：新 feature `features/cipher_add/`、codec（`WebsiteLoginCipherPayload`）、repository 调用、路由 SSOT
- **BarrelLock_ios / BarrelLock_android**：新页面与 layout、`app_router_config` 补 builder
- **BarrelLock_macos / web / windows / linux**：路由注册 + 占位页（与现有 password tab 占位策略一致）
- **password-tab-real-storage**：Coordinator 占位逻辑被替换，无 ViewModel 形状变更
