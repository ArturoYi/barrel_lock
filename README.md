# Flutter Bazaar

使用 [Melos](https://melos.invertase.dev/) 管理的 Flutter 多包工作区，按平台拆分为独立应用。

## 项目结构

```text
flutter_bazaar/
├── apps/
│   ├── bazaar_android/  # Android 应用
│   ├── bazaar_ios/      # iOS 应用
│   ├── bazaar_windows/  # Windows 应用
│   ├── bazaar_linux/    # Linux 应用
│   ├── bazaar_web/      # Web 应用
│   └── bazaar_macos/    # macOS 应用
├── packages/
│   └── core/            # 共享核心库
├── pubspec.yaml         # 工作区根配置
└── pubspec.lock
```

## 环境要求

- Flutter 3.27+（本项目通过 FVM 管理，见 `.fvmrc`）
- Dart 3.6+
- [Melos](https://melos.invertase.dev/getting-started) CLI

## 快速开始

```bash
# 安装 FVM 依赖的 Flutter SDK
fvm install

# 全局安装 Melos（如未安装）
dart pub global activate melos

# 初始化工作区（链接本地包并安装依赖）
melos bootstrap

# 运行指定平台应用（示例：macOS）
melos run run:macos
# 或
cd apps/bazaar_macos && fvm flutter run -d macos
```

## 常用命令

| 命令 | 说明 |
|------|------|
| `melos bootstrap` | 初始化/更新工作区依赖 |
| `melos list` | 列出所有包 |
| `melos run analyze` | 静态分析 |
| `melos run test` | 运行所有测试 |
| `melos run run:<platform>` | 运行指定平台应用（android/ios/windows/linux/web/macos） |
| `melos run build:<platform>` | 构建指定平台应用 |

## 添加新包

1. 在 `apps/` 或 `packages/` 下创建新包
2. 在新包的 `pubspec.yaml` 中添加 `resolution: workspace`
3. 在根 `pubspec.yaml` 的 `workspace:` 列表中注册路径
4. 运行 `melos bootstrap`
