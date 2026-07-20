## Context

### 已有基础（`password-tab-real-storage` 已落地）

| 组件 | 状态 |
|---|---|
| `AppStorage.init` + `StorageRepositories` | 已接入启动链 |
| `CipherOverviewCodec` / `EncryptedNameCodec` | 已实现 |
| `PasswordTabModel.loadVaultData` + `watchDataChanges` | 已实现，保存后列表自动刷新 |
| 添加按钮 | UI 已有，`openAddPassword()` → `detail/new` 占位 |
| `full_data_blob` 格式 | **未定义**，无 codec |
| 创建 vault / cipher 业务 | **未实现** |

### 约束

- MVVM-C：View 不直接访问 DB / Router；Model 读写，ViewModel 校验编排，Coordinator 导航
- 列表只解密 overview；密码明文仅存在于添加页内存，保存时一次性加密写入 `full_data_blob`
- 路由：`fast_navigator`，路由 SSOT 在 `barrel_lock/lib/router/`
- 首版 **UI 范围**：仅交付 `CipherType.websiteLogin` 添加表单；其余类型 schema 已在存储设计文档定义，codec 层预留扩展

## Goals / Non-Goals

**Goals:**

- 从密码 Tab 点「添加」进入表单，填完保存后回到首页并看到新条目
- 无 vault 时自动创建默认库「我的保险库」，再写入 cipher
- 表单校验：标题、用户名、密码非空；网站可选
- 保存失败有 toast / 错误态，不 silent fail

**Non-Goals:**

- 编辑已有密码、详情页展示 full_data
- 银行卡 / 证件 / 笔记 / SSH **添加表单 UI**（schema 与 codec 已对齐，UI 后续迭代）
- 添加页类型选择器、附件上传、TOTP 生成器
- 六端全量精美 UI（桌面端可占位）

## Decisions

### D1：独立路由 `/cipher/add`，不用 detail 扩展

```dart
// domain/cipher_add_route.dart
class CipherAddRoute {
  String get path => '/cipher/add';
  String call({String? vaultId}) => vaultId == null
      ? '/cipher/add'
      : '/cipher/add?vaultId=$vaultId';
}
```

**理由**：添加与详情语义不同；query `vaultId` 传递当前 Tab 选中库，避免表单再选 vault（首版）。

**备选**：`/detail/new` — 与详情耦合，后续编辑难拆分。

### D2：Feature 目录 `features/cipher_add/`

```
features/cipher_add/
├── cipher_add.dart
├── cipher_add_model.dart
├── cipher_add_view_model.dart
├── cipher_add_coordinator.dart
└── cipher_add_form_state.dart   // 纯数据，非 Riverpod
```

View 放 `BarrelLock_ios/lib/pages/cipher_add/`（Android 镜像）。

### D3：`full_data_blob` 多类型 JSON 结构

`cipher` 表通过 `type`（1–5，见 `CipherType`）区分条目类别；`full_data_blob` JSON **必须**含 `"type": <int>`，再按类型携带不同字段。完整 schema 见 `packages/core/lib/storage/密码App数据表设计.md`。

**Codec 分层**：

```dart
sealed class CipherFullDataPayload { int get type; ... }
final class WebsiteLoginCipherPayload extends CipherFullDataPayload { ... }
// 后续：BankCardCipherPayload、SshKeyCipherPayload ...

CipherFullDataCodec.encrypt(CipherFullDataPayload)
CipherFullDataCodec.decrypt(Uint8List) // 按 JSON.type 分发
```

**Model 通用保存**：

```dart
CipherAddModel.saveCipher(type, overview, fullData, ...)
// 网站登录便捷方法：saveWebsiteLoginCipher(...) → 内部调 saveCipher
```

**首版 UI 仅实现 type=1**，路由支持 `?type=` query 预留扩展。

#### D3a：网站登录（`CipherType.websiteLogin = 1`）

域模型：`WebsiteLoginCipherPayload`（避免与 App 解锁凭据混淆）。

```json
{
  "type": 1,
  "username": "cyr@example.com",
  "password": "secret",
  "notes": "备注可选"
}
```

- `username`：该网站上的登录名 / 邮箱（表单「用户名」）
- `password`：该网站上的密码（表单「密码」）

`CipherFullDataCodec` mirror `CipherOverviewCodec` 模式。

