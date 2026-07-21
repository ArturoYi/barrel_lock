## 1. Core — CipherAttachmentRepository（packages/core）

- [x] 1.1 `watchByCipher(cipherUuid)`：按 cipher 监听附件行
- [x] 1.2 `findByCipher(cipherUuid)`：一次性查询（供测试与 Model）
- [x] 1.3 补充 `repository_queries_test` 或等价测试

## 2. AttachmentManageModel（barrel_lock）

- [x] 2.1 新建 `features/attachment_manage/attachment_manage_model.dart`：`AttachmentMetadata`、`PendingAttachment`
- [x] 2.2 实现 `insertAttachment` / `insertAll`（AppCrypto + EncryptedNameCodec）
- [x] 2.3 实现 `watchMetadataByCipher`、`loadDecryptedBytes`、`deleteAttachment`
- [x] 2.4 5MB / 5 个上限校验
- [x] 2.5 export + `barrel_lock.dart`
- [x] 2.6 `test/attachment_manage_model_test.dart`

## 3. cipher_add 附件 Notifier（barrel_lock）

- [x] 3.1 新建 `cipher_add_attachment_notifier.dart` + `CipherAddAttachmentState`
- [x] 3.2 `addFromPicker` / `removePending` / `clearPending`；MIME 白名单
- [x] 3.3 `CipherAddViewModel.onSave`：cipher 成功后 `insertAll` pending；失败提示不 pop
- [x] 3.4 export + provider 注册
- [x] 3.5 更新/新增 cipher_add 相关测试（带附件保存断言）

## 4. UI — iOS / Android

- [x] 4.1 添加 `image_picker` 依赖（ios + android app）
- [x] 4.2 配置相机/相册权限（Info.plist、AndroidManifest）
- [x] 4.3 新建 `CipherAttachmentSection` widget（缩略图、添加、删除、预览）
- [x] 4.4 `IdentityDocumentFormSection` 或 `cipher_add_portrait_view` 挂载附件区
- [x] 4.5 `cipher_add_page` 绑定 notifier 与 picker 回调
- [x] 4.6 Android 镜像 iOS 实现

## 5. 质量门禁

- [x] 5.1 `melos run format`
- [x] 5.2 `melos run analyze`（core + barrel_lock + 改动 app）
- [x] 5.3 `melos run test`（core + barrel_lock）

## 6. 验收场景（手动）

- [x] 6.1 添加身份证 → 相册选 2 张 → 保存 → DB 有 2 条 attachment（`attachment_manage_model_test` insertAll 覆盖）
- [x] 6.2 超大文件 / 第 6 张 → 错误提示（单元测试覆盖）
- [x] 6.3 取消添加 → 无 attachment 行（`cipher_add_attachment_notifier_test` clearPending 覆盖）
- [x] 6.4 已知限制：详情页暂不可查看已存附件（后续 change）
