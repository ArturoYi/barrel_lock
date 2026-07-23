# BarrelLock

<p align="center">
  <img src="apps/barrel_lock_ui/assets/app_icon.png" alt="BarrelLock App Icon" width="128" height="128" />
</p>

**BarrelLock** 是一款本地优先的跨平台密码与敏感信息管理应用。名字取自「桶锁」——像把珍贵的东西锁进一只坚固的桶里；应用图标中的贝壳与钥匙孔，也寓意「外壳保护、内核加密」。

## 项目初衷

在依赖云端同步的密码管理器之外，我们希望做一款**数据留在本机、密钥由用户掌控**的工具：不绑定特定云服务，换机与备份由用户自行决定，减少第三方托管带来的隐私与可用性风险。

BarrelLock 的目标不是功能堆砌，而是把「存得安全、用得顺手」做扎实：

- **本地加密保险库** — 密码、网站登录、银行卡、安全笔记、附件等统一存入 SQLite，敏感字段经 ChaCha20-Poly1305 加密
- **应用级二次防护** — 支持 PIN / 生物识别解锁，离开应用时可自动上锁
- **真正跨平台** — Android、iOS、macOS、Windows、Linux、Web 共用一套业务逻辑（MVVM-C），各平台独立适配界面
- **可迁移、可备份** — 加密备份包、本地快照、文件导入导出等能力持续演进，方便换机与灾备

本仓库是 BarrelLock 的**单 App monorepo**：共享 Feature 与基础设施集中维护，按平台拆分为独立 Flutter 工程，便于分别构建与发布。

---

