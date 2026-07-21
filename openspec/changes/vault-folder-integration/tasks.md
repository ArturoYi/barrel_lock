## 1. VaultManageModel（barrel_lock）

- [x] 1.1 新建 `features/vault_manage/vault_manage_model.dart`：`createVault(name, iconName?, colorHex?)`
- [x] 1.2 新建 `vault_manage.dart` export + `barrel_lock.dart` export
- [x] 1.3 `CipherAddModel.createDefaultVault()` 委托 `VaultManageModel.createVault(name: '我的保险库')`
- [x] 1.4 新建 `test/vault_manage_model_test.dart`：createVault 写入与名称解密

## 2. FolderManageModel（barrel_lock）

- [x] 2.1 新建 `features/folder_manage/folder_manage_model.dart`：`createFolder`、`watchSummariesByVault`
- [x] 2.2 定义 `FolderSummary`（id + name）供 UI 使用
- [x] 2.3 新建 `folder_manage.dart` export + `barrel_lock.dart` export
- [x] 2.4 新建 `test/folder_manage_model_test.dart`：create + watch

## 3. cipher_add 文件夹接入

- [x] 3.1 新增 `cipherAddFolderIdProvider` → `cipherAddFolderNotifierProvider` + `CipherAddFolderState`
- [x] 3.2 各 `saveXxxCipher` 与 `saveCipher` 透传 `folderUuid`
- [x] 3.3 `CipherAddViewModel`：加载 folder 列表、选择/新建、`onSave` 传 folderUuid
- [x] 3.4 文件夹选择态独立 Notifier（不污染 form state）
- [x] 3.5 更新 `cipher_add_model_test.dart`：带 folderUuid 保存断言

## 4. Password Tab 建库 UI（iOS / Android）

- [x] 4.1 `PasswordTabViewModel.createVault(name)` + 选中新建 vault
- [x] 4.2 `VaultSwitcherButton` 增加「新建保险库」→ BottomSheet
- [x] 4.3 空库态 CTA「创建保险库」（iOS + Android password tab view）
- [x] 4.4 更新 `password_tab_model_test.dart`（如有需要）— 现有测试仍通过

## 5. cipher_add 文件夹 UI（iOS / Android）

- [x] 5.1 iOS `cipher_add_portrait_view`：文件夹 Dropdown + 新建 dialog
- [x] 5.2 Android 镜像 5.1
- [x] 5.3 ViewModel 绑定 vault 变化时刷新 folder 列表

## 6. 质量门禁

- [x] 6.1 `melos run format`
- [x] 6.2 `melos run analyze`（barrel_lock）
- [x] 6.3 `melos run test`（barrel_lock 100 tests）

## 7. 验收场景

- [ ] 7.1 空库 → Tab 创建保险库 → 切换器可见（需手动 E2E）
- [ ] 7.2 添加密码选文件夹 → 保存 → Tab 分组正确（需手动 E2E）
- [ ] 7.3 添加页新建文件夹 → 保存 → 分组显示新文件夹名（需手动 E2E）
