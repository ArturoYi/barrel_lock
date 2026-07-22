---
name: extract-shared-feature
description: Extracts duplicated code from multi-platform BarrelLock apps into a shared packages/ module. Use when code is duplicated across android/ios/macos/web/windows/linux apps, or when extracting shared UI, providers, or business logic.
---

# 抽取共享 Feature 包

## 背景

BarrelLock 按平台拆分为 6 个独立 Flutter 工程。路由层已抽到 `packages/core/lib/router/`，各平台 `lib/pages/` 独立实现。

## 决策：什么该抽、什么留平台

| 抽到 packages | 留在平台 app |
|---------------|--------------|
| AppRoutes、AppRouter、AppRouteBuilders | 平台 Page Widget（MVVM-C） |
| Riverpod providers（跨平台共享时） | `lib/router/app_router_config.dart` 装配 |
| 主题、常量、工具类 | 平台权限、原生通道、main.dart |

## 工作流

```
Task Progress:
- [ ] Step 1: 识别重复代码
- [ ] Step 2: 创建 packages/<feature>/ 
- [ ] Step 3: 迁移代码并建立 export
- [ ] Step 4: 各平台 app 添加依赖并删重复文件
- [ ] Step 5: 平台 app 保留薄壳（main + 平台配置）
- [ ] Step 6: melos run ci 验证
```

### Step 1: 识别重复

对比以下路径的文件差异：

```
apps/android/lib/
apps/ios/lib/
apps/macos/lib/
...
```

若 `pages/` 内容相同或仅 import 路径不同，适合抽到共享 UI 包；**路由层已在 core，无需再抽**。

### Step 2: 创建包

按 `add-workspace-package` skill 创建，推荐命名：

```
apps/barrel_lock/     # 共享 M / VM / C
各平台 app/lib/pages/            # 各平台 View
```

依赖关系建议：

```
barrel_lock    → core
barrel_lock_ui → core, barrel_lock（可选）
各平台 app     → core, barrel_lock
```

### Step 3: 迁移结构

```
apps/barrel_lock_ui/
├── lib/
│   ├── barrel_lock_ui.dart
│   └── pages/
│       ├── home_page.dart
│       ├── detail_page.dart
│       └── settings_page.dart
```

路由仍在 `packages/core/lib/router/`，平台 app 保留 `app_router_config.dart` 注入本地或共享 Page。

### Step 4: 平台 app 瘦身

平台 `lib/main.dart` 改为：

```dart
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'router/app_router_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SPStorage.init();
  configureBarrelLockRouter();
  runApp(const ProviderScope(child: BazaarApp()));
}

class BazaarApp extends StatelessWidget {
  const BazaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemedApp.router(routerConfig: AppRouter.routerConfig);
  }
}
```

删除各平台重复的 `lib/router/router.dart`（已迁移至 core）。

### Step 5: 平台差异处理

若某平台需要特殊行为：

```dart
// apps/barrel_lock_ui 中
typedef PlatformInitializer = Future<void> Function();

// 平台 app main.dart 注入
await platformInit();
runApp(...);
```

或通过 conditional import / 抽象接口，避免在 6 个 app 复制逻辑。

### Step 6: 验证

```bash
melos run analyze
melos run test
# 各平台 smoke test
melos run run:macos
melos run run:android
```

## 迁移原则

- **一次一个 feature**：先 pages + router，再 providers
- **最小 diff**：迁移时不改业务逻辑
- **保持 API 稳定**：`AppRouter.push` 等调用方无需改动
- **禁止**在迁移中引入 go_router 或替换 fast_navigator

## 相关 Skill

- 新建包：`add-workspace-package`
- 加路由：`add-fast-navigator-route`
- 质量检查：`melos-ci-check`
