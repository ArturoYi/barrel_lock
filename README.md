# Flutter Bazaar

使用 [Melos](https://melos.invertase.dev/) + [Dart pub workspaces](https://dart.dev/tools/pub/workspaces) 管理的 Flutter 多包工作区,按平台拆分为独立应用。

## 项目结构

```text
flutter_bazaar/
├── .github/workflows/        # CI/CD(GitHub Actions)
├── .vscode/                  # VS Code 调试/SDK 配置
├── .fvmrc                    # FVM 锁定的 Flutter 版本
├── apps/
│   └── BarrelLock/           # BarrelLock 应用
│       ├── BarrelLock_android/  # Android 独立工程
│       ├── BarrelLock_ios/      # iOS 独立工程
│       ├── BarrelLock_windows/  # Windows 独立工程
│       ├── BarrelLock_linux/    # Linux 独立工程
│       ├── BarrelLock_web/      # Web 独立工程
│       └── BarrelLock_macos/    # macOS 独立工程
├── packages/
│   ├── core/                 # 共享核心库(常量/工具/异常)
│   └── fast_navigator/       # 自研声明式路由框架(对标 go_router)
├── pubspec.yaml              # 工作区根配置 + Melos 8.0.0 scripts
├── pubspec.lock
└── melos_outputs/            # 构建产物汇聚目录(.gitignore)
```

## 环境要求

- **Flutter 3.44.2**(由 `.fvmrc` 锁定,通过 FVM 安装)
- **Dart ^3.12.2**(根 `pubspec.yaml` 约束)
- **[Melos ^8.0.0](https://pub.dev/packages/melos)** CLI

> Melos 8.0.0 必须使用 Dart pub workspaces,所有子包 `pubspec.yaml` 必须添加 `resolution: workspace`。

## 快速开始

```bash
# 1. 安装 FVM(若未安装)
brew install fvm          # macOS
# 或 dart pub global activate fvm

# 2. 用 FVM 安装锁定版本的 Flutter
fvm install               # 读取 .fvmrc -> 3.44.2

# 3. 全局安装 Melos(若未安装)
dart pub global activate melos

# 4. 初始化工作区:链接本地包 + 安装依赖
melos bootstrap

# 5. 运行指定平台应用(示例:macOS)
melos run run:macos
# 或
cd apps/BarrelLock/BarrelLock_macos && fvm flutter run -d macos
```

## 常用命令

> 所有脚本均通过根 `pubspec.yaml` 的 `melos.scripts` 块统一配置,使用 `melos run <name>` 调用。

### 质量门禁

| 命令 | 说明 |
|------|------|
| `melos bootstrap` | 初始化/更新工作区依赖 |
| `melos list` | 列出所有包 |
| `melos run analyze` | 静态分析 |
| `melos run analyze:fix` | 自动应用 analyzer 建议 |
| `melos run format` | 格式化所有 Dart 代码 |
| `melos run format:check` | 校验格式(CI 用,不修改文件) |
| `melos run test` | 运行所有测试 |
| `melos run test:coverage` | 运行测试并产出 coverage 报告 |
| `melos run ci` | 一键质量门禁:`format:check` -> `analyze` -> `test` |

### BarrelLock App

| 命令 | 说明 |
|------|------|
| `melos run run:<platform>` | 运行指定平台应用(android/ios/windows/linux/web/macos) |
| `melos run build:<platform>` | 构建指定平台应用 |
| `melos run build:android:bundle` | 构建 Android AAB(Play Store) |
| `melos run clean` | `flutter clean` 每个子包 |
| `melos run clean:full` | 深度清理(含 `build/`、`melos_outputs/`、`.dart_tool/`) |

## 添加新包

1. 在 `apps/` 或 `packages/` 下创建新包
2. 在新包的 `pubspec.yaml` 中添加 `resolution: workspace`
3. 在根 `pubspec.yaml` 的 `workspace:` 列表中追加新包路径(Melos 8.0.0 不会自动扫描 glob,需手动登记)
4. 运行 `melos bootstrap`

## CI/CD

GitHub Actions 工作流位于 `.github/workflows/`:

| Workflow | 触发条件 | 职责 |
|----------|----------|------|
| `ci.yml` | push / PR | 质量门禁:`melos run ci`,并上传 coverage 报告 |
| `build-android.yml` | push tag `v*` / manual | Android APK + AAB,产物上传到 Artifacts;tag 自动附到 GitHub Release |
| `build-ios.yml` | push tag `v*` / manual | iOS 无签名构建 |
| `build-macos.yml` | push tag `v*` / manual | macOS release + 自动 zip |
| `build-web.yml` | push / PR / manual | Web release,main 分支自动部署到 GitHub Pages |

构建产物在 CI 内部统一汇聚到 `melos_outputs/` 后通过 `actions/upload-artifact` 上传。


