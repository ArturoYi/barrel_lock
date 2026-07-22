## Context

当前仓库 `flutter_bazaar`（remote: `bazaar_flutter`）采用 Melos 8 + Dart pub workspaces，实际只包含 BarrelLock 一款 App。目录为 `apps/BarrelLock/<子包>/`，存在三层嵌套（仓库 → 产品 → 平台），与单 App 定位不符。Dart 包名（`barrel_lock_android` 等）和 MVVM-C 分层已经合理，本次只做**物理路径扁平化 + 仓库重命名 + 文档对齐**，不改业务逻辑与 Native ID。

## Goals / Non-Goals

**Goals:**

- 仓库统一命名为 `barrel_lock`，App 显示名保持 **BarrelLock**
- 移除 `apps/BarrelLock/` 中间层，所有 App 相关子包直接位于 `apps/` 下
- 平台目录使用小写短名（`android`、`ios` 等），与 pubspec 包名 `barrel_lock_*` 对应
- 更新 workspace、path 依赖、Melos scope、CI、Cursor rules/skills、README
- 迁移后 `melos run ci` 通过

**Non-Goals:**

- 不改已发布 Native ID（`com.hulk.bazaarAndroid`、`com.hulk.bazaarIos`）
- 不合并/拆分 Dart 包（`barrel_lock` 与 `barrel_lock_ui` 保持独立）
- 不将 `core/lib/storage` 从 `packages/core` 迁出（后续独立 change）
- 不合并 android/ios 重复 View 代码
- 不改 `fast_lifecycle` 的 `com.flutterbazaar` 命名空间

## Decisions

### 1. 目标目录布局

```text
barrel_lock/                          # 仓库根（重命名自 flutter_bazaar）
├── pubspec.yaml                        # name: barrel_lock_workspace
├── apps/
│   ├── android/                        # pubspec name: barrel_lock_android
│   ├── ios/                            # barrel_lock_ios
│   ├── macos/                          # barrel_lock_macos
│   ├── windows/                        # barrel_lock_windows
│   ├── linux/                          # barrel_lock_linux
│   ├── web/                            # barrel_lock_web
│   ├── barrel_lock/                    # 共享 M/VM/C、路由
│   └── barrel_lock_ui/                 # runBarrelLockApp()、根 Widget、assets
├── packages/
│   ├── core/
│   ├── app_fonts/
│   └── fast_*/
└── openspec/
```

**理由：** 用户明确要求子项目直接放 `apps/`；平台用小写目录名避免 `BarrelLock_android` 与 `barrel_lock_android` 双轨命名。

**备选：** 业务包上提到 `packages/barrel_lock` —— 用户要求放 `apps/`，故不采用。

### 2. 根 pubspec 命名

- `name: barrel_lock_workspace`（Melos 根包，非 pub.dev 发布名）
- `description` 改为「BarrelLock monorepo managed by Melos」

**理由：** 根包名不能与子包 `barrel_lock` 冲突；`_workspace` 后缀是 Dart workspace 常见做法。

### 3. path 依赖深度调整

扁平化后，`apps/barrel_lock` 到 `packages/` 的相对路径从 `../../../packages/` 变为 `../../packages/`。所有显式 `path:` 依赖必须同步更新。

workspace 依赖（无 path 的 `barrel_lock:`、`core:` 等）由 pub workspaces 解析，**包名不变则 import 语句无需改动**。

### 4. Melos scope 保持不变

Melos scope 基于 pubspec `name`（如 `barrel_lock_android`），与目录名无关。`melos run run:android` 等脚本**无需改 scope 字符串**，除非 scope 当前绑定了错误名称（需验证）。

### 5. 产品 assets 归位

`apps/BarrelLock/assets/`（如 `app_icon.png`）合并到 `apps/barrel_lock_ui/assets/`，删除独立 `apps/assets` 目录，避免 `apps/` 下出现非 Dart 包文件夹。

### 6. Git 与本地目录

- 推荐：`git mv` 移动子目录，保留历史
- 仓库根目录重命名（`flutter_bazaar` → `barrel_lock`）由开发者在本地执行；文档说明 GitHub remote rename 步骤
- 不在本 change 内 force push 或改 git config

### 7. 文档用语统一

| 旧表述 | 新表述 |
|--------|--------|
| Flutter Bazaar | BarrelLock |
| 跨产品 / 多产品 monorepo | 单 App monorepo |
| `apps/BarrelLock/...` | `apps/...` |
| `apps/<App>/` | `apps/`（产品层已移除） |

## Risks / Trade-offs

| 风险 | 缓解 |
|------|------|
| 遗漏 path 依赖导致 `pub get` 失败 | 迁移后用 `dart pub get` + `melos run analyze` 全量验证 |
| IDE / Cursor 缓存旧路径 | 更新 `.cursor/rules` 与 skills；提示开发者重开 workspace |
| 既有 OpenSpec change 文档路径过时 | 可选批量替换；不阻塞 CI |
| 开发者本地仍 clone 旧 repo 名 | README 增加「从 bazaar_flutter 迁移」说明 |
| Android/iOS 原生工程内硬编码旧相对路径 | 检查 `build.gradle.kts`、`project.pbxproj` 是否有 Flutter 子路径引用 |

## Migration Plan

1. **准备**：在当前分支创建 change，确保 working tree clean
2. **移动目录**（`git mv`）：
   - `apps/BarrelLock/BarrelLock_android` → `apps/android`
   - 其余平台同理
   - `apps/BarrelLock/barrel_lock` → `apps/barrel_lock`
   - `apps/BarrelLock/barrel_lock_ui` → `apps/barrel_lock_ui`
   - 删除空的 `apps/BarrelLock/`
3. **更新配置**：根 `pubspec.yaml` workspace 列表、各包 path 依赖
4. **更新引用**：README、CI、Cursor rules/skills、core README
5. **验证**：`dart pub get` → `melos run ci`
6. **仓库重命名**（可选同步）：GitHub rename + 本地目录 rename + `git remote set-url`

**Rollback：** revert 迁移 commit；不涉及数据迁移或 schema 变更。

## Open Questions

- GitHub remote 是否同步 rename 为 `barrel_lock`？（建议 yes，可在 tasks 中作为 optional step）
- `packages/*/description` 中 "Flutter Bazaar" 是否本 change 一并替换？（建议 yes，低成本）
