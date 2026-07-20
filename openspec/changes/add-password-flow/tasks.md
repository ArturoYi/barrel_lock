## 1. 依赖与域模型

- [x] 1.1 在 `packages/core/pubspec.yaml` 添加 `uuid: ^4.5.0`；新建 `lib/ids/app_ids.dart`（`AppIds.newUuid()`）；在 `core.dart` export；根目录 `fvm dart pub get`
- [x] 1.2 新建 `barrel_lock/lib/crypto/website_login_cipher_payload.dart`：定义 `WebsiteLoginCipherPayload`（username、password、notes?）— **第三方网站凭据**，非 App 账号
- [x] 1.3 新建 `barrel_lock/lib/crypto/cipher_full_data_codec.dart`：`encryptWebsiteLogin(WebsiteLoginCipherPayload)` / `decryptWebsiteLogin`（JSON → AppCrypto）
- [x] 1.4 在 `barrel_lock.dart` export 上述 codec / payload
- [x] 1.5 新建 `test/cipher_full_data_codec_test.dart`：roundtrip、篡改密文、缺 notes 默认值

## 2. cipher_add Feature（barrel_lock MVVM-C）

- [x] 2.1 新建 `lib/features/cipher_add/cipher_add_form_state.dart`：title、username、password、website、notes、isSaving、errorMessage、canSave getter
- [x] 2.2 新建 `lib/features/cipher_add/cipher_add_model.dart`：
  - [x] 2.2.1 注入 `StorageRepositories`
  - [x] 2.2.2 `resolveVaultUuid({String? preferredVaultId})` — 有选用选用，无库则建默认 vault
  - [x] 2.2.3 `createDefaultVault()` — 名称「我的保险库」、`EncryptedNameCodec` 加密 name、`AppIds.newUuid()` 生成 vaultUuid
  - [x] 2.2.4 `saveWebsiteLoginCipher(...)` — 组装 overview + full_data blob，`CipherEntriesCompanion.insert` 写入
  - [x] 2.2.5 从 website 字段解析 host（去 protocol / path，供 overview.host）
- [x] 2.3 新建 `lib/features/cipher_add/cipher_add_coordinator.dart`：`pop()`、`finishAddSuccess()`（pop + 可选 toast）
- [x] 2.4 新建 `lib/features/cipher_add/cipher_add_view_model.dart`：
  - [x] 2.4.1 构造函数参数或 provider family 接收 `vaultId?`
  - [x] 2.4.2 字段 onChanged 回调更新 form state
  - [x] 2.4.3 `onSave()` 校验 → 调 Model → 成功走 Coordinator
  - [x] 2.4.4 `onCancel()` → Coordinator.pop
- [x] 2.5 新建 `lib/features/cipher_add/cipher_add.dart` 聚合 export
- [x] 2.6 在 `barrel_lock.dart` export `features/cipher_add/cipher_add.dart`
- [x] 2.7 新建 `test/cipher_add_model_test.dart`：
  - [x] 2.7.1 空库 save → 创建 1 vault + 1 cipher
  - [x] 2.7.2 有库 save → 不新增 vault，cipher 归属正确
  - [x] 2.7.3 overview / full_data 可解密且字段正确

## 3. 路由（fast_navigator SSOT）

- [x] 3.1 新建 `lib/router/domain/cipher_add_route.dart`（path `/cipher/add`，`call({String? vaultId})` 带 query）
- [x] 3.2 在 `app_routes.dart` 添加 `static const cipherAdd = CipherAddRoute()`
- [x] 3.3 在 `router.dart` export 新 route
- [x] 3.4 扩展 `AppRouteBuilders` 增加 `cipherAdd` builder 字段
- [x] 3.5 在 `app_router.dart` `_buildRoutes` 注册 `AppRoutes.cipherAdd` FastRoute
- [x] 3.6 **BarrelLock_ios** `app_router_config.dart` 注册 `cipherAdd` builder
- [x] 3.7 **BarrelLock_android** 同步 3.6
- [x] 3.8 **BarrelLock_macos / web / windows / linux** 注册 builder（可先占位页）

