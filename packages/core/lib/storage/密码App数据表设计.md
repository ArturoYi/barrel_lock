# 本地无账号个人密码管理器 完整数据表设计

> 适用：Flutter 离线本地密码 App，无服务端、无账号系统，所有表预留账号 / 云同步扩展字段
> 分层规范：加密逻辑与存储完全解耦；列表仅解密概览，详情才解密完整敏感数据

## 总览表清单

1. `vault` 保险库顶层仓库表
2. `folder` 用户自定义文件夹分类表
3. `cipher` 密码条目核心主表
4. `cipher_attachment` 密码附件独立存储表
5. `backup_log` 本地备份操作日志表

> **非 SQLite 配置**：
>
> - 界面主题、语言、排序等 App 全局偏好走 `SPStorage` / `AppPreference`
> - 对称加密密钥由 App 层在启动时通过 `AppCrypto.init()` 注入（ChaCha20-Poly1305），**不入 Drift 数据库**
> - 应用内 PIN / 生物识别解锁走 `AppIdentityAuth`，PIN 哈希存 `SPStorage`

---

## 一、vault 保险库表

### 作用

顶层隔离仓库，支持多库（个人 / 工作 / 家庭），可单独备份、隐藏、整库共享（未来扩展）。

| 字段 | 类型 | 约束 | 说明 |
| ---- | ---- | ---- | ---- |
| vault_uuid | TEXT | PRIMARY KEY | 保险库全局唯一 ID |
| owner_account_id | TEXT | NULL | 预留账号外键，当前全部为空 |
| name | BLOB | NOT NULL | 加密存储保险库名称（`EncryptedPayload`） |
| icon_name | TEXT | NULL | 图标标识（明文无敏感） |
| color_hex | TEXT | NULL | 标签配色（明文） |
| is_personal | BOOLEAN | NOT NULL DEFAULT 1 | 是否个人私有仓库 |
| is_trashed | BOOLEAN | NOT NULL DEFAULT 0 | 是否移入回收站 |
| sync_revision | DATETIME | NOT NULL | 同步时间戳，本地备份复用 |
| local_modified | BOOLEAN | NOT NULL DEFAULT 1 | 标记本地有未同步修改 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 修改时间 |

### 关联关系

一对多：1 个保险库 → 多个 folder、多条 cipher
索引：`idx_vault_owner (owner_account_id)`

---

## 二、folder 文件夹表

### 作用

同一保险库内自定义分类（社交、银行卡、游戏等），单独建表实现一键改名，无需批量更新密码条目。

| 字段 | 类型 | 约束 | 说明 |
| ---- | ---- | ---- | ---- |
| folder_uuid | TEXT | PRIMARY KEY | 文件夹唯一 ID |
| vault_uuid | TEXT | NOT NULL REFERENCES vault(vault_uuid) | 归属保险库外键 |
| owner_account_id | TEXT | NULL | 预留账号字段，当前为空 |
| name | BLOB | NOT NULL | 加密文件夹名称 |
| is_trashed | BOOLEAN | DEFAULT 0 | 是否回收站文件夹 |
| sync_revision | DATETIME | NOT NULL | 同步版本标记 |
| local_modified | BOOLEAN | NOT NULL DEFAULT 1 | 本地变更标记 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 修改时间 |

### 关联关系

多对一：多个文件夹归属同一个 vault；一对多：1 个文件夹绑定多条 cipher
索引：`idx_folder_vault (vault_uuid)`

---

## 三、cipher 密码条目主表（核心业务表）

### 作用

统一存储登录、银行卡、证件、笔记、SSH 密钥；`type` 数字区分条目类型，双层加密隔离列表与完整敏感数据。

> type 枚举：1=网站登录 2=银行卡 3=身份证件 4=安全笔记 5=SSH 密钥 6=App 账户密码

