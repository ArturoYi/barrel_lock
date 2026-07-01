import 'package:flutter/widgets.dart';
import '../domain/registry/route_registry.dart';
import '../domain/route/routes.dart';
import '../domain/state/navigation_state.dart';
import '../domain/transition/page_transition.dart';
import '../page/app_type_detector.dart';
import '../router/fast_router.dart';
import 'fast_navigator.dart';

/// MaterialApp.router 一键接入配置（FastRouterConfig）。
///
/// 职责：
/// - 封装 [FastRouter] 的便捷构造
/// - 统一 initialLocation、routes、defaultTransition 等接入参数
/// - 初始化 [FastNavigator]
///
/// 状态：已实现（M1 + M2 过渡）
class FastRouterConfig {
  /// 暴露给 MaterialApp.router 的配置对象
  final RouterConfig<NavigationState> routerConfig;

  FastRouterConfig._(this.routerConfig);

  /// 初始化 FastRouter 的核心入口
  ///
  /// [defaultTransition] 全局默认过渡策略，默认 [PlatformAdaptiveTransition]。
  /// [appType] 强制指定 App 类型（单测用）；为 null 时自动探测 Material/Cupertino/Widgets。
  ///
  /// [navigationThrottleMs] 导航节流窗口（毫秒）。
  /// 首次点击立即执行，窗口期内重复点击全部丢弃；为 0（默认）时不节流。
  factory FastRouterConfig({
    required List<FastBaseRoute> routes,
    FastRoute? unknownRoute,
    String initialLocation = '/',
    PageTransition defaultTransition = const PlatformAdaptiveTransition(),
    AppType? appType,
    int navigationThrottleMs = 0,
  }) {
    final registry = RouteRegistry(
      routes: routes,
      unknownRoute: unknownRoute,
    );

    final router = FastRouter(
      registry: registry,
      initialLocation: initialLocation,
      defaultTransition: defaultTransition,
      appType: appType,
    );

    // 绑定全局单例门面，方便无 Context 跳转
    FastNavigator.bind(
      router.delegate,
      router.registry,
      navigationThrottleMs: navigationThrottleMs,
    );

    return FastRouterConfig._(router.routerConfig);
  }
}
