import '../core/fast_router_delegate.dart';
import '../domain/route_registry.dart';

/// 全场景路由跳转门面 API（FastNavigator）。
///
/// 职责：
/// - 对外提供 push / pop / replace / go / popUntil / pushAndPopUntil
/// - 无 Context 全局调用（通过 bind 注入 RouterDelegate）
/// - 内部只做：registry.match → NavigationState 变换 → delegate.setState
///
/// 依赖：core 层、domain 层
///
/// 状态：已实现（M1 基础 API，M2 全量 API）
class FastNavigator {
  // 单例模式
  static final FastNavigator _instance = FastNavigator._internal();
  factory FastNavigator() => _instance;
  FastNavigator._internal();

  FastRouterDelegate? _delegate;
  RouteRegistry? _registry;

  /// 初始化绑定 Delegate 和 Registry
  /// 仅供内部或 FastRouterConfig 初始化时调用
  static void bind(FastRouterDelegate delegate, RouteRegistry registry) {
    _instance._delegate = delegate;
    _instance._registry = registry;
  }

  void _checkInitialized() {
    if (_delegate == null || _registry == null) {
      throw StateError('FastNavigator has not been initialized. Please ensure FastRouterConfig is created first.');
    }
  }

  /// Push 命名路由
  static void pushNamed(String name, {Map<String, String>? pathParams, Map<String, String>? queryParams, Object? extra}) {
    _instance._checkInitialized();
    final route = _instance._registry!.findByName(name);
    if (route == null) throw ArgumentError('Route name "$name" not found.');

    // 简单组装 URI 进行匹配（也可以直接基于 RouteConfig 构造 Match，但走统一的 matchLocation 逻辑更安全）
    var path = route.path;
    pathParams?.forEach((key, value) {
      path = path.replaceAll(':$key', value);
    });
    
    final uri = Uri(path: path, queryParameters: queryParams);
    push(uri.toString(), extra: extra);
  }

  /// Push URL 路径
  static void push(String location, {Object? extra}) {
    _instance._checkInitialized();
    final match = _instance._registry!.matchLocation(Uri.parse(location), extra: extra);
    final newState = _instance._delegate!.state.push(match);
    _instance._delegate!.updateState(newState);
  }

  /// Pop 弹出栈顶
  static void pop() {
    _instance._checkInitialized();
    final newState = _instance._delegate!.state.pop();
    _instance._delegate!.updateState(newState);
  }

  /// Replace 替换栈顶
  static void replace(String location, {Object? extra}) {
    _instance._checkInitialized();
    final match = _instance._registry!.matchLocation(Uri.parse(location), extra: extra);
    final newState = _instance._delegate!.state.replace(match);
    _instance._delegate!.updateState(newState);
  }

  /// Go 直接跳转，清空现有栈，完全重置（或压入多级栈）
  static void go(String location, {Object? extra}) {
    _instance._checkInitialized();
    final match = _instance._registry!.matchLocation(Uri.parse(location), extra: extra);
    final newState = _instance._delegate!.state.go([match]);
    _instance._delegate!.updateState(newState);
  }

  /// PopUntil 弹出直到符合条件
  static void popUntil(bool Function(String routeName) predicate) {
    _instance._checkInitialized();
    final newState = _instance._delegate!.state.popUntil((match) => predicate(match.route.name));
    _instance._delegate!.updateState(newState);
  }
}