| 字段 | 类型 | 约束 | 说明 |
| ---- | ---- | ---- | ---- |
| cipher_uuid | TEXT | PRIMARY KEY | 条目唯一 ID |
| vault_uuid | TEXT | NOT NULL REFERENCES vault(vault_uuid) | 归属保险库 |
| folder_uuid | TEXT | REFERENCES folder(folder_uuid) | 归属文件夹，可为 NULL |
| owner_account_id | TEXT | NULL | 预留账号字段，当前为空 |
| type | INTEGER | NOT NULL | 条目系统分类，固定数字 |
| overview_blob | BLOB | NOT NULL | 轻量加密：标题、域名（列表 / 搜索专用） |
| full_data_blob | BLOB | NOT NULL | 完整加密：账号、密码、TOTP 种子、卡号、备注 |
| is_favorite | BOOLEAN | NOT NULL DEFAULT 0 | 是否收藏 |
| deleted_at | DATETIME | NULL | 软删除时间，非空代表回收站 |
| sync_revision | DATETIME | NOT NULL | 同步时间戳 |
| local_modified | BOOLEAN | NOT NULL DEFAULT 1 | 本地未同步修改标记 |
| remote_id | TEXT | NULL | 云端同步后端 ID，无同步为空 |
| created_at | DATETIME | NOT NULL | 创建时间 |
| updated_at | DATETIME | NOT NULL | 修改时间 |

### 关联关系

多对一：归属 vault、可选绑定 folder；一对多：1 条 cipher 对应多条附件
索引：
`idx_cipher_vault (vault_uuid)`
`idx_cipher_revision (sync_revision)`
`idx_cipher_deleted (deleted_at)`

---

## 四、cipher_attachment 附件表

### 作用

存储证件照片、银行卡截图、pem 密钥、PDF 证书；独立分表避免主表膨胀、列表滑动卡顿；原始二进制 BLOB 存储，不转 Base64。

| 字段 | 类型 | 约束 | 说明 |
| ---- | ---- | ---- | ---- |
| attach_uuid | TEXT | PRIMARY KEY | 附件唯一 ID |
| cipher_uuid | TEXT | NOT NULL REFERENCES cipher(cipher_uuid) | 所属密码条目外键 |
| owner_account_id | TEXT | NULL | 预留账号字段，当前为空 |
| file_name | BLOB | NOT NULL | 加密文件名 |
| encrypted_file | BLOB | NOT NULL | 文件原始二进制加密数据 |
| file_size | INTEGER | NOT NULL | 文件字节大小（明文展示） |
| sync_revision | DATETIME | NOT NULL | 同步标记 |
| created_at | DATETIME | NOT NULL | 上传时间 |

### 关联关系

多对一：多个附件绑定单条 cipher；删除 cipher 级联删除附件
索引：`idx_attach_cipher (cipher_uuid)`

---

## 五、backup_log 备份日志表

### 作用

记录本地加密备份导出记录，用于备份文件检索与数据恢复。

| 字段 | 类型 | 约束 | 说明 |
| ---- | ---- | ---- | ---- |
| log_id | TEXT | PRIMARY KEY | 日志唯一 UUID |
| backup_time | DATETIME | NOT NULL | 备份导出时间 |
| backup_path | TEXT | NULL | 本地备份文件路径 |
| backup_password_salt | BLOB | NOT NULL | 备份文件加密盐 |
| vault_version | INTEGER | NOT NULL | 备份时加密库版本 |
| is_encrypted | BOOLEAN | NOT NULL DEFAULT 1 | 备份文件是否加密 |
| note | TEXT | NULL | 用户自定义备份备注 |
| created_at | DATETIME | NOT NULL | 日志生成时间 |

### 关联关系

独立日志表，无外键；恢复时读取全量 vault / cipher / attachment 密文重建库。

---

# 整体层级关系

```
vault 保险库
├── folder 文件夹（多对一 vault）
└── cipher 密码条目
    ├─ 归属 vault，可选绑定 folder
    └── cipher_attachment 附件（多对一 cipher）

独立辅助表：backup_log
```

---

# 核心业务规范