**overview 映射**（保存时同步生成）：

| overview 字段 | 来源 |
|---|---|
| title | 表单「名称」 |
| subtitle | 表单「用户名」 |
| host | 表单「网站」解析 host |
| hasTotp | false（首版） |

### D4：Vault 引导 — 首次添加隐式建库

```dart
Future<String> resolveVaultId({String? preferredVaultId}) async {
  if (preferredVaultId != null && await vaultExists) return preferredVaultId;
  final active = await repos.vaults.watchActive().first;
  if (active.isNotEmpty) return active.first.vaultUuid;
  return createDefaultVault(); // 名称「我的保险库」, icon person
}
```

**理由**：对齐 `password-tab-real-storage` design 已决 empty 态策略。

### D5：ID 生成（`packages/core` 统一引入 uuid）

在 `packages/core/pubspec.yaml` 添加 `uuid: ^4.x`，封装并经由 `core.dart` 导出，例如：

```dart
// packages/core/lib/ids/app_ids.dart
abstract final class AppIds {
  static String newUuid() => const Uuid().v4();
}
```

业务层（`barrel_lock`）通过 `import 'package:core/core.dart'` 调用 `AppIds.newUuid()`，**不在 barrel_lock 单独声明 uuid 依赖**。

**备选**：时间戳 + 随机 — 碰撞风险略高。

### D6：Repository 扩展位置

在 `CipherAddModel` 内组合现有 `insert` + codec，或新增：

- `VaultRepository.insertVault(VaultsCompanion)` — 直接用 Drift insert
- `CipherEntryRepository.insertCipher(...)` — 封装 timestamp / default 字段

**不在 core 加业务方法**；core 保持 CRUD，barrel_lock Model 组装 Companion。

### D7：ViewModel 形态

`Notifier<CipherAddViewState>`（同步表单态），`onSave` 为 async：

```dart
Future<void> onSave() async {
  if (!state.canSave) return;
  state = state.copyWith(isSaving: true);
  try {
    await _model.save(...);
    _coordinator.finishAddSuccess();
  } catch (e) {
    state = state.copyWith(isSaving: false, errorMessage: '...');
  }
}
```

### D8：导航与参数传递

```dart
// PasswordTabCoordinator
void openAddPassword({String? vaultId}) {
  AppRouter.push(AppRoutes.cipherAdd(vaultId: vaultId));
}

// PasswordTabViewModel.onAddPasswordTapped
_coordinator.openAddPassword(vaultId: state.selectedVaultIdOrNull);
```

`CipherAddViewModel` 从 route query 读取 `vaultId`（通过 `AppRouter` 当前 match 或 constructor 注入）。

**平台 Page**：

```dart
CipherAddPage({this.vaultId});
// app_router_config:
cipherAdd: (_, match) => CipherAddPage(
  vaultId: match.parameters.queryParams['vaultId'],
),
```

### D9：iOS/Android UI 首版字段

| 字段 | 控件 | 必填 |
|---|---|---|
| 名称 | TextField | ✓ | 条目显示名（如「GitHub」） |
| 用户名 | TextField | ✓ | **网站登录名/邮箱**，非 App 账号 |
| 密码 | TextField obscure + 显示切换 | ✓ | **网站密码**，非 App PIN |
| 网站 | TextField (URL / 域名) | | 可选 |
| 备注 | TextField multiline | | 可选 |

AppBar：取消（pop）、保存（primary action）

## Risks / Trade-offs

| 风险 | 缓解 |
|---|---|
| query `vaultId` 为空且 DB 无库 | `resolveVaultId` 自动建库 |
| 保存时加密失败 | try/catch + toast，保持表单内容 |
| 桌面端未实现完整 UI | 注册路由 + 占位，避免 push 崩溃 |
| overview / full_data 字段漂移 | codec 单测 + model 集成测 |

## Migration Plan

1. codec + model 单测（无 UI）
2. 路由 + 空壳 Page（验证 push/pop）
3. iOS 竖屏表单 + 保存闭环
4. Android 同步
5. 替换 Coordinator 占位
6. 桌面占位 + CI

## Open Questions

1. 保存成功后是否 toast「已添加」？（建议：是，用 `fast_toast`）
2. 是否支持从空 vault 态直接进入添加并建库？（建议：是，与 D4 一致）
