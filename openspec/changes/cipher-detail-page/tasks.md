## 1. Core — CipherDetailModel（barrel_lock）

- [x] 1.1 定义 `CipherDetailData` DTO（overview、fullData、vaultUuid、folderUuid、isFavorite、type、updatedAt）
- [x] 1.2 实现 `loadCipherDetail(cipherUuid)`：findById、解密双 blob、处理 missing/deleted
- [x] 1.3 实现 `updateCipher(...)`：重加密 overview/full_data 并 `CipherEntryRepository.update`
- [x] 1.4 实现 `updateFolder(cipherUuid, folderUuid?)` 与 `softDelete(cipherUuid)`
- [x] 1.5 按需扩展 `CipherEntryRepository`（`softDelete` / `updateFolderUuid` 薄封装）
- [x] 1.6 单元测试：load、update round-trip、soft delete、folder 变更

## 2. Form 复用 — 编辑态填充（barrel_lock）

- [x] 2.1 `CipherAddFormStateFactory.fromCipherDetail(overview, fullData)` 六种已启用类型
- [x] 2.2 `CipherDetailModel` 与 factory 映射单测（至少 websiteLogin + bankCard）

## 3. Detail ViewModel / Coordinator（barrel_lock）

- [x] 3.1 定义 `DetailViewState`（loading/error/data、isEditing、revealPassword flags）
- [x] 3.2 `DetailViewModel`：load on build、watch DB 变更、toggle edit/save/cancel
- [x] 3.3 命令：`onCopyField`、`onToggleFavorite`、`onChangeFolder`、`onDelete`（含确认）
- [x] 3.4 `DetailCoordinator`：pop、可选打开附件预览
- [x] 3.5 ViewModel 单测：校验拦截 save、cancel 恢复、copy/favorite/delete 调用 Model

## 4. 只读展示 UI（iOS / Android）

- [x] 4.1 替换 `detail_page.dart` 占位：AppBar（返回、收藏、编辑、更多/删除）
- [x] 4.2 `CipherDetailFieldRow`：label + value + copy + 敏感字段掩码/显隐
- [x] 4.3 类型分区：`WebsiteLoginDetailSection` 等（六种已启用类型）
- [x] 4.4 元数据区：类型图标、文件夹名、未分组文案
- [x] 4.5 复制成功 SnackBar

## 5. 编辑态 UI（iOS / Android）

- [x] 5.1 编辑模式嵌入既有 form sections（复用 cipher_add layout 组件）
- [x] 5.2 AppBar「完成 / 取消」与 saving 态禁用
- [x] 5.3 编辑态挂载 `CipherFolderSelector`（复用或抽 shared widget）

## 6. 文件夹更改（只读快捷入口）

- [x] 6.1 只读态文件夹行「更改」→ BottomSheet 列表（未分组 + folders + 新建）
- [x] 6.2 对接 `FolderManageModel` + `CipherDetailModel.updateFolder`
- [x] 6.3 新建文件夹流程复用 add 页 dialog 模式

## 7. 附件区（详情页）

- [x] 7.1 详情页 `CipherDetailAttachmentSection`（列表、添加、删除确认）
- [x] 7.2 预览：复用 add 页 picker/preview 或轻量 Image 预览
- [x] 7.3 对接 `AttachmentManageModel.watchMetadataByCipher` / insert / delete

## 8. 删除与错误态

- [x] 8.1 删除确认 Dialog → softDelete → `AppRouter.pop`
- [x] 8.2 Loading / NotFound / 解密失败友好页

## 9. 其他平台

- [x] 9.1 macOS / web / windows / linux：最小只读 detail_page（标题 + 类型 + 返回）
- [x] 9.2 确认六平台 `app_router_config` 仍指向 DetailPage（路由已存在则仅换 View）

## 10. 质量门禁

- [x] 10.1 `melos run format`
- [x] 10.2 `melos run analyze`（barrel_lock + ios + android）
- [x] 10.3 相关单元测试通过；手动验证：列表 → 详情 → 复制 → 改文件夹 → 编辑保存 → 删除
