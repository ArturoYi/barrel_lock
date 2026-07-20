## Context

### 已有基础（`add-password-flow` + 存储对齐重构）

| 组件 | 状态 |
|---|---|
| `CipherType` 1–5 | `storage_constants.dart` + 设计文档 schema |
| `CipherFullDataPayload` + `CipherFullDataCodec.encrypt/decrypt` | 已实现，仅 website 有 payload 类 |
| `CipherAddModel.saveCipher(type, overview, fullData)` | 通用保存入口 |
| `CipherAddRoute.call(vaultId, type)` | 支持 `?type=` query |
| iOS 添加页 | 仅 `CipherAddPortraitView` 网站登录表单 |
| `CipherAddFormState` | 单类，website 字段硬编码 |

### 约束

- MVVM-C：View 不直连 DB；类型切换 / 校验在 ViewModel；保存走 Model + Coordinator
- 列表仍只解密 `overview_blob`；敏感字段仅在添加页内存，保存时一次性加密
- 首版平台：**iOS 完整交付**；Android 暂缓（与 `add-password-flow` §5 一致）
- 不引入附件上传、TOTP 编辑器、文件夹选择器

### 竞品参考（类型入口）

| 产品 | 添加入口 | 启示 |
|---|---|---|
| Bitwarden | 类型列表（Login / Card / Identity / Secure note / SSH） | 5 类平铺，图标 + 文案 |
| 1Password | 类别 + 模板 | 先选类别再填表 |
| Apple 密码 | 简化（偏登录） | 我们需显式类型以匹配 DB |

---

## Goals / Non-Goals

**Goals:**

- 添加页顶部可选 cipher 类型；切换类型后展示对应表单
- 本迭代 **完整实现** `CipherType.websiteLogin` + `CipherType.bankCard` 添加与保存
- 表单态、ViewModel、Model 架构可无痛扩展 type 3/4/5
- 未启用类型可见但不可选（或选后提示「即将推出」），避免用户误以为 App 仅支持网站

**Non-Goals:**

- 证件 / 安全笔记 / SSH 的添加表单（仅 catalog 展示）
- SSH 私钥文件导入、银行卡 OCR、Luhn 强校验
- 编辑已有条目、详情页按 type 展示
- Android / 桌面完整多类型 UI
- 密码 Tab「添加」菜单按类型分流（后续可做；本迭代添加页内选择）

---

## Decisions

### D1：第二种类型选 **银行卡（type=2）**，而非 SSH

| 维度 | 银行卡 | SSH |
|---|---|---|
| 字段形态 | 结构化短字段 | 多行 PEM、passphrase、host |
| 与 website 差异 | 高（无 username/password 歧义） | 中（host/username 重叠） |
| 附件依赖 | 无 | 常配合 `.pem` 文件（`cipher_attachment`） |
| 校验复杂度 | 卡号格式、有效期 MM/YY | 密钥格式、可选 passphrase |
| 竞品优先级 | 高（钱包核心） | 中（开发者向） |

**结论**：银行卡更适合验证「类型选择器 + 第二套表单 + overview 映射」模板；SSH 留待 `cipher_attachment` 或专用 import 变更。

**备选**：若产品优先开发者用户，可 swap 为 SSH — 仅需替换 payload + form spec，架构不变。

### D2：表单态用 **sealed class 按类型分态**

```dart
sealed class CipherAddFormState {
  int get cipherType;
  bool get isSaving;
  String? get errorMessage;
  String? get validationMessage;
  bool get canSave;
}

final class WebsiteLoginFormState extends CipherAddFormState { ... }
final class BankCardFormState extends CipherAddFormState { ... }
final class UnsupportedTypeFormState extends CipherAddFormState { ... } // type 3/4/5 占位
```

**理由**：各类型必填项不同（website：名称+用户名+密码；bank card：名称+卡号+持卡人）；单类 `canSave` 会充满类型分支。

**切换策略**：用户改 type → ViewModel **重置为该类型空表单**（不保留跨类型字段，避免脏数据）；同 type 内保留输入。

**备选**：单 state + `Map<String,dynamic>` — 丧失类型安全，不采用。

### D3：类型元数据 `CipherTypeCatalog`（barrel_lock）

```dart
final class CipherTypeDescriptor {
  const CipherTypeDescriptor({
    required this.type,
    required this.label,
    required this.iconName,
    required this.isEnabled,
  });
  final int type;
  final String label;
  final String iconName;
  final bool isEnabled; // 本迭代：1、2 true；3–5 false
}

abstract final class CipherTypeCatalog {
  static const all = [ ... ];
  static CipherTypeDescriptor forType(int type);
}
```

View 只读 catalog 渲染 selector；不在 Widget 内硬编码 type 列表。

### D4：添加页 UI 结构（iOS）

