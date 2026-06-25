# fast_navigator

基于 Flutter **Navigator 2.0 原生四件套**自研的声明式路由框架，对标 go_router 设计思想，零第三方路由依赖，面向企业生产级跨平台（Mobile / Web / Desktop）场景。

---

## 核心本质

**Navigator 2.0 的本质是：用不可变的「路由状态（Page List）」替代 1.0 的「命令式栈黑盒」，RouterDelegate 做唯一栈管理者，Parser 做状态 ⇄ URL 翻译器，Page 做最小渲染单元——框架只做「状态机 + 匹配 + 拦截」，不做 UI 黑盒。**

---

## 官方四件套 vs 1.0

| 维度 | Navigator 1.0 | Navigator 2.0 |
|------|---------------|---------------|
| 栈管控 | `push/pop` 命令式改栈，开发者不可见 | `List<Page>` 声明式驱动，栈完全透明 |
| URL / Web | 需额外插件，割裂 | `RouteInformation` 一等公民 |
| 状态恢复 | 难 | Parser 可从 URL 重建栈 |
| 页面单元 | `Route`（命令式） | `Page`（声明式，可 diff） |
| 系统返回 | Navigator 内部处理 | `BackButtonDispatcher` + `popRoute()` 显式协议 |

### 数据流

```
浏览器 / 系统 URL 变化
        ↓
RouteInformationParser  →  NavigationState（不可变）
        ↓
RouterDelegate.build()  →  Navigator(pages: [...])
        ↑
RouterDelegate.currentConfiguration  →  回写 URL
```

**与 go_router 的关系**：go_router 不是替代 Navigator 2.0，而是在此之上加了 RouteMatcher、Redirect、Shell、便捷 API。`fast_navigator` 对标这一层，底层仍走原生四件套。

---

## 设计目标

| 痛点 | fast_navigator 解法 |
|------|---------------------|
| 1.0 栈不可控、Web 割裂 | 单一 `NavigationState` 驱动全平台 |
| URL 与栈不同步 | Parser ⇄ Delegate 双向绑定 |
| 手势 / 物理返回乱 pop | 统一 `pop()` 入口 + `BackButtonDispatcher` |
| Page 复用错乱 | 规范 `Page.key` 生成策略 |
| 直接改 List 不刷新 | 强制不可变 `copyWith` |
| 业务 API 缺失 | `FastNavigator` 门面封装栈操作 |
| 登录 / 权限 / 埋点散落 | Middleware 管道 |
| 非法路径崩溃 | `onUnknownRoute` + 404 Page |

---

## 分层架构

```
┌──────────────────────────────────────────────────────────────┐
│  Application Layer（业务 App）                                │
│  - 注册 RouteConfig / ShellRoute                              │
│  - 定义 Middleware（登录、埋点）                               │
│  - 页面 Widget                                                 │
└───────────────────────────┬──────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────┐
│  Facade Layer（对外 API）                                      │
│  FastNavigator          → push / pop / go / replace / ...     │
│  FastRouterConfig       → MaterialApp.router 一键接入          │
└───────────────────────────┬──────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────┐
│  Core Layer（Navigator 2.0 四件套）                          │
│  FastRouterDelegate     → 栈管理、build Navigator、popRoute    │
│  FastRouteInformationParser → URL ↔ NavigationState           │
│  FastRouter             → 组合 Delegate + Parser + Dispatcher │
└───────────────────────────┬──────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────┐
│  Domain Layer（路由领域模型）                                   │
│  NavigationState        → 不可变栈状态（SSOT）                   │
│  RouteMatch             → 单次匹配结果（参数绑定单元）            │
│  RouteRegistry          → 路由表 + 匹配引擎                    │
│  RouteMiddleware        → 拦截管道                             │
└───────────────────────────┬──────────────────────────────────┘
                            │
┌───────────────────────────▼──────────────────────────────────┐
│  Foundation Layer（渲染基础）                                   │
│  FastPage               → Page 工厂 + Key 策略                 │
│  RouteParameters        → path / query / extra 参数模型        │
└──────────────────────────────────────────────────────────────┘
```

