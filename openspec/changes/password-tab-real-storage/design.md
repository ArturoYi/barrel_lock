## Context

### 当前状态

| 层 | 现状 |
|---|---|
| 启动 | `runBarrelLockApp` 已初始化 `SPStorage`、`BarrelLockCrypto`（`AppCrypto`），**未**调用 `AppStorage.init()` |
| 存储 | `packages/core/lib/storage` 提供 Drift 五表 + `StorageRepositories` 聚合，CRUD 仅有 `findAll` / `watchAll` |
| 密码 Tab | `PasswordTabModel` 硬编码 2 个 vault、7 条 cipher、folder 名称 map；`toggleFavorite` 仅改内存 |
| 加密 | `AppCrypto` 可用；vault/folder `name`、cipher `overview_blob` / `full_data_blob` 均为 `EncryptedPayload` BLOB |
| UI | 竖屏/横屏 View 已就绪，期望 `CipherOverviewItem` / `VaultFolderGroup` 形状不变 |

### 约束（来自存储设计文档与项目规范）

1. Storage 层只读写密文 BLOB，不解密逻辑
2. 列表只解密 `overview_blob`；`full_data_blob` 留给详情页
3. 软删除：`cipher.deleted_at`、`vault/folder.is_trashed`，列表须过滤
4. MVVM-C：View 不直接访问 `StorageRepositories`；Model 负责数据，ViewModel 编排，Coordinator 负责导航
5. Riverpod 3.x：跨 feature 共享 provider 放 `barrel_lock`，通过 `package:core/core.dart` 引入

## Goals / Non-Goals

**Goals:**

- App 冷启动后 `StorageRepositories.defaults()` 可用
- 密码 Tab 展示真实 vault 列表与分组 cipher，无 seed 假数据
- overview 解密失败时单条降级（占位标题），不阻塞整页
- DB 写入（如 toggle favorite）后 UI 自动刷新
- 空库时展示现有 empty 态，不 crash

**Non-Goals:**

- 新建/编辑密码页与 `full_data_blob` 写入（仅保留 Coordinator 占位路由）
- 云同步、`remote_id`、`sync_revision` 业务
- 「最近使用」独立持久化（DB 无 `last_used_at` 字段，本阶段用 `updated_at` 代理或暂隐藏该筛选项）
- TOTP 筛选的精确判定（需 `full_data_blob` 或 overview 扩展字段，可 Phase 2）
- 附件、备份日志 UI

## Decisions

### D1：启动顺序 — `AppStorage.init` 放在 `BarrelLockCrypto.init` 之后

```
WidgetsFlutterBinding → SPStorage.init → BarrelLockCrypto.init → AppStorage.init → ...
```

**理由**：overview / vault 名称解密依赖 `AppCrypto`；Storage 与 SP 共用 `appNamespace: 'barrel_lock'` 与 `env` 隔离策略。

**备选**：在 `BarrelLockCrypto` 之前 init DB — 可行但无收益。

### D2：`StorageRepositories` 通过 Riverpod Provider 注入

```dart
// barrel_lock/lib/storage/storage_providers.dart（新建）
final storageRepositoriesProvider = Provider<StorageRepositories>(
  (_) => StorageRepositories.defaults(),
);
```

`PasswordTabModel` 构造函数接收 `StorageRepositories`，由 `passwordTabModelProvider` 注入。

**理由**：测试可 `overrideWithValue(StorageRepositories(db))` 使用内存库，符合现有 `launchScreenPrepareProvider` 模式。

### D3：overview BLOB 格式 — JSON UTF-8 → `AppCrypto.encrypt`

定义 `CipherOverviewData`（barrel_lock 域模型，非 Drift entity）：

```json
{
  "title": "GitHub",
  "subtitle": "cyr@example.com",
  "host": "github.com",
  "hasTotp": false
}
```

- `CipherOverviewCodec.encrypt(CipherOverviewData)` → `Uint8List`
- `CipherOverviewCodec.decrypt(Uint8List)` → `CipherOverviewData`
- vault/folder 名称：JSON `{"name":"个人库"}` 同样模式，可抽 `EncryptedJsonCodec` 复用

