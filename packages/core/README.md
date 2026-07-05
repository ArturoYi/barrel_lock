# core

Flutter Bazaar monorepo 共享核心库：主题、偏好存储、Riverpod 统一入口，以及 BarrelLock 路由层。

## 模块

| 模块 | 路径 | 说明 |
|------|------|------|
| 主题 | `lib/theme/` | 配色、字体、ThemeNotifier、ThemedApp |
| 偏好 | `lib/preference/` | SPStorage、AppPreference |
| 路由 | `lib/router/` | AppRoutes、AppRouter、AppRouteBuilders |
| 应用信息 | `lib/app_info.dart` | appName、greeting 等常量 |

## 路由（BarrelLock）

路由地址与导航 API 在 `core` 统一管理；各平台 Page Widget 通过 [AppRouteBuilders] 注入。

详细架构与接入步骤见 **[lib/router/README.md](lib/router/README.md)**。

```dart
import 'package:core/core.dart';

// main 之前
configureBarrelLockRouter(); // 各平台 lib/router/app_router_config.dart

// 跳转
AppRouter.push(AppRoutes.detail(id: '42'));
```

## 依赖

- [app_fonts](../app_fonts) — 字体资源
- [fast_navigator](../fast_navigator) — 声明式路由引擎
- [fast_loading](../fast_loading) / [fast_toast](../fast_toast) — 全局 UI 能力
- flutter_riverpod — 状态管理（统一 re-export）

## 使用

各平台 app 的 `pubspec.yaml` 依赖 `core:` 即可；通过 `package:core/core.dart` 引入。

```dart
import 'package:core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SPStorage.init();
  configureBarrelLockRouter();
  runApp(const ProviderScope(child: MyApp()));
}
```

## 质量

```bash
melos run analyze
melos run test:dart  # 含 core 包测试
```
