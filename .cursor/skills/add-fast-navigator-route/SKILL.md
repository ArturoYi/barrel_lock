---
name: add-fast-navigator-route
description: Adds a new page route using fast_navigator in BarrelLock apps. Use when the user asks to add a route, new page, screen, navigation target, or jump/link between pages.
---

# 添加 fast_navigator 路由

## 前置检查

- 路由框架：`fast_navigator`（禁止 go_router / auto_route）
- **路由表 SSOT**：`packages/core/lib/router/`（[AppRoutes]、[AppRouter]、[AppRouteBuilders]）
- **平台装配**：各 app 的 `lib/router/app_router_config.dart` 注入 Page Widget
- 详细架构见 `packages/core/lib/router/README.md`

## 工作流

```
Task Progress:
- [ ] Step 1: 在 core AppRoutes 添加路由描述符
- [ ] Step 2: 扩展 AppRouteBuilders + AppRouter._buildRoutes
- [ ] Step 3: 各平台创建 pages/<name>_page.dart
- [ ] Step 4: 各平台 app_router_config.dart 补 builder
- [ ] Step 5: （可选）添加 RouteMiddleware
- [ ] Step 6: 在调用方添加跳转
- [ ] Step 7: melos run analyze 验证
```

### Step 1: AppRoutes 描述符

在 `packages/core/lib/router/domain/app_routes.dart` 追加：

**无参路由**（属性访问）：

```dart
static const profile = AppSimpleRoute(name: 'profile', path: '/profile');
```

**带参路由**（方法式调用）：在 `domain/` 新建类，参考 [DetailRoute]：

```dart
final class UserDetailRoute {
  const UserDetailRoute();
  String get name => 'userDetail';
  String get path => '/user/:id';
  String call({required String id}) => '/user/$id';
}
```

### Step 2: 扩展 AppRouteBuilders

`packages/core/lib/router/application/app_route_builders.dart` 追加字段；
`app_router.dart` 的 `_buildRoutes` 注册对应 [FastRoute]。

### Step 3: 创建页面

各平台 `lib/pages/<name>_page.dart`（MVVM-C 见 mvvm-c 规则）：

```dart
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  // ...
}
```

### Step 4: 平台装配

各平台 `lib/router/app_router_config.dart`：

```dart
profile: (_, __) => const ProfilePage(),
```

带 path 参数：

```dart
userDetail: (_, match) => UserDetailPage(
  id: match.parameters.pathParams['id']!,
),
```

### Step 5: Middleware（可选）

登录/权限拦截示例：

```dart
class AuthMiddleware extends RouteMiddleware {
  @override
  MiddlewareResult handle(NavigationState current, NavigationState target) {
    if (!isLoggedIn) {
      return target.go(loginMatch);
    }
    return null;
  }
}
```

### Step 6: 跳转

```dart
import 'package:core/core.dart';

// 无参
AppRouter.push(AppRoutes.profile.path);
AppRouter.pushNamed(AppRoutes.profile.name);

// 带参
AppRouter.push(AppRoutes.detail(id: '42'));
AppRouter.pushNamed(
  AppRoutes.detail.name,
  pathParams: {'id': '42'},
  queryParams: {'tab': 'info'},
  extra: someObject,
);
```

### Step 7: 验证

```bash
melos run analyze
```

## 禁止事项

- 不在各平台重复定义 AppRoutes / AppRouter
- 不用 `Navigator.of(context).push` / `pushNamed`
- 不直接 mutate `NavigationState.matches`
- 不把 `extra` 纳入 Page Key

## 多平台同步

- core 路由层改一次，六端 `app_router_config.dart` 同步补 builder
- 页面 Widget 各平台独立，路径与 API 保持一致
