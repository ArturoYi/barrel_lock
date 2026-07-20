## Why

`add-password-flow` 已交付网站登录（`CipherType.websiteLogin`）添加闭环，但添加页仍是单一表单，与 `packages/core/lib/storage` 中五种 cipher 类型的数据模型不对齐。用户无法选择「银行卡 / SSH / 证件 / 笔记」等竞品标配类别，且现有 `CipherAddFormState` / ViewModel 按 website 字段硬编码，每增一种类型都会加剧技术债。

本变更在 **不改动 DB schema** 的前提下，引入 **类型选择器 + 第二种完整表单**，验证多类型 MVVM-C 架构可扩展至全部五类。

## What Changes

- 重构 `cipher_add` 表单态为 **按类型分态**（sealed union），ViewModel 持有 `selectedCipherType`
- 添加页顶部 **类型选择器**（展示全部 5 类；本迭代启用 website + bankCard，其余显示「即将推出」）
- 新增 `BankCardCipherPayload` + codec 分发；`CipherAddModel.saveBankCardCipher`
- iOS 银行卡完整表单：持卡人、卡号、有效期、CVV、PIN（可选）、备注
- 提取网站登录表单为独立 layout widget；添加页 shell 按 type 切换子表单
- 路由 / Page 读取 `?type=` query，与类型选择器双向同步
- **BREAKING（内部）**：`CipherAddFormState` 从单类变为 sealed hierarchy；现有 website 字段迁移至 `WebsiteLoginFormState`

## Capabilities

### New Capabilities

- `cipher-type-catalog`: 五种类型的元数据（label、icon、`CipherType` 值、是否在本迭代启用）
- `cipher-type-selector`: 添加页类型选择 UI 与 ViewModel 切换逻辑（含禁用态、切换时表单重置策略）
- `cipher-add-form-state`: 多类型 sealed form state + 各类型 `canSave` / 校验规则
- `bank-card-cipher-payload`: `BankCardCipherPayload`、overview 映射、codec `fromJson` 分发
- `bank-card-add-form`: iOS 银行卡添加表单 layout 与保存闭环

### Modified Capabilities

- `add-password-page`: 从「仅 website 表单」扩展为「类型选择 + 按 type 渲染表单」；website 行为保持不变
- `cipher-add-routing`: Page 从 query 读取 `type` 并注入 ViewModel；Coordinator 可选传递默认 type
- `cipher-full-data-codec`: `CipherFullDataPayload.fromJson` 支持 `CipherType.bankCard` 反序列化

## Impact

- **barrel_lock**：`features/cipher_add/` 重构（form state、ViewModel、Model）；`crypto/bank_card_cipher_payload.dart`
- **BarrelLock_ios**：`pages/cipher_add/` 拆分 layout（selector、website、bank card）
- **add-password-flow 产物**：无 DB / 路由 path 变更；与已落地的 `saveCipher` / `CipherAddRoute(type)` 衔接
- **Android / 桌面**：本迭代不交付新 UI；类型选择器占位或沿用 website 默认
- **测试**：payload roundtrip、Model 集成测、ViewModel 类型切换与校验单测