使用 [Melos](https://melos.invertase.dev/) + [Dart pub workspaces](https://dart.dev/tools/pub/workspaces) 管理上述 monorepo。

## 项目结构

```text
barrel_lock/
├── .github/workflows/        # CI/CD（GitHub Actions）
├── .vscode/                  # VS Code 调试/SDK 配置
├── .fvmrc                    # FVM 锁定的 Flutter 版本
├── apps/
│   ├── barrel_lock/          # 共享业务 Feature（MVVM-C M/VM/C + 路由）
│   ├── barrel_lock_ui/       # 启动入口与根 Widget
│   ├── android/              # Android 独立工程（含 lib/pages/）
│   ├── ios/                  # iOS 独立工程
│   ├── macos/                # macOS 独立工程
│   ├── windows/              # Windows 独立工程
│   ├── linux/                # Linux 独立工程
│   └── web/                  # Web 独立工程
├── packages/
│   ├── core/                 # 基础设施（主题/偏好/存储/Riverpod 入口）
│   ├── fast_navigator/       # 自研声明式路由引擎
│   ├── fast_dialog/          # 全局 Dialog 弹窗栈
│   ├── fast_loading/         # 全局 Loading 遮罩
│   ├── fast_toast/           # 全局 Toast
│   └── app_fonts/            # 字体资源
├── pubspec.yaml              # 工作区根配置 + Melos 8.0.0 scripts
├── pubspec.lock
└── melos_outputs/            # 构建产物汇聚目录（.gitignore）
```

## 环境要求

- **Flutter 3.44.2**（由 `.fvmrc` 锁定，通过 FVM 安装）
- **Dart ^3.12.2**（根 `pubspec.yaml` 约束）
- **[Melos ^8.0.0](https://pub.dev/packages/melos)** CLI

> Melos 8.0.0 必须使用 Dart pub workspaces，所有子包 `pubspec.yaml` 必须添加 `resolution: workspace`。

## 快速开始

```bash
# 1. 安装 FVM（若未安装）
brew install fvm          # macOS
# 或 dart pub global activate fvm

# 2. 用 FVM 安装锁定版本的 Flutter
fvm install               # 读取 .fvmrc -> 3.44.2

# 3. 全局安装 Melos（若未安装）
dart pub global activate melos

# 4. 初始化工作区
dart pub get

# 5. 运行指定平台应用（示例：macOS）
melos run run:macos
# 或
cd apps/macos && fvm flutter run -d macos
```

## 路由架构

路由地址（`AppRoutes`）与导航 API（`AppRouter`）在 `apps/barrel_lock/lib/router/` 统一管理；各平台通过 `app_router_config.dart` 注入 Page Widget。

```text
apps/barrel_lock/router/   → AppRoutes、AppRouter（SSOT）
apps/barrel_lock/features/ → 共享 M / VM / C
各平台 app/lib/pages/      → View（MVVM-C 的 V 层）
各平台 app/lib/router/     → configureBarrelLockRouter()
各平台 app/lib/main.dart   → runBarrelLockApp(configureRouter: ...)
```

详见 [apps/barrel_lock/README.md](apps/barrel_lock/README.md)。

## 常用命令

> 所有脚本均通过根 `pubspec.yaml` 的 `melos.scripts` 块统一配置，使用 `melos run <name>` 调用。

### 质量门禁

| 命令 | 说明 |
|------|------|
| `dart pub get` | 初始化/更新工作区依赖 |
| `melos list` | 列出所有包 |
| `melos run analyze` | 静态分析 |
| `melos run analyze:fix` | 自动应用 analyzer 建议 |
| `melos run format` | 格式化所有 Dart 代码 |
| `melos run format:check` | 校验格式（CI 用，不修改文件） |
| `melos run test` | 运行所有测试 |
| `melos run test:coverage` | 运行测试并产出 coverage 报告 |
| `melos run ci` | 一键质量门禁：`format:check` → `analyze` → `test` |

### BarrelLock App

| 命令 | 说明 |
|------|------|
| `melos run run:<platform>` | 运行指定平台应用（android/ios/windows/linux/web/macos） |
| `melos run build:<platform>` | 构建指定平台应用 |
| `melos run build:android:bundle` | 构建 Android AAB（Play Store） |
| `melos run clean` | `flutter clean` 每个子包 |
| `melos run clean:full` | 深度清理（含 `build/`、`melos_outputs/`、`.dart_tool/`） |

## 添加新包

1. 在 `apps/` 或 `packages/` 下创建新包
2. 在新包的 `pubspec.yaml` 中添加 `resolution: workspace`
3. 在根 `pubspec.yaml` 的 `workspace:` 列表中追加新包路径（Melos 8.0.0 不会自动扫描 glob，需手动登记）
4. 运行 `dart pub get`

## CI/CD

GitHub Actions 工作流位于 `.github/workflows/`:

| Workflow | 触发条件 | 职责 |
|----------|----------|------|
| `ci.yml` | push / PR | 质量门禁：`melos run ci`，并上传 coverage 报告 |
| `build-android.yml` | push tag `v*` / manual | Android APK + AAB，产物上传到 Artifacts；tag 自动附到 GitHub Release |
| `build-ios.yml` | push tag `v*` / manual | iOS 无签名构建 |
| `build-macos.yml` | push tag `v*` / manual | macOS release + 自动 zip |
| `build-web.yml` | push / PR / manual | Web release，main 分支自动部署到 GitHub Pages |

构建产物在 CI 内部统一汇聚到 `melos_outputs/` 后通过 `actions/upload-artifact` 上传。

## 从旧仓库迁移

若你此前 clone 的是 `flutter_bazaar` 或 `bazaar_flutter`：

1. GitHub 仓库已重命名为 `barrel_lock`（或请维护者完成 rename）
2. 本地目录建议同步重命名：`mv flutter_bazaar barrel_lock`
3. 更新 remote：`git remote set-url origin https://github.com/<owner>/barrel_lock.git`
4. 目录结构已扁平化：原 `apps/BarrelLock/BarrelLock_android` 现为 `apps/android`

Dart 包名（`barrel_lock_android` 等）与 Native ID 未变，无需改 import 或应用配置。