---

## 目录结构

```
lib/
├── fast_navigator.dart                 # 包入口，统一 export
└── src/
    ├── core/                           # Navigator 2.0 四件套
    │   ├── fast_router.dart
    │   ├── fast_router_delegate.dart
    │   └── fast_route_information_parser.dart
    ├── domain/                         # 路由领域模型
    │   ├── navigation_state.dart
    │   ├── route_match.dart
    │   ├── route_registry.dart
    │   ├── route_config.dart
    │   └── route_middleware.dart
    ├── facade/                         # 对外门面 API
    │   ├── fast_navigator.dart
    │   └── fast_router_config.dart
    ├── page/                           # Page 渲染层
    │   └── fast_page.dart
    └── params/                         # 参数模型
        └── route_parameters.dart
```

---

## 核心领域模型

### NavigationState — 唯一真相源（SSOT）

- 不可变对象，持有 `List<RouteMatch> matches`（从底到顶的栈）
- 所有栈变更（push / pop / replace / go / popUntil / pushAndPopUntil）必须返回**新实例**
- `location` 属性用于 Web URL 回写（通常为栈顶 URI）
- **禁止**直接 mutate `matches` 列表引用

### RouteMatch — 参数持久绑定单元

| 字段 | 说明 |
|------|------|
| `path` | 实际路径，如 `/user/42` |
| `routeName` | 路由名，如 `userDetail` |
| `pathParams` | 动态路径参数，如 `{id: 42}` |
| `queryParams` | URL 查询参数，如 `{tab: info}` |
| `extra` | 不可序列化参数（对象、回调），不参与 URL |

**Page Key 策略**：

| 场景 | Key 规则 | 原因 |
|------|----------|------|
| 同路由不同 id | `routeName:path` | 不同实例，必须重建 |
| 同 id 仅 query 变 | 可选纳入 query | 需刷新则加 query hash |
| 同路由 push 两次 | 加 `stackIndex` 或 uuid | 防 Page 复用 |
| extra 变化 | **不纳入 Key** | 改 Key 会错误 dispose |

### RouteRegistry — 匹配引擎

- 注册 `RouteConfig` 路由表
- `match(location)` 最长前缀 / 优先级匹配，支持 `:param` 动态段
- `unknown(location)` 404 兜底，**永不 throw**

---

## 四大核心组件职责

| 组件 | 文件 | 职责 |
|------|------|------|
| **Router** | `fast_router.dart` | 组装 Delegate + Parser + BackButtonDispatcher，产出 `RouterConfig` |
| **RouteInformationParser** | `fast_route_information_parser.dart` | URL → NavigationState；NavigationState → RouteInformation |
| **RouterDelegate** | `fast_router_delegate.dart` | 唯一栈写入口、`build Navigator`、`popRoute`、`onPopPage` |
| **Page** | `fast_page.dart` | 从 RouteMatch 生成 Page，规范 Key，创建 Route |

### URL 双向同步策略

| 策略 | 行为 | 适用 |
|------|------|------|
| **Location 模式**（默认） | URL = 栈顶 location | 移动端主路径 + Web 友好 |
| **Full Stack 模式** | URL 编码完整栈 | 强 Web 多 Tab 历史 |
| **Shell 模式**（二期） | 外层 Shell 固定 URL 段，内层 Branch 独立 | Tab + 嵌套导航 |

> Web 刷新时内存栈丢失，默认恢复为单页 `[match]`。中间 push 页若需恢复，须写入 URL 或接受产品约定。

### 系统返回兼容

1. `PopNavigatorRouterDelegateMixin` 绑定 `navigatorKey`
2. `MaterialApp.router` + `RootBackButtonDispatcher`
3. `onPopPage` 与 `popRoute()` 必须走同一 `setState(pop())`

---

## 业务能力

