import 'package:flutter/widgets.dart';
import '../domain/registry/route_registry.dart';
import '../domain/state/navigation_state.dart';
import '../domain/transition/page_transition.dart';
import '../page/app_type_detector.dart';
import '../page/page_factory.dart';
import 'fast_route_information_parser.dart';
import 'fast_router_delegate.dart';

/// Navigator 2.0 顶层路由容器（Router 组装层）。
///
/// 职责：
/// - 组合 [FastRouterDelegate]、[FastRouteInformationParser]
/// - 产出 `RouterConfig<NavigationState>` 供 `MaterialApp.router` 接入
///
/// 状态：已实现（M1）
class FastRouter {
  final RouteRegistry registry;
  late final FastRouteInformationParser parser;
  late final FastRouterDelegate delegate;

  FastRouter({
    required this.registry,
    String initialLocation = '/',
    PageTransition defaultTransition = const PlatformAdaptiveTransition(),
    AppType? appType,
    List<NavigatorObserver> navigatorObservers = const [],
  }) {
    parser = FastRouteInformationParser(registry: registry);

    // 初始化时，根据 initialLocation 构建初始导航栈
    final initialUri = Uri.parse(initialLocation);
    final initialMatch = registry.matchLocation(initialUri);
    final initialState = NavigationState(matches: [initialMatch]);

    delegate = FastRouterDelegate(
      initialState: initialState,
      pageFactory: PageFactory(
        defaultTransition: defaultTransition,
        appTypeOverride: appType,
      ),
      observers: navigatorObservers,
    );
  }

  /// 获取供 MaterialApp.router 使用的 RouterConfig
  RouterConfig<NavigationState> get routerConfig =>
      RouterConfig<NavigationState>(
        routerDelegate: delegate,
        routeInformationParser: parser,
        routeInformationProvider: PlatformRouteInformationProvider(
          initialRouteInformation: RouteInformation(
            uri: delegate.state.location,
          ),
        ),
        backButtonDispatcher: RootBackButtonDispatcher(),
      );
}
