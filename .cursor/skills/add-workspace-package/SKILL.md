---
name: add-workspace-package
description: Creates a new Dart/Flutter package in the Melos 8 pub workspace monorepo. Use when adding a package, shared module, feature library, or registering a new workspace member.
---

# 添加 Workspace 包

## 约束

- Melos 8 + Dart pub workspaces
- 根目录 `pubspec.yaml` 的 `workspace:` **必须手动登记**（不自动 glob 扫描）
- 子包 `pubspec.yaml` 必须含 `resolution: workspace`
- 依赖安装：根目录 `dart pub get`（不用 `melos bootstrap`，会触发 startup lock 冲突）

## 工作流

```
Task Progress:
- [ ] Step 1: 确定包类型与路径
- [ ] Step 2: 创建目录与 pubspec.yaml
- [ ] Step 3: 根 workspace 登记
- [ ] Step 4: dart pub get
- [ ] Step 5: 创建 lib 入口与目录结构
- [ ] Step 6: 在消费方添加依赖
- [ ] Step 7: melos run format + analyze 验证
```

### Step 1: 确定路径

| 类型 | 路径 | 示例 |
|------|------|------|
| 共享库 | `packages/<name>/` | `packages/core`, `packages/fast_navigator` |
| App 业务共享层 | `apps/<name>/` | `apps/barrel_lock`, `apps/barrel_lock_ui` |
| 平台 App | `apps/<platform>/` | `apps/android`（含 `lib/pages/`） |

### Step 2: pubspec.yaml 模板

**纯 Dart / Flutter 库**（`packages/`）：

```yaml
name: my_feature
description: Shared feature module for BarrelLock.
version: 0.0.1
publish_to: none
resolution: workspace

environment:
  sdk: ^3.12.2
  flutter: ">=3.27.0"

dependencies:
  flutter:
    sdk: flutter
  core:
    path: ../core

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

flutter:
```

**平台 App** 额外需要各平台目录（`flutter create` 生成），并在 `pubspec.yaml` 中依赖本地 packages。

### Step 3: 根 workspace 登记

编辑根 `pubspec.yaml`，在 `workspace:` 列表追加：

```yaml
workspace:
  - packages/my_feature
  # ...existing entries
```

### Step 4: 安装依赖

```bash
cd /path/to/barrel_lock
dart pub get
```

### Step 5: 包结构

```
packages/my_feature/
├── lib/
│   ├── my_feature.dart      # 入口，统一 export
│   └── src/                 # 内部实现
├── test/
│   └── my_feature_test.dart
├── analysis_options.yaml    # include: package:flutter_lints/flutter.yaml
└── pubspec.yaml
```

入口文件：

```dart
library;

export 'src/...';
```

### Step 6: 消费方依赖

在 app 或 package 的 `pubspec.yaml`：

```yaml
dependencies:
  my_feature:
    path: ../../packages/my_feature
```

路径按相对位置调整。workspace 内也可省略 version，由 workspace 解析。

### Step 7: 验证

```bash
melos list                  # 确认新包可见
melos run format            # 必须！否则 CI format:check 失败
melos run analyze
melos run test              # 若有 test 目录
# 或一键：melos run ci
```

首次 clone 后可安装 pre-commit 钩子，提交前自动格式化：

```bash
./scripts/install-git-hooks.sh
```

## 常见错误

| 错误 | 修复 |
|------|------|
| 包找不到 | 检查根 `workspace:` 是否登记 |
| resolution 冲突 | 子包加 `resolution: workspace` |
| startup lock | 用 `dart pub get` 代替 `melos bootstrap` |
| analyze 找不到 main | app 包需有 `lib/main.dart`；库包 analyze 整个目录 |
| CI format:check 失败 | 新包未格式化 → `melos run format` 后重新提交 |
