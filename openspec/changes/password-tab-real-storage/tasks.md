## 1. 启动与依赖注入

- [x] 1.1 在 `runBarrelLockApp` 中于 `BarrelLockCrypto.init()` 之后调用 `AppStorage.init(appNamespace: 'barrel_lock', env: storageEnv)`
- [x] 1.2 新建 `barrel_lock/lib/storage/storage_providers.dart`，暴露 `storageRepositoriesProvider`
- [x] 1.3 在 `barrel_lock.dart` export 新 provider；确认 workspace `dart pub get` 通过

## 2. Overview 编解码（barrel_lock）

- [x] 2.1 定义 `CipherOverviewData` 域模型（title、subtitle、host?、hasTotp?）
- [x] 2.2 实现 `CipherOverviewCodec`（JSON UTF-8 → `AppCrypto.encrypt` / decrypt）
- [x] 2.3 实现 `EncryptedNameCodec`（或复用通用 `EncryptedJsonCodec`）供 vault/folder 名称
- [x] 2.4 添加 codec 单元测试（roundtrip、篡改密文、缺字段默认值）

## 3. 仓储查询扩展（packages/core）

- [x] 3.1 `VaultRepository.watchActive()` — 过滤 `is_trashed = false`
- [x] 3.2 `FolderRepository.watchByVault(vaultUuid)` — 过滤 trashed
- [x] 3.3 `CipherEntryRepository.watchByVault(vaultUuid)` — 过滤 `deleted_at IS NULL`
- [x] 3.4 `CipherEntryRepository.setFavorite(id, value)` — 更新 `is_favorite` + `updated_at`
- [x] 3.5 补充 repository 测试（内存库 insert + watch 断言）

## 4. PasswordTabModel 真实数据源

- [x] 4.1 构造函数注入 `StorageRepositories`；`passwordTabModelProvider` 从 `storageRepositoriesProvider` 读取
- [x] 4.2 删除 `_seedCiphers()`、硬编码 `vaults` 常量、静态 `folderNames` map
- [x] 4.3 实现 `watchVaultSummaries()` / `watchFolderGroups(...)` 或等价 async API，内部 decrypt overview + folder/vault 名称
- [x] 4.4 `toggleFavorite` 改为调用 `cipherEntries.setFavorite` 而非内存 mutate
- [x] 4.5 `buildFolderGroups` 保留现有 filter/search/sort 逻辑，输入改为解密后的 `CipherOverviewItem` 列表

## 5. ViewModel 与 View 适配

- [x] 5.1 将 `PasswordTabViewModel` 升级为 `AsyncNotifier<PasswordTabViewState>`（或 Stream 订阅 + invalidate）
- [x] 5.2 合并 vault/cipher/folder watch，映射为现有 `PasswordTabViewState` 形状
- [x] 5.3 更新 iOS/Android `PasswordTabPage`：处理 loading / error / data 三态
- [x] 5.4 确认空库、有数据、筛选、搜索、折叠动画行为与 mock 时代一致

## 6. 测试与 CI

- [x] 6.1 新建 `password_tab_model_test.dart`：内存库 seed vault/folder/cipher（用 codec 写 overview），断言分组与筛选
- [x] 6.2 确认 `melos run ci`（format / analyze / test）通过
- [x] 6.3 手动验证：真机/模拟器空库启动不 crash；插入数据后列表刷新

## 7. 清理与文档

- [x] 7.1 移除 `PasswordTabModel` 文件头「内存 mock」注释，更新为 storage 数据源说明
- [x] 7.2 在 design 中 Open Questions 选定「无 vault 时」产品行为并实现最小路径（empty 或引导）
