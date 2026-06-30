import 'package:flutter/widgets.dart';
import '../domain/registry/route_registry.dart';
import '../domain/state/navigation_state.dart';

/// Navigator 2.0 URL / 路径解析器（RouteInformationParser）。
///
/// 职责：
/// - `parseRouteInformation`：URL / Deep Link → [NavigationState]
/// - `restoreRouteInformation`：[NavigationState] → URL（Web 前进 / 后退 / 地址栏同步）
/// - 委托 [RouteRegistry.match] 完成路径匹配与参数提取
/// - 匹配失败时走 404 兜底，不 throw
///
/// 设计原则：
/// - 只负责「翻译」，不持有栈状态（状态归 Delegate）
///
/// 依赖：domain 层
///
/// 状态：已实现（M1）
class FastRouteInformationParser extends RouteInformationParser<NavigationState> {
  final RouteRegistry registry;

  FastRouteInformationParser({required this.registry});

  @override
  Future<NavigationState> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = routeInformation.uri;
    
    // 如果 URL 为空，默认访问根路径
    final targetUri = (uri.path.isEmpty) ? Uri(path: '/') : uri;
    
    // 使用 registry 进行匹配
    final match = registry.matchLocation(targetUri);
    
    // 将匹配结果转换为全新的 NavigationState，作为替换的新栈（DeepLink/URL访问）
    return NavigationState(matches: [match]);
  }

  @override
  RouteInformation? restoreRouteInformation(NavigationState configuration) {
    // 将当前栈顶的状态转换为 URL，回写给系统（如 Web 的地址栏）
    if (configuration.isEmpty) return null;
    
    final uri = configuration.location;
    return RouteInformation(uri: uri);
  }
}
