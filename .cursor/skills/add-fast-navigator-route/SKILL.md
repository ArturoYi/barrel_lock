---
name: add-fast-navigator-route
description: Adds a new page route using fast_navigator in BarrelLock apps. Use when the user asks to add a route, new page, screen, navigation target, or jump/link between pages.
---

# 添加 fast_navigator 路由

## 前置检查

- 路由框架：`fast_navigator`（禁止 go_router / auto_route）
- 参考实现：`apps/BarrelLock/BarrelLock_android/lib/router/router.dart`
- 多平台 app 各自有 `lib/router/router.dart` 和 `lib/pages/`，优先改 android 作为模板，再同步到其他平台

## 工作流

```
Task Progress:
- [ ] Step 1: 在 AppRoutes 添加 name + path 常量
- [ ] Step 2: 创建 pages/<name>_page.dart
- [ ] Step 3: 在 _buildRoutes() 注册 FastRoute
- [ ] Step 4: （可选）添加 RouteMiddleware
- [ ] Step 5: 在调用方添加跳转
- [ ] Step 6: melos run analyze 验证
```

### Step 1: AppRoutes 常量

在 `lib/router/router.dart` 的 `AppRoutes` 中追加：

```dart
static const profile = 'profile';
static const profilePath = '/profile';
```

动态路径示例：`static const userDetailPath = '/user/:id';`

### Step 2: 创建页面

在 `lib/pages/<name>_page.dart`：

```dart
import 'package:flutter/material.dart';
import '../router/router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: FilledButton(
          onPressed: AppRouter.pop,
          child: const Text('返回'),
        ),
      ),
    );
  }
}
```

### Step 3: 注册 FastRoute

在 `_buildRoutes()` 追加，并添加 import：

```dart
FastRoute(
  name: AppRoutes.profile,
  path: AppRoutes.profilePath,
  builder: (context, match) => const ProfilePage(),
),
```

带 path 参数：

```dart
FastRoute(
  name: AppRoutes.userDetail,
  path: AppRoutes.userDetailPath,
  builder: (context, match) {
    final id = match.parameters.pathParams['id']!;
    return UserDetailPage(id: id);
  },
),
```

### Step 4: Middleware（可选）

登录/权限拦截示例：

```dart
class AuthMiddleware extends RouteMiddleware {
  @override
  MiddlewareResult handle(NavigationState current, NavigationState target) {
    if (!isLoggedIn) {
      return target.go(loginMatch); // 返回新 State 表示 redirect
    }
    return null; // null = 放行
  }
}
```

挂载到 `FastRoute(middlewares: [AuthMiddleware()])` 或 `FastRouterConfig(globalMiddlewares: [...])`。

### Step 5: 跳转

```dart
// 路径跳转
AppRouter.push(AppRoutes.profilePath);

// 命名跳转
AppRouter.pushNamed(AppRoutes.profile);

// 带参数
AppRouter.pushNamed(
  AppRoutes.userDetail,
  pathParams: {'id': '42'},
  queryParams: {'tab': 'info'},
  extra: someObject, // 不参与 URL
);
```

### Step 6: 验证

```bash
melos run analyze
```

## 禁止事项

- 不用 `Navigator.of(context).push` / `pushNamed`
- 不直接 mutate `NavigationState.matches`
- 不把 `extra` 纳入 Page Key

## 多平台同步

若其他平台（ios/macos/web 等）也有独立 `router.dart` 和 `pages/`，同步相同改动。长期应抽到共享 package，见 `extract-shared-feature` skill。
