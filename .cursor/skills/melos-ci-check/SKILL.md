---
name: melos-ci-check
description: Runs the BarrelLock quality gate (format, analyze, test) via Melos scripts. Use when fixing CI failures, checking merge readiness, running analyze/format/test, or before creating a PR.
---

# Melos CI 质量门禁

## 一键门禁

与 GitHub Actions `ci.yml` 一致：

```bash
melos run ci
```

等价于顺序执行：

```bash
melos run format:check   # 只检查，不修改
melos run analyze
melos run test
```

## 工作流

```
Task Progress:
- [ ] Step 1: 运行 melos run ci
- [ ] Step 2: 若有 format 失败 → melos run format
- [ ] Step 3: 若有 analyze 失败 → 逐包修复
- [ ] Step 4: 若有 test 失败 → 修复后重跑
- [ ] Step 5: 再次 melos run ci 确认通过
```

## 分步命令

| 命令 | 说明 |
|------|------|
| `melos run format:check` | CI 用，格式不对则 exit 1 |
| `melos run format` | 自动格式化所有 Dart 文件 |
| `melos run analyze` | 全包静态分析 |
| `melos run analyze:fix` | 自动应用 analyzer 建议 |
| `melos run test` | 运行 packages 测试（core、fast_navigator） |
| `melos run test:coverage` | 测试 + coverage 报告 |

## 单包调试

```bash
cd packages/fast_navigator
dart analyze .
flutter test --no-pub --reporter=expanded
dart format .
```

## 环境要求

- Flutter **3.44.2**（`.fvmrc` / FVM）
- 本地优先：`fvm flutter` 或确保 FVM 版本在 PATH
- 首次：`dart pub get`（根目录，解析全部 workspace 包）

## 修复顺序

1. **format** — 最快，先 `melos run format`
2. **analyze** — 读错误信息，按包修复；可用 `melos run analyze:fix` 处理简单项
3. **test** — 当前覆盖 `packages/core`、`packages/fast_navigator`

## 运行 App（非 CI，但常用）

```bash
melos run run:macos      # 或 android / ios / web / windows / linux
melos run build:macos    # release 构建
```

## CI 对齐

GitHub Actions 步骤：

1. `dart pub get`（非 melos bootstrap）
2. `melos run ci --no-select`

本地通过 `melos run ci` 即与 CI 等效。
