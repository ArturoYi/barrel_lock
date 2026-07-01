---
name: extract-shared-feature
description: Extracts duplicated code from multi-platform BarrelLock apps into a shared packages/ module. Use when code is duplicated across android/ios/macos/web/windows/linux apps, or when extracting shared UI, providers, or business logic.
---

# 抽取共享 Feature 包

## 背景

BarrelLock 按平台拆分为 6 个独立 Flutter 工程，当前 `lib/pages/`、`lib/router/` 在各平台间重复。新功能应优先抽到 `packages/`，平台 app 只做薄壳。

## 决策：什么该抽、什么留平台

| 抽到 packages | 留在平台 app |
|---------------|--------------|
| 页面 Widget（无平台 API） | 平台权限、原生通道 |
| Riverpod providers | 平台特有 main.dart 配置 |
| 路由表、AppRoutes | 各平台 build.gradle / Info.plist 等 |
| 主题、常量、工具类 | 平台特有插件初始化 |

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
apps/BarrelLock/BarrelLock_android/lib/
apps/BarrelLock/BarrelLock_ios/lib/
apps/BarrelLock/BarrelLock_macos/lib/
...
```

若 `pages/`、`router/` 内容相同或仅 import 路径不同，适合抽取。

### Step 2: 创建包

按 `add-workspace-package` skill 创建，推荐命名：

```
packages/barrel_lock_ui/     # 共享 UI + 路由
packages/barrel_lock/        # 业务逻辑 + providers
```

依赖关系建议：

```
barrel_lock_ui → core, fast_navigator
barrel_lock    → core, barrel_lock_ui
各平台 app     → barrel_lock_ui (或 barrel_lock)
```

### Step 3: 迁移结构

```
packages/barrel_lock_ui/
├── lib/
│   ├── barrel_lock_ui.dart
│   ├── router/
│   │   └── app_router.dart      # 原 AppRouter + AppRoutes
│   └── pages/
│       ├── home_page.dart
│       ├── detail_page.dart
│       └── settings_page.dart
```

入口 export：

```dart
library;

export 'router/app_router.dart';
export 'pages/home_page.dart';
// ...
```

### Step 4: 平台 app 瘦身

平台 `lib/main.dart` 改为：

```dart
import 'package:barrel_lock_ui/barrel_lock_ui.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ProviderScope(child: BazaarApp()));
}

class BazaarApp extends StatelessWidget {
  const BazaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: AppRouter.routerConfig,
    );
  }
}
```

删除各平台重复的 `lib/pages/`、`lib/router/`。

### Step 5: 平台差异处理

若某平台需要特殊行为：

```dart
// packages/barrel_lock_ui 中
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
