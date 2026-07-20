## 1. 类型元数据（barrel_lock）

- [x] 1.1 新建 `lib/features/cipher_add/cipher_type_catalog.dart`：`CipherTypeDescriptor` + `CipherTypeCatalog.all`（6 类 label/icon/isFormEnabled）
- [x] 1.2 catalog 展示全部 6 类；`isFormEnabled` 全部为 true
- [x] 1.3 在 `cipher_add.dart` export catalog

## 2. 全类型 Payload 与 Codec

- [x] 2.1 新建 `bank_card_cipher_payload.dart`（type=2）
- [x] 2.2 新建 `identity_document_cipher_payload.dart`（type=3）
- [x] 2.3 新建 `secure_note_cipher_payload.dart`（type=4）
- [x] 2.4 新建 `ssh_key_cipher_payload.dart`（type=5）
- [x] 2.4b 新建 `app_account_cipher_payload.dart`（type=6 App 账户密码）
- [x] 2.5 更新 `cipher_full_data_payload.dart`：`fromJson` 分发全部 6 类
- [x] 2.6 在 `barrel_lock.dart` export 全部 payload
- [x] 2.7 新建 `test/cipher_all_payloads_test.dart`：6 类 roundtrip

## 3. 多类型 Form State

- [x] 3.1 新建 `form/cipher_add_form_state.dart`（abstract base）
- [x] 3.2 新建 `form/website_login_form_state.dart`
- [x] 3.3 新建 `form/bank_card_form_state.dart`
- [x] 3.4 新建 `form/identity_document_form_state.dart`
- [x] 3.5 新建 `form/secure_note_form_state.dart`
- [x] 3.6 新建 `form/ssh_key_form_state.dart`
- [x] 3.6b 新建 `form/app_account_form_state.dart`（type=6）
- [x] 3.7 新建 `form/cipher_add_form_state_factory.dart`（`emptyForType`）
- [x] 3.8 删除原单类 `cipher_add_form_state.dart`；更新 export

## 4. Model 与 ViewModel

- [x] 4.1 `saveBankCardCipher` / `saveIdentityDocumentCipher` / `saveSecureNoteCipher` / `saveSshKeyCipher` + overview 映射工具
- [x] 4.2 新建 `test/cipher_add_model_all_types_test.dart`（type 2–5 保存验证）
- [x] 4.3 新增 `cipherAddInitialTypeProvider`；Page `ProviderScope` override
- [x] 4.4 重构 `CipherAddViewModel`：`onCipherTypeSelected`、分类型 onChanged、`onSave` 分支
- [x] 4.5 新建 `test/cipher_add_view_model_test.dart`：类型切换、校验、保存路径

## 5. iOS UI — 类型选择器与 Shell

- [x] 5.1 新建 `widgets/cipher_type_selector.dart`（5 类 Chip，未启用 type 不可选）
- [x] 5.2 重构 `cipher_add_portrait_view.dart` 为 shell：AppBar + selector + 表单区
- [x] 5.3 提取 `layout/website_login_form_section.dart`
- [x] 5.4 新建各类型 form section（含 `app_account_form_section.dart`）
- [x] 5.5 敏感字段 obscure + 可见切换（银行卡等）
- [x] 5.6 更新 `cipher_add_page.dart`：`cipherType` query + sealed state

## 6. 路由集成

- [x] 6.1 iOS `app_router_config.dart` 传递 `cipherType` query
- [x] 6.2 `CipherAddPage` 增加 `cipherType` 参数
- [x] 6.3 `PasswordTabCoordinator` 默认 website（不传 type）

## 7. 测试与 CI

- [x] 7.1 `melos run format` + `analyze` + `test`（barrel_lock）
- [x] 7.2 `BarrelLock_ios` analyze 通过
- [x] 7.2b `BarrelLock_android` analyze 通过（§8.1）
- [ ] 7.3 手动 iOS：6 类 selector 展示、各类型保存回归

## 8. 后续迭代（本 change 部分完成）

- [x] 8.1 Android 镜像 UI（6 类 selector + form sections + router `cipherType`）
- [x] 8.2 证件 / 笔记 / SSH / **App 账户** payload + form state + Model 保存 + iOS UI
- [x] 8.3 全部类型完整表单 UI + 启用 catalog `isFormEnabled`
- [ ] 8.4 类型切换确认 dialog、Tab 添加入口记忆上次 type

## 实现顺序建议

```
已完成：1 → 2 → 3 → 4 → 5 → 6 → 7.1–7.2/7.2b → 8.1–8.3
待办：7.3 手动 iOS/Android 冒烟；8.4 类型切换确认
```

## 验收标准

- [x] codec / Model 支持全部 6 类 cipher 写入 DB
- [x] 添加页展示 6 类类型选择 Chip
- [x] website 添加表单无回归
- [x] 银行卡等类型的完整 iOS 表单 UI 可填可存
- [x] `/cipher/add?type=2` 深链打开银行卡表单