### FastNavigator API

| API | 行为 |
|-----|------|
| `push` | 栈顶追加 |
| `pop` | 弹出栈顶 |
| `replace` | 替换栈顶 |
| `go` | 清栈跳转 |
| `popUntil` | 弹栈至指定路由 |
| `pushAndPopUntil` | 跳转并清栈至 predicate |

对内**从不**调用 `Navigator.push`，只变换 `NavigationState`。

### 多层参数体系

```
location: /user/42?tab=info
          ─────  ──  ──────
          path   │   queryParams
               pathParams(:id)

push('/order', extra: OrderDraft)  →  extra（内存绑定，不写 URL）
```

| 参数类型 | URL | 刷新可恢复 |
|----------|-----|-----------|
| 固定段 / 动态 `:id` | ✅ | ✅ |
| `?key=val` query | ✅ | ✅ |
| `extra` | ❌ | ❌ |

### Middleware 管道

执行顺序：`globalMiddlewares` → `route.middlewares` → `setState`

- 返回 `null`：放行
- 返回新 `NavigationState`：短路 redirect（如登录拦截）
- 需 `redirectLimit` 防死循环（建议默认 5 次）

### 404 兜底

匹配失败 → `registry.unknown(location)` → 404 Page，避免路由崩溃。

---

## 接入示例（目标形态）

```dart
void main() {
  final registry = RouteRegistry();
  runApp(MyApp(registry: registry));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.registry, super.key});
  final RouteRegistry registry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: FastRouter.config(
        registry: registry,
        initialLocation: '/',
        middlewares: [AuthMiddleware()],
        routes: [
          RouteConfig(
            name: 'home',
            path: '/',
            builder: (ctx, m) => HomePage(),
          ),
          RouteConfig(
            name: 'user',
            path: '/user/:id',
            builder: (ctx, m) => UserPage(id: m.pathParams['id']!),
          ),
        ],
      ),
    );
  }
}

// 业务跳转
FastNavigator.push('/user/42?tab=info', extra: UserSource.search);
FastNavigator.go('/login');
```

---

## 潜在坑点

1. **直接修改 `matches` 列表** → Diff 不触发，页面不刷新
2. **Key 含 extra** → extra 变一次 dispose 一次，状态丢失
3. **Parser 与 Delegate 双写状态** → 竞态；仅 Delegate 持有状态
4. **push 不更新 URL（Web）** → 刷新丢页；栈顶变化须触发 URL 回写
5. **Middleware redirect 死循环** → 加 `redirectLimit`
6. **Modal / Dialog** → 非 Page 栈，勿与 Router 栈混用
7. **Hero 跨页** → Page 类型 + Key 策略须一致

---

## 迭代路线图

| 阶段 | 交付 | 验证标准 |
|------|------|----------|
| **M1 内核** | State + Delegate + Parser + Page + push/pop/go | Web 刷新、浏览器后退正常 |
| **M2 业务 API** | replace / popUntil / pushAndPopUntil + 参数 | 单元测试覆盖栈变换 |
| **M3 中间件** | 全局 / 路由拦截 + 404 | 未登录 redirect 可测 |
| **M4 Shell** | 底部 Tab + 各 Branch 独立栈 | 对标 go_router StatefulShell |
| **M5 工程化** | 路由表拆分、日志、调试面板 | 接入 Bazaar 全端 App |

---

## 与 go_router 定位差异

| | go_router | fast_navigator |
|--|-----------|----------------|
| 依赖 | 官方维护、功能全 | 自研、轻量、可深度定制 |
| 学习成本 | 低 | 需理解 2.0 原理 |
| 混合栈 / 定制拦截 | 扩展点固定 | 完全掌控 Middleware / State |
| 适用 | 快速交付 | 长期维护、特殊栈需求 |

---

## 当前状态

**骨架阶段**：目录与核心文件已创建，各文件以注释说明职责，**尚未开始编码实现**。请按 M1 → M5 路线图迭代。
