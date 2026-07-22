## Why

仓库当前名为 `flutter_bazaar`，但只服务一款 App（BarrelLock），且 `apps/BarrelLock/` 中间层没有实际价值，导致命名混乱、路径过深、文档仍按「多产品 monorepo」描述。现在统一为单 App 仓库 `barrel_lock`，可以消除认知负担并为后续开发提供一致的项目结构。

## What Changes

- **BREAKING** 仓库根目录重命名：`flutter_bazaar` → `barrel_lock`（本地目录与 Git remote 建议同步）
- **BREAKING** 根 `pubspec.yaml` 的 `name` 从 `flutter_bazaar` 改为 `barrel_lock_workspace`
- **BREAKING** 扁平化 `apps/`：移除 `apps/BarrelLock/` 中间层，子项目直接位于 `apps/` 下
  - `apps/BarrelLock/BarrelLock_android` → `apps/android`
  - `apps/BarrelLock/BarrelLock_ios` → `apps/ios`
  - `apps/BarrelLock/BarrelLock_macos` → `apps/macos`
  - `apps/BarrelLock/BarrelLock_windows` → `apps/windows`
  - `apps/BarrelLock/BarrelLock_linux` → `apps/linux`
  - `apps/BarrelLock/BarrelLock_web` → `apps/web`
  - `apps/BarrelLock/barrel_lock` → `apps/barrel_lock`
  - `apps/BarrelLock/barrel_lock_ui` → `apps/barrel_lock_ui`
  - `apps/BarrelLock/assets` → `apps/assets`（或并入 `barrel_lock_ui/assets`）
- 更新根 `workspace:` 列表、各包 `path:` 依赖、Melos scripts scope
- 更新 README、`.cursor/rules`、`.cursor/skills` 中的路径与「Flutter Bazaar / 跨产品」表述
- 更新 CI workflows 中的 scope 与路径引用
- **不变**：Dart 包名（`barrel_lock`、`barrel_lock_android` 等）、App 显示名 BarrelLock、已发布的 Native ID（`com.hulk.bazaarAndroid` / `com.hulk.bazaarIos`）

## Capabilities

### New Capabilities

- `monorepo-layout`: 单 App Melos workspace 目录布局与命名约定（`apps/` 扁平结构、`packages/` 共享库、根 workspace 登记规则）

### Modified Capabilities

（无——本次为纯结构/命名重组，不改变 App 功能需求。）

## Impact

- **根配置**：`pubspec.yaml`（name、workspace 路径、melos scripts）
- **App 包**：8 个子包物理路径迁移，内部 `path:` 依赖深度变化（如 `../../../packages/` → `../../packages/`）
- **共享库**：`packages/core`、`packages/fast_*` 的 description 文案
- **CI**：`.github/workflows/*.yml` scope 与路径
- **工具链**：`.cursor/rules/*.mdc`、`.cursor/skills/**/*.md` 中的路径示例
- **OpenSpec**：既有 change 文档中的路径引用（可选批量更新）
- **开发者本地**：需重新 `dart pub get`、更新 IDE 打开路径、可选 rename Git remote