```
CipherAddPage
└── CipherAddShellView (AppBar 共用)
    ├── CipherTypeSelectorRow   // 横向 Chip / Segmented
    └── switch (state)
          WebsiteLoginFormSection
          BankCardFormSection
          UnsupportedTypePlaceholder
```

从现有 `cipher_add_portrait_view.dart` **提取** website 字段区为 `WebsiteLoginFormSection`；AppBar（取消/保存）留在 shell。

**保存按钮**：shell 统一；`onSave` 在 ViewModel 内对 `state` 做 pattern match。

### D5：`BankCardCipherPayload` 与 overview 映射

**full_data**（对齐 `密码App数据表设计.md`）：

```json
{
  "type": 2,
  "cardholderName": "张三",
  "cardNumber": "6222021234567890",
  "expiryMonth": "12",
  "expiryYear": "28",
  "cvv": "123",
  "pin": "",
  "notes": ""
}
```

**overview 映射**：

| 字段 | 来源 |
|---|---|
| title | 表单「名称」（银行/卡别名，如「招商银行储蓄卡」） |
| subtitle | 卡号后四位（不足四位则全文） |
| host | null |
| hasTotp | false |

**必填校验**：title、cardholderName、cardNumber（去空格后非空）；expiryMonth/Year、cvv 首版必填（竞品普遍要求）；pin 可选。

**卡号展示**：列表 subtitle 仅后四位；full_data 存完整卡号（加密）。

### D6：路由与 Page 参数

```dart
// app_router_config (已有 vaultId)
cipherAdd: (_, match) => CipherAddPage(
  vaultId: match.parameters.queryParams['vaultId'],
  cipherType: int.tryParse(match.parameters.queryParams['type'] ?? '') 
      ?? CipherType.websiteLogin,
),

// Page
ProviderScope(
  overrides: [
    cipherAddVaultIdProvider.overrideWithValue(vaultId),
    cipherAddInitialTypeProvider.overrideWithValue(cipherType),
  ],
)
```

类型选择器变更 type 时 **不 push 新路由**（避免栈膨胀）；可选 `replace` 更新 query 供深链 — 首版仅内存态切换。

### D7：ViewModel API

```dart
void onCipherTypeSelected(int type);
// website callbacks → 仅当 state is WebsiteLoginFormState 时更新
// bank card callbacks → 仅当 state is BankCardFormState 时更新

Future<void> onSave() async {
  switch (state) {
    case WebsiteLoginFormState s: await _model.saveWebsiteLoginCipher(...);
    case BankCardFormState s: await _model.saveBankCardCipher(...);
    case UnsupportedTypeFormState(): /* validationMessage */;
  }
}
```

### D8：Model 便捷方法

```dart
Future<String> saveBankCardCipher({
  required String? preferredVaultId,
  required String title,
  required String cardholderName,
  required String cardNumber,
  required String expiryMonth,
  required String expiryYear,
  required String cvv,
  required String pin,
  required String notes,
}) => saveCipher(
  type: CipherType.bankCard,
  overview: CipherOverviewData(
    title: title.trim(),
    subtitle: _lastFourDigits(cardNumber),
  ),
  fullData: BankCardCipherPayload(...),
);
```

---

## Risks / Trade-offs

| 风险 | 缓解 |
|---|---|
| 类型切换丢失已填内容 | 切换前可选确认 dialog — 首版直接重置并文档化 |
| `CipherAddFormState` breaking 影响测试 | 同步更新/新增 ViewModel 单测 |
| 卡号明文存 full_data | 与设计一致（加密 BLOB）；列表 never 解密 full_data |
| 未实现类型用户困惑 | catalog `isEnabled=false` + 禁用 Chip + 文案「即将推出」 |
| website 回归 | 提取 layout 后跑原有 model 测试 + 手动 iOS 冒烟 |

---

## Migration Plan

1. payload + codec + Model（无 UI）+ 单测
2. sealed form state + ViewModel 重构 + 单测
3. iOS shell + type selector + 提取 website section
4. bank card form section + 集成
5. 路由 Page 注入 initial type；Password Tab 仍默认 website
6. CI：`melos run ci`（barrel_lock + BarrelLock_ios）

**回滚**：保留 `saveWebsiteLoginCipher`；若 selector 有问题可 feature-flag 隐藏 selector 仅展示 website。

---

## Open Questions

1. 类型切换是否弹确认？（建议：首版不弹，减少摩擦）
2. 银行卡有效期控件：两个 TextField vs DatePicker？（建议：MM / YY 两个短输入，与竞品一致）
3. 密码 Tab「添加」是否要记住上次选的 type？（建议：否，默认 website；后续 `AppPreference`）
4. 下一类型优先 SSH 还是证件？（建议：secure note 最简单，SSH 需附件）