## 4. iOS 添加密码页 UI

- [x] 4.1 新建 `BarrelLock_ios/lib/pages/cipher_add/cipher_add_page.dart`（ConsumerWidget，读 ViewModel）
- [x] 4.2 新建 `layout/cipher_add_portrait_view.dart`：
  - [x] 4.2.1 AppBar：取消 / 标题「添加密码」/ 保存
  - [x] 4.2.2 表单：名称、用户名、密码（obscure + 可见切换）、网站、备注
  - [x] 4.2.3 保存中禁用按钮 + 进度指示
  - [x] 4.2.4 校验错误 inline 或 SnackBar
- [x] 4.3 （可选）`layout/cipher_add_landscape_view.dart` 两列布局或复用 portrait
- [x] 4.4 Page 从 `match.queryParams['vaultId']` 传入 ViewModel provider

## 5. Android 添加密码页 UI

> **暂缓**：当前迭代仅交付 iOS；Android 后续镜像 §4。

- [x] 5.1 镜像 iOS 目录结构：`pages/cipher_add/` + portrait layout
- [x] 5.2 确认 Material 3 输入框样式与密码 Tab 一致
- [x] 5.3 `app_router_config.dart` 指向 Android `CipherAddPage`（含 `cipherType` query）

## 6. 密码 Tab 集成

- [x] 6.1 修改 `PasswordTabCoordinator.openAddPassword({String? vaultId})` → `AppRoutes.cipherAdd(vaultId: vaultId)`
- [x] 6.2 修改 `PasswordTabViewModel.onAddPasswordTapped()` 传入 `state.selectedVaultId`（空串不传）
- [ ] 6.3 手动验证：保存后返回 Tab，列表通过 `watchDataChanges` 出现新卡片（无需额外 refresh）

## 7. 桌面 / Web 占位（最小可用）

> **已完成**：§3.8 已注册占位页（「请使用 iOS/Android 客户端添加密码」+ 返回）。

- [x] 7.1 macOS / web / windows / linux 各建 `CipherAddPage` 占位（Center 文案 + 返回），避免路由 push 崩溃
- [x] 7.2 或：单页提示「请使用 iOS/Android 客户端添加密码」— 按产品取舍

## 8. 测试与 CI

- [ ] 8.1 新建 `test/cipher_add_view_model_test.dart`：校验失败不调用 Model、成功调 Coordinator
- [ ] 8.2 更新/确认 `password_tab_coordinator` 相关测试（若有）不再期望 detail/new
- [ ] 8.3 `melos run format` + `melos run analyze` + `melos run test` 通过
- [ ] 8.4 iOS 模拟器 E2E：空库 → 添加 → 列表出现条目；有库 → 添加 → 归属当前库

## 9. 文档与清理

- [ ] 9.1 删除或注释 `PasswordTabCoordinator` 中对 `detail/new` 的引用说明
- [x] 9.2 在 `cipher_add_model.dart` 文件头注明 overview/full_data 字段映射约定
- [x] 9.3 更新 `packages/core/lib/storage/密码App数据表设计.md` 补充 full_data / overview JSON 示例（5 种 type）

## 实现顺序建议

```
1 → 2 → 3 → 4 → 6 → 8.3   （最小闭环：codec + model + 路由 + iOS UI + Tab 集成）
        ↓
       5、7、8.4            （Android + 桌面占位 + 真机验证）
```

## 验收标准

- [ ] 空数据库冷启动，点「添加密码」→ 填表保存 → 首页出现一条可点击的密码卡片
- [ ] 已有 vault 时新 cipher 写入当前选中 vault，不重复建库
- [ ] 取消 / 返回不写入 DB
- [ ] 必填项为空时 Save 无效且有提示
