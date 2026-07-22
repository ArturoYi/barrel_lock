# barrel_lock

BarrelLock 产品包（位于 `apps/barrel_lock/`）：**MVVM-C 的 M/VM/C、路由、应用壳**；View 在各平台 `lib/pages/`。

## 与 core 的分工

| 包 | 职责 |
|---|---|
| `core` | SP、Theme 引擎、Riverpod / fast_* re-export |
| `barrel_lock` | AppRoutes、AppRouter、ThemedApp、业务 Feature |
| `barrel_lock_ui` | `runBarrelLockApp()`、根 Widget |
| 各平台 app | Page Widget、`app_router_config.dart` |

## 目录结构

```text
lib/
├── app_info.dart
├── router/
├── shell/themed_app.dart
├── preference/
└── features/
    ├── launch_screen/
    ├── home/
    ├── detail/
    └── settings/
```

## 平台 app 接入

```dart
import 'package:barrel_lock_ui/barrel_lock_ui.dart';

import 'router/app_router_config.dart';

Future<void> main() async {
  await runBarrelLockApp(
    configureRouter: configureBarrelLockRouter,
    scopeBuilder: (child) => ProviderScope(
      overrides: [
        launchScreenPrepareProvider.overrideWith((_) => platformInit),
      ],
      child: child,
    ),
  );
}
```

## 依赖

```
barrel_lock_ui → barrel_lock → core → fast_*
各平台 app   → barrel_lock_ui, barrel_lock, core
```
