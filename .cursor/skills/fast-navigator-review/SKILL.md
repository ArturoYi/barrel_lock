---
name: fast-navigator-review
description: Reviews fast_navigator and routing changes for correctness, immutability, and Page Key strategy. Use when reviewing routing PRs, NavigationState changes, middleware, or fast_navigator package modifications.
---

# fast_navigator Code Review

## 审查范围

- `packages/fast_navigator/**`
- 各 app 的 `lib/router/**`
- 涉及 `NavigationState`、`RouteMatch`、`FastRouterDelegate` 的改动

## 审查清单

```
Review Progress:
- [ ] NavigationState 不可变性
- [ ] Page Key 策略
- [ ] Middleware 行为
- [ ] Web URL 同步
- [ ] 业务层 API 使用
- [ ] 测试覆盖
```

### 1. NavigationState 不可变（Critical）

- [ ] 所有栈操作（push/pop/replace/go/popUntil）返回**新** `NavigationState` 实例
- [ ] `matches` 使用 `List.unmodifiable` 或 spread 创建新 List
- [ ] 无 `matches.add()` / `matches.removeLast()` 等原地修改
- [ ] 类标注 `@immutable`

```dart
// ❌ BAD
state.matches.add(match);

// ✅ GOOD
NavigationState(matches: [...state.matches, match]);
```

### 2. Page Key 策略（Critical）

| 场景 | Key 规则 |
|------|----------|
| 同路由不同 id | `routeName:path` |
| 同 id 仅 query 变 | 按需纳入 query |
| 同路由 push 两次 | 加 stackIndex 或 uuid |
| extra 变化 | **不纳入 Key** |

- [ ] `RouteMatch.extra` 未用于 Page Key 生成
- [ ] 重复 push 同路由不会错误复用 Widget 状态

### 3. Middleware（Critical）

- [ ] `handle` 返回 `null` = 放行，返回 `NavigationState` = redirect
- [ ] 执行顺序：globalMiddlewares → route.middlewares → setState
- [ ] 有 redirect 循环保护（redirectLimit，默认 5 次）
- [ ] 异步 Middleware 正确处理 `FutureOr`

### 4. Web URL 同步

- [ ] `NavigationState.location` 与栈顶 URI 一致
- [ ] Parser 能从 URL 重建栈
- [ ] `RouterDelegate.currentConfiguration` 正确回写

### 5. 业务层 API

- [ ] App 层用 `AppRouter.push` / `pushNamed`，非 Navigator 1.0
- [ ] 路由常量集中在 `AppRoutes`
- [ ] `FastRoute` builder 签名为 `(context, match) => Widget`
- [ ] path 参数通过 `match.parameters.pathParams` 读取

### 6. 测试

- [ ] `NavigationState` 栈操作有单元测试
- [ ] LaunchMode（standard/singleTop/singleTask/multipleTop）边界覆盖
- [ ] Middleware redirect 场景有测试

## 反馈格式

- 🔴 **Critical**：必须修复（immutable 破坏、Key 错误、redirect 死循环）
- 🟡 **Suggestion**：建议改进（缺少测试、命名不一致）
- 🟢 **Nice to have**：可选优化

## 架构参考

详细设计见 `packages/fast_navigator/README.md`：

- Domain: `NavigationState`, `RouteMatch`, `RouteRegistry`, `RouteMiddleware`
- Core: `FastRouterDelegate`, `FastRouteInformationParser`, `FastRouter`
- Facade: `FastNavigator`, `FastRouterConfig`

## 禁止引入

- go_router、auto_route、Navigator 1.0 命令式路由混用
