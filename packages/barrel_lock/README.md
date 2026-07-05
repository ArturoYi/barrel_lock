# barrel_lock

BarrelLock 共享业务 Feature 包：**MVVM-C 的 Model / ViewModel / Coordinator 在此统一实现，View 留各平台 app**。

## 与 core 的分工

| 包 | 职责 |
|---|---|
| `core` | 基础设施：主题、偏好、路由（AppRoutes / AppRouter）、Riverpod 入口 |
| `barrel_lock` | BarrelLock 业务 Feature 的状态与编排 |
| 各平台 app | Page Widget（V 层）、原生配置、`app_router_config.dart` |

## 目录结构

```text
lib/
├── barrel_lock.dart
└── features/
    └── launch_screen/
        ├── launch_screen.dart              # feature export
        ├── launch_screen_model.dart        # M
        ├── launch_screen_view_model.dart    # VM
        └── launch_screen_coordinator.dart  # C
```

## 平台 app 接入（launch_screen）

### View（留平台）

```dart
import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class LaunchScreenPage extends ConsumerStatefulWidget { /* ... */ }

// initState 中：
ref.read(launchScreenViewModelProvider.notifier).onViewAppeared();
```

### 平台差异注入（可选）

```dart
runApp(
  ProviderScope(
    overrides: [
      launchScreenPrepareProvider.overrideWith(
        (_) => () async {
          // iOS ATT、Android 预初始化等
        },
      ),
    ],
    child: const BazaarApp(),
  ),
);
```

## 新增 Feature

1. 在 `lib/features/<name>/` 按 MVVM-C 拆分 M / VM / C
2. 从 `barrel_lock.dart` export
3. 各平台 `lib/pages/<name>/` 仅保留 View
4. `melos run analyze` 验证

## 依赖

```
各平台 app → barrel_lock → core → fast_navigator
```
