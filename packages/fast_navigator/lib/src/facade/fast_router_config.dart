import 'package:flutter/widgets.dart';
import '../core/fast_router.dart';
import '../domain/navigation_state.dart';
import '../domain/routes/routes.dart';
import '../domain/route_registry.dart';
import 'fast_navigator.dart';

/// MaterialApp.router 一键接入配置（FastRouterConfig）。
///
/// 职责：
/// - 封装 [FastRouter] 的便捷构造
/// - 统一 initialLocation、routes 等接入参数
/// - 初始化 [FastNavigator]
///
/// 状态：已实现（M1）
class FastRouterConfig {
  /// 暴露给 MaterialApp.router 的配置对象
  final RouterConfig<NavigationState> routerConfig;

  FastRouterConfig._(this.routerConfig);

  /// 初始化 FastRouter 的核心入口
  ///
  /// [navigationThrottleMs] 导航节流窗口（毫秒）。
  /// 首次点击立即执行，窗口期内重复点击全部丢弃；为 0（默认）时不节流。
  factory FastRouterConfig({
    required List<FastBaseRoute> routes,
    FastRoute? unknownRoute,
    String initialLocation = '/',
    int navigationThrottleMs = 0,
  }) {
    final registry = RouteRegistry(
      routes: routes,
      unknownRoute: unknownRoute,
    );

    final router = FastRouter(
      registry: registry,
      initialLocation: initialLocation,
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
