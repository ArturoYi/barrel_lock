# Core 路由模块

BarrelLock 共享路由层：**地址与导航 API 在 `core` 统一管理，页面 Widget 由各平台 app 注入**。

## 架构分层

```text
┌─────────────────────────────────────────────────────────────┐
│  Platform App（BarrelLock_ios / _android / …）               │
│  lib/pages/          → 各平台独立 Page Widget（MVVM-C）       │
│  lib/router/app_router_config.dart → AppRouteBuilders 注入   │
└───────────────────────────┬─────────────────────────────────┘
                            │ AppRouter.configure(builders)
┌───────────────────────────▼─────────────────────────────────┐
│  packages/core/lib/router/                                   │
│  domain/         AppRoutes、AppSimpleRoute、DetailRoute      │
│  application/    AppRouter、AppRouteBuilders                 │
│  presentation/   UnknownRoutePage                            │
└───────────────────────────┬─────────────────────────────────┘
                            │ FastNavigator / FastRouterConfig
┌───────────────────────────▼─────────────────────────────────┐
│  packages/fast_navigator/                                    │
└─────────────────────────────────────────────────────────────┘
```

## 路由描述符约定

| 类型 | 对外 API | 示例 |
|------|----------|------|
| 无参路由 | [AppSimpleRoute] 的 `.name` / `.path` 属性 | `AppRoutes.home.path` |
| 带参路由 | 独立类 + `call()` 方法 | `AppRoutes.detail(id: '42')` |

新增无参路由：在 [AppRoutes] 追加 `AppSimpleRoute`，并在 [AppRouteBuilders] / [AppRouter._buildRoutes] 注册。

新增带参路由：在 `domain/` 新建描述符类（含 `path` 模板与 `call()`），同步扩展 [AppRouteBuilders]。

## 平台 app 接入

### 1. 装配路由（main 之前）

```dart
// lib/router/app_router_config.dart
import 'package:core/core.dart';

import '../pages/detail_page.dart';
import '../pages/home_page.dart';
import '../pages/launch_screen/launch_screen_page.dart';
import '../pages/settings_page.dart';

void configureBarrelLockRouter() {
  AppRouter.configure(
    AppRouteBuilders(
      launchScreen: (_, _) => const LaunchScreenPage(),
      home: (_, _) => const HomePage(),
      detail: (_, match) => DetailPage(
        id: match.parameters.pathParams['id']!,
      ),
      settings: (_, _) => const SettingsPage(),
    ),
  );
}
```

```dart
// lib/main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SPStorage.init();
  configureBarrelLockRouter();
  runApp(const ProviderScope(child: BazaarApp()));
}
```

### 2. 页面内跳转

```dart
import 'package:core/core.dart';

// 无参
AppRouter.go(AppRoutes.home.path);
AppRouter.pushNamed(AppRoutes.settings.name);

// 带参
AppRouter.push(AppRoutes.detail(id: 'demo'));
AppRouter.pushNamed(
  AppRoutes.detail.name,
  pathParams: {'id': '42'},
);
```

### 3. MVVM-C Coordinator

Coordinator 只依赖 `AppRoutes` + `AppRouter`，不 import 平台 `pages/`：

```dart
void goToHome() => AppRouter.go(AppRoutes.home.path);
```

## 禁止事项

- 不在 `core` 中 import 各平台 `pages/`
- 不在 View / ViewModel 中硬编码路径字符串
- 不使用 Navigator 1.0 的 `pushNamed`
- 不把 `RouteMatch.extra` 纳入 Page Key（见 fast_navigator 规范）

## 相关文档

- [fast_navigator README](../../fast_navigator/README.md)
- [core README](../README.md)
- `.cursor/rules/fast-navigator-mdc.mdc`
- `.cursor/rules/mvvm-c-mdc.mdc`
