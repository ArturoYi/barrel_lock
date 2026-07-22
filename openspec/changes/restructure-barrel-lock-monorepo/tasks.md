## 1. 目录迁移

- [x] 1.1 使用 `git mv` 将 `apps/BarrelLock/BarrelLock_android` → `apps/android`
- [x] 1.2 使用 `git mv` 将 `apps/BarrelLock/BarrelLock_ios` → `apps/ios`
- [x] 1.3 使用 `git mv` 将 `apps/BarrelLock/BarrelLock_macos` → `apps/macos`
- [x] 1.4 使用 `git mv` 将 `apps/BarrelLock/BarrelLock_windows` → `apps/windows`
- [x] 1.5 使用 `git mv` 将 `apps/BarrelLock/BarrelLock_linux` → `apps/linux`
- [x] 1.6 使用 `git mv` 将 `apps/BarrelLock/BarrelLock_web` → `apps/web`
- [x] 1.7 使用 `git mv` 将 `apps/BarrelLock/barrel_lock` → `apps/barrel_lock`
- [x] 1.8 使用 `git mv` 将 `apps/BarrelLock/barrel_lock_ui` → `apps/barrel_lock_ui`
- [x] 1.9 将 `apps/BarrelLock/assets/` 内容合并到 `apps/barrel_lock_ui/assets/`，删除空目录
- [x] 1.10 删除空的 `apps/BarrelLock/` 目录

## 2. 根 workspace 配置

- [x] 2.1 更新根 `pubspec.yaml`：`name` → `barrel_lock_workspace`，`description` → BarrelLock monorepo
- [x] 2.2 更新根 `pubspec.yaml` `workspace:` 列表为扁平路径（`apps/android`、`apps/barrel_lock` 等）
- [x] 2.3 确认 Melos scripts 中 scope 仍匹配 pubspec `name`（`barrel_lock_android` 等），无需改 scope 则标记完成

## 3. path 依赖修复

- [x] 3.1 更新 `apps/barrel_lock/pubspec.yaml` 中 `path:` 依赖（`../../../packages/` → `../../packages/`）
- [x] 3.2 搜索全仓库 `apps/BarrelLock` 字符串，修复残留 path 引用
- [x] 3.3 搜索 `../../../packages/` 等旧相对路径，确保所有显式 path 依赖正确
- [x] 3.4 根目录执行 `dart pub get`，确认 workspace 解析无错误

## 4. 文档与工具链

- [x] 4.1 重写 `README.md`：项目名 BarrelLock、结构图用 `apps/android` 等扁平路径、去掉「跨产品」表述
- [x] 4.2 更新 `apps/barrel_lock/README.md` 路径描述
- [x] 4.3 更新 `packages/core/README.md` 中的路径引用
- [x] 4.4 更新 `.cursor/rules/project-context-mdc.mdc`：单 App monorepo、`apps/` 扁平布局
- [x] 4.5 更新 `.cursor/rules/mvvm-c-mdc.mdc`、`fast-navigator-mdc.mdc` 中的路径
- [x] 4.6 更新 `.cursor/skills/add-workspace-package/SKILL.md`、`extract-shared-feature/SKILL.md`、`melos-ci-check/SKILL.md` 中的路径与示例
- [x] 4.7 更新 `packages/*/pubspec.yaml` 和 README 中的 "Flutter Bazaar" 文案为 BarrelLock

## 5. CI 与工作流

- [x] 5.1 检查 `.github/workflows/*.yml` 是否有硬编码 `apps/BarrelLock` 路径，如有则更新
- [x] 5.2 确认 CI 中 melos scope（`barrel_lock_android` 等）仍有效

## 6. 验证

- [x] 6.1 运行 `melos run format`
- [ ] 6.2 运行 `melos run ci`，确认 format:check → analyze → test 全部通过（format:check + analyze 已通过；test 有 2 个既有失败：`backup_ble_gatt_transfer_test`、`backup_manage_model_test`，与本次迁移无关）
- [x] 6.3 抽查 Android `applicationId` 与 iOS `PRODUCT_BUNDLE_IDENTIFIER` 未被改动

## 7. 仓库重命名（可选，建议同步）

- [ ] 7.1 GitHub 上将 remote 仓库 `bazaar_flutter` rename 为 `barrel_lock`
- [ ] 7.2 本地将目录 `flutter_bazaar` rename 为 `barrel_lock`
- [ ] 7.3 更新 `git remote set-url origin` 指向新 URL
- [x] 7.4 README 增加「从 flutter_bazaar / bazaar_flutter 迁移」说明