1. **分层隔离**：`AppCrypto` 负责 ChaCha20-Poly1305 加解密，Storage 只读写密文 BLOB（`EncryptedPayload` 布局），不处理明文；
2. **密钥管理**：对称密钥由 App 层在启动时注入 `AppCrypto.init()`，不持久化到 SQLite；
3. **解密时机**：列表仅解密 `overview_blob`；点击详情 / 编辑才解密 `full_data_blob`；附件仅预览时解密；
4. **扩展预留**：所有业务表 `owner_account_id` 置空，后续新增账号表无需迁移数据；
5. **文件存储**：附件原始 Uint8List 加密直接存入 BLOB，禁止 Base64；
6. **删除策略**：全业务表使用软删除字段，不物理删除数据，支持回收站恢复；
7. **离线 2FA**：TOTP 种子存放于 `full_data_blob`，本地离线计算验证码，无需服务端；
8. **解锁体验**：指纹 / PIN 解锁配置走 `AppIdentityAuth` + `SPStorage`，自动锁定等偏好走 `AppPreference`；
9. **偏好存储**：主题、字体、语言等非密码业务配置使用 SharedPreferences（`AppPreference`），与 SQLite 密码库分离。

---

# cipher BLOB 明文 JSON 约定

> 以下 JSON 在加密前序列化为 UTF-8，再经 `AppCrypto.encrypt` 写入 BLOB。
> `cipher.type` 与 JSON 内 `type` 字段 MUST 一致。

## overview_blob（列表 / 搜索层，各类型共用结构）

| 字段 | 类型 | 说明 |
| ---- | ---- | ---- |
| title | string | 条目显示名（如「GitHub」「招商银行储蓄卡」） |
| subtitle | string | 列表副标题（用户名、卡号后四位、证件号掩码等） |
| host | string? | 网站域名 / SSH 主机等，非 URL 类可为空 |
| hasTotp | bool? | 是否绑定 TOTP，默认 false |

## full_data_blob（详情 / 编辑层，按 type 区分）

### type = 1 网站登录（websiteLogin）

```json
{
  "type": 1,
  "username": "cyr@example.com",
  "password": "secret",
  "notes": "备注可选",
  "totpSecret": "BASE32SECRET可选"
}
```

### type = 2 银行卡（bankCard）

```json
{
  "type": 2,
  "cardholderName": "张三",
  "cardNumber": "6222****1234",
  "expiryMonth": "12",
  "expiryYear": "28",
  "cvv": "123",
  "pin": "",
  "notes": ""
}
```

### type = 3 身份证件（identityDocument）

```json
{
  "type": 3,
  "documentType": "身份证",
  "fullName": "张三",
  "documentNumber": "110***********1234",
  "issueDate": "2020-01-01",
  "expiryDate": "2030-01-01",
  "notes": ""
}
```

### type = 4 安全笔记（secureNote）

```json
{
  "type": 4,
  "content": "笔记正文",
  "notes": ""
}
```

### type = 5 SSH 密钥（sshKey）

```json
{
  "type": 5,
  "privateKey": "-----BEGIN OPENSSH PRIVATE KEY-----...",
  "publicKey": "ssh-ed25519 AAAA...",
  "passphrase": "",
  "host": "github.com",
  "username": "git",
  "notes": ""
}
```

### type = 6 App 账户密码（appAccount）

```json
{
  "type": 6,
  "username": "13800138000",
  "password": "secret",
  "packageName": "com.tencent.xin",
  "notes": ""
}
```

## overview 字段映射参考

| type | title 来源 | subtitle 来源 | host 来源 |
| ---- | ---------- | ------------- | --------- |
| 1 网站登录 | 用户填「名称」 | 用户名 | 网站 URL 解析 |
| 2 银行卡 | 银行 / 卡别名 | 卡号后四位 | — |
| 3 证件 | 证件类型 + 姓名 | 证件号掩码 | — |
| 4 安全笔记 | 笔记标题 | 内容摘要 | — |
| 5 SSH | 密钥名称 | user@host | host |
| 6 App 账户 | 用户填「名称」 | 账号 | 包名 / Bundle ID（可选） |