**理由**：与 `EncryptedPayload` + ChaCha20 栈一致；JSON 便于扩展字段而不改表结构。

**备选**：Protobuf — 过重；明文 title 存 SP — 违反设计。

### D4：仓储查询扩展放在 `packages/core` Repository 层

在 `CipherEntryRepository` 增加：

- `watchByVault(String vaultUuid)` — `WHERE vault_uuid = ? AND deleted_at IS NULL`
- `Future<bool> setFavorite(String id, bool value)`

`VaultRepository` / `FolderRepository` 增加：

- `watchActive()` — `WHERE is_trashed = false`

**理由**：设计文档要求复杂查询不污染 `CrudRepository` 接口，但在对应 `XxxRepository` 扩展。

### D5：ViewModel 使用 `AsyncNotifier` + 组合 Stream

```dart
@riverpod
class PasswordTabViewModel extends _$PasswordTabViewModel {
  @override
  Future<PasswordTabViewState> build() async {
    final model = ref.watch(passwordTabModelProvider);
    // 监听 vault + cipher + folder 变化，合并 rebuild state
  }
}
```

或保持 `Notifier`，Model 内部 `watchAll().listen` 并 `ref.invalidateSelf()`。

**推荐 `AsyncNotifier`**：首次加载 decrypt 可能耗时，天然支持 loading；View 已有 empty 态，补 error/loading 即可。

**备选**：纯 `Future` 一次性加载 — DB 变更需手动 refresh，体验差。

### D6：分组逻辑保留在 `PasswordTabModel.buildFolderGroups`

从 DB 读取 → 解密 overview → 映射为 `CipherOverviewItem` → 现有 filter/search/group 算法复用。

未分组：`folder_uuid == null` → `uncategorizedFolderId`（常量保留）。

Folder 名称：join `folder_uuid` → 解密 folder.name；缺失时显示「未分组」/ folder_uuid 前 8 位。

### D7：移除 mock 后的空库体验

- 无 vault：展示引导（可后续「创建保险库」）；本阶段允许 0 vault → empty
- 有 vault 无 cipher：现有 `_EmptyPasswordList`
- 测试 seed：仅在 test 中 insert，不在 prod 代码 path 写 seed

## Risks / Trade-offs

| 风险 | 缓解 |
|---|---|
| `AppStorage.init` 遗漏导致 runtime crash | 在 `runBarrelLockApp` 单点初始化；集成测试断言 `AppStorage.database` 可用 |
| 列表解密 N 条 cipher 阻塞 UI | `AsyncNotifier` loading；后续可加 isolate 批量解密 |
| 旧 DB 中 overview 格式不兼容 | codec 版本字段 `v:1`；解析失败单条 fallback |
| `lastUsedAt` / TOTP 筛选无数据源 | 本阶段：`recent` 用 `updated_at`；`totp` 读 overview.hasTotp，无字段则筛出空集 |
| **BREAKING** ViewModel 变 Async | 各平台 `PasswordTabPage` 用 `.when(loading/error/data)` 包裹 |
| 双端重复 View 文件 | 仅改 barrel_lock Model/VM；iOS/Android View 最小 diff |

## Migration Plan

1. 先合入 `AppStorage.init` + provider（无 UI 变化）
2. 合入 codec + repository 扩展 + 单测
3. 替换 `PasswordTabModel`，删除 seed
4. 升级 ViewModel / View 处理 Async
5. 手动验证：空库、插入 1 vault + 2 cipher、收藏切换、软删除不展示

**回滚**：恢复 `PasswordTabModel` mock 分支或 feature flag `useRealStorage`（可选，非必须）。

## Open Questions

1. ~~首个 vault 由谁创建？~~ **已决（2026-03）**：本变更采用 empty 态——无 vault 时展示「暂无保险库」引导，首个 vault 在「添加密码」流程（后续 change）中隐式创建。
2. overview JSON 纳入 `barrel_lock` 域（`CipherOverviewCodec`），`core` 保持 agnostic。
3. 「最近使用」是否新增 `last_used_at` 列 — 暂用 `cipher.updated_at` 代理，独立 change 再议。
