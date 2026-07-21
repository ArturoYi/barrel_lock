## Why

身份证件、银行卡等条目需要保存证件照、截图或 `.pem` 等文件，但 `cipher_attachment` 表与 `CipherAttachmentRepository` 虽已就绪，App 层无任何写入/读取路径；添加页仅有文本字段，用户无法为身份证上传正反面照片。`vault-folder-integration` 已明确附件为独立 change，现补齐该能力以完成「证件信息 + 影像资料」闭环。

## What Changes

- 新增 `AttachmentManageModel`：加密写入 `cipher_attachment`、按 `cipher_uuid` 查询元数据、按需解密预览、删除附件
- 扩展 `CipherAttachmentRepository`：`watchByCipher` / `findByCipher`（列表只读元数据，不加载 `encrypted_file`）
- `cipher_add` 增加附件区（首版以身份证件 type=3 为主，组件可复用到其它类型）
- 保存流程：先 insert cipher，再批量 insert 待上传附件；取消时丢弃内存态
- iOS / Android 添加页接入 `image_picker`（相册 + 相机）
- 单元测试覆盖加密写入、按 cipher 查询、大小/数量校验

## Capabilities

### New Capabilities

- `attachment-manage`: 附件 Model 层——加密 BLOB 持久化、元数据查询、解密预览、删除
- `cipher-add-attachment`: 添加页选择/预览/移除待保存附件，保存后与 cipher 关联

### Modified Capabilities

（无 archive 存量 spec；本 change 以 delta spec 自洽）

## Impact

- **packages/core**：`CipherAttachmentRepository` 增加按 cipher 查询 API；表结构不变
- **barrel_lock**：新 feature `attachment_manage/`；扩展 `cipher_add` ViewModel/Notifier
- **BarrelLock_ios / BarrelLock_android**：身份证件表单附件 UI、`image_picker` 依赖
- **Out of scope**：详情页附件预览（`DetailPage` 仍为占位）、编辑页改附件、备份导出含附件 UI、视频/超大文件、附件软删除回收站
