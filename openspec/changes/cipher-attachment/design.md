## Context

| 模块 | 现状 |
|------|------|
| `cipher_attachment` 表 | 已定义：`file_name` / `encrypted_file` BLOB、`file_size`、FK → cipher |
| `CipherAttachmentRepository` | 仅 generic CRUD，无 `watchByCipher` |
| `CipherAddModel` | 写 cipher 文本字段；无附件 |
| 身份证件 UI | 纯文本表单（`IdentityDocumentFormSection`） |
| `DetailPage` | 占位页，无详情/预览 |
| 数据表设计规范 | 规则 5：附件 **Uint8List 加密直存 BLOB**，禁止 Base64；规则 3：列表不解密附件，预览时才解密 |

约束：MVVM-C、`StorageRepositories` 注入、`AppCrypto` ChaCha20-Poly1305、Riverpod 3。

## Goals / Non-Goals

**Goals:**

- 用户在添加身份证件时可从相册/相机添加 1～N 张图片，保存后与 cipher 关联
- 附件文件名与二进制均加密入库；列表/添加页仅展示元数据（文件名、大小），不预加载 BLOB
- 提供可复用的 `AttachmentManageModel` 与 `CipherAddAttachmentNotifier`，后续详情页/SSH `.pem` 可复用

**Non-Goals:**

- 详情页查看已保存附件（后续 change，依赖 Detail 实现）
- 编辑已有 cipher 的附件增删
- 文件系统路径存储方案、云同步、备份 UI
- PDF / 视频 / 单文件 > 5MB（首版限制见 D2）

## Decisions

### D1: 存储方案 — 加密 BLOB 入库（推荐，采用）

**选择**：读取用户选取文件的 `Uint8List` → `AppCrypto.encrypt` → 写入 `cipher_attachment.encrypted_file`；文件名经 `EncryptedNameCodec`（或同等 JSON 加密）写入 `file_name`。

**理由**：

1. **与现有 schema 一致**：`密码App数据表设计.md` 已规定 BLOB 直存，禁止 Base64 中转
2. **备份/恢复简单**：`backup_log` 设计为读取全量 vault / cipher / attachment 密文重建，单库单文件无孤儿路径
3. **跨平台一致**：避免 iOS 沙盒路径、Android scoped storage、桌面多路径同步
4. **安全边界清晰**：Storage 层只读写密文，与 cipher `full_data_blob` 同一密钥体系
5. **密码管理器常见模式**：本地加密 SQLite BLOB，适合证件照、截图、小 pem（KB～低 MB）

**备选：文件系统 + DB 存路径**

| 维度 | BLOB 入库 | 文件系统 + 路径 |
|------|-----------|-----------------|
| 备份 | 随 DB 一体 | 需额外打包文件目录 |
| 删除一致性 | FK 级联 | 易遗留孤儿文件 |
| 大文件 (>10MB) | DB 膨胀 | 更合适 |
| 实现复杂度 | 低（已有表） | 高（路径、权限、迁移） |

**结论**：首版采用 BLOB；若未来支持视频/大 PDF，可另开 change 做「元数据入库 + 加密文件落盘」混合方案，而非首版引入双存储。

### D2: 首版限制

- 单文件上限 **5MB**（保存前校验）
- 单条 cipher 待保存附件上限 **5 个**
- MIME：首版仅 **image/jpeg、image/png、image/webp**（身份证件场景）
- 可选：保存前对 JPEG/PNG 做最大边长压缩（如 2048px）以控体积 — 实现阶段评估，非阻塞

### D3: 独立 `AttachmentManageModel`

**选择**：`features/attachment_manage/`，不塞进 `CipherAddModel`。

**理由**：与 `FolderManageModel` 对称；详情/编辑/导入 SSH 密钥均可复用；cipher 保存与附件写入分步但同一事务语义由 ViewModel 编排。

### D4: 添加页附件状态 — `CipherAddAttachmentNotifier`

**选择**：与 `CipherAddFolderNotifier` 对称，内存态 `List<PendingAttachment>`（bytes + fileName + mimeType），**保存成功后再写 DB**。

**流程**：

```
选图 → Pending 列表（内存）→ 用户点保存
  → CipherAddModel 插入 cipher → 得到 cipherUuid
  → AttachmentManageModel.insertAll(cipherUuid, pending)
  → 成功则 finishAddSuccess；失败则 cipher 已存在需定义策略（见风险）
```

**UI（身份证件表单下方）**：

1. 区块标题「附件（可选）」+ 说明「可添加身份证正反面等照片」
2. 横向缩略图列表 + 「添加」按钮
3. 点击缩略图：全屏预览（解密内存 bytes，无需读库）
4. 缩略图角标删除
5. 「添加」→ BottomSheet：「拍照」「从相册选择」（`image_picker`）

首版 **仅** 在 `IdentityDocumentFormSection` 下方挂载 `CipherAttachmentSection`；其它 cipher 类型不显示（组件保留扩展点）。

### D5: Repository 查询分层

**选择**：

- `watchMetadataByCipher(cipherUuid)`：SELECT 除 `encrypted_file` 外字段，或 SELECT 全行但 Model 映射为 `AttachmentMetadata`（id, fileName, fileSize, createdAt）
- `loadDecryptedFile(attachUuid)`：按需读取并解密 BLOB（供详情/预览 change 复用）

列表与添加页 **禁止** `watchAll()` 拉全表 BLOB。

### D6: 加密实现

- `file_name`：复用 `EncryptedNameCodec.encrypt(originalFileName)`
- `encrypted_file`：`AppCrypto.encrypt(fileBytes)` → `Uint8List.fromList(payload.bytes)` 存 BLOB
- 解密预览：`AppCrypto.decrypt(EncryptedPayload(blob))`

与 `full_data_blob` 相同算法，不引入独立文件密钥。

## Risks / Trade-offs

- **[Risk] 保存 cipher 成功但附件 insert 失败** → ViewModel 在同一 `try` 中顺序执行；附件失败时 surfacing 错误并保留添加页（cipher 已落库可能重复标题）。首版可接受；后续 edit 页可补附件。Mitigation：测试覆盖；可选 future 事务包装。
- **[Risk] 大图片撑大 DB** → D2 大小/数量限制 + 可选压缩
- **[Risk] `image_picker` 平台权限** → iOS Info.plist / Android manifest 声明；CI 不测真机选图
- **[Trade-off] 详情页不能看已存附件** → 首版 Non-Goal；用户保存后暂无法从详情回看，需在 tasks 验收中说明

## Migration Plan

1. core：`CipherAttachmentRepository` 扩展查询
2. barrel_lock：`AttachmentManageModel` + tests
3. `CipherAddAttachmentNotifier` + save 编排
4. iOS/Android UI + `image_picker`
5. `melos run ci`

无 schema migration（表已存在）。

## Open Questions

1. ~~BLOB vs 文件路径~~ → **BLOB**（D1）
2. 保存失败时是否回滚 cipher？→ 首版不回滚，文档化；若产品要求强一致再开事务 change
3. 是否首版支持 PDF？→ 否，仅 image/*；PDF 随详情/SSH change 扩展 MIME 白名单
