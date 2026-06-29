import '../core/fast_router_delegate.dart';
import '../domain/launch_mode.dart';
import '../domain/route_registry.dart';
import '../utils/navigation_throttle.dart';

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
  NavigationThrottle _throttle = NavigationThrottle();

  /// 初始化绑定 Delegate 和 Registry
  /// 仅供内部或 FastRouterConfig 初始化时调用
  static void bind(
    FastRouterDelegate delegate,
    RouteRegistry registry, {
    int navigationThrottleMs = 0,
  }) {
    _instance._delegate = delegate;
    _instance._registry = registry;
    _instance._throttle = NavigationThrottle(durationMs: navigationThrottleMs);
  }

  /// 节流拦截：窗口期内重复调用直接丢弃。
  bool _runIfAllowed(void Function() action) {
    if (!_throttle.tryAcquire()) return false;
    action();
    return true;
  }

  void _checkInitialized() {
    if (_delegate == null || _registry == null) {
      throw StateError('FastNavigator has not been initialized. Please ensure FastRouterConfig is created first.');
    }
  }

  /// Push 命名路由
  static void pushNamed(
    String name, {
    Map<String, String>? pathParams,
    Map<String, String>? queryParams,
    Object? extra,
    LaunchMode launchMode = LaunchMode.standard,
  }) {
    _instance._checkInitialized();
    _instance._runIfAllowed(() {
      final route = _instance._registry!.findByName(name);
      if (route == null) throw ArgumentError('Route name "$name" not found.');

      var path = route.path;
      pathParams?.forEach((key, value) {
        path = path.replaceAll(':$key', value);
      });

      final uri = Uri(path: path, queryParameters: queryParams);
      _instance._pushImpl(uri.toString(), extra: extra, launchMode: launchMode);
    });
  }

  /// Push URL 路径
  static void push(
    String location, {
    Object? extra,
    LaunchMode launchMode = LaunchMode.standard,
  }) {
    _instance._checkInitialized();
    _instance._runIfAllowed(() {
      _instance._pushImpl(location, extra: extra, launchMode: launchMode);
    });
  }

  void _pushImpl(
    String location, {
    Object? extra,
    LaunchMode launchMode = LaunchMode.standard,
  }) {
    final match = _registry!.matchLocation(
      Uri.parse(location),
      extra: extra,
    );
    final newState = _delegate!.state.push(
      match,
      launchMode: launchMode,
    );
    _delegate!.updateState(newState);
  }

  /// Pop 弹出栈顶
  static void pop() {
    _instance._checkInitialized();
    _instance._runIfAllowed(() {
      final newState = _instance._delegate!.state.pop();
      _instance._delegate!.updateState(newState);
    });
  }

  /// Replace 替换栈顶
  static void replace(String location, {Object? extra}) {
    _instance._checkInitialized();
    _instance._runIfAllowed(() {
      final match = _instance._registry!.matchLocation(Uri.parse(location), extra: extra);
      final newState = _instance._delegate!.state.replace(match);
      _instance._delegate!.updateState(newState);
    });
  }

  /// Go 直接跳转，清空现有栈，完全重置（或压入多级栈）
  static void go(String location, {Object? extra}) {
    _instance._checkInitialized();
    _instance._runIfAllowed(() {
      final match = _instance._registry!.matchLocation(Uri.parse(location), extra: extra);
      final newState = _instance._delegate!.state.go([match]);
      _instance._delegate!.updateState(newState);
    });
  }

  /// PopUntil 弹出直到符合条件
  static void popUntil(bool Function(String routeName) predicate) {
    _instance._checkInitialized();
    _instance._runIfAllowed(() {
      final newState = _instance._delegate!.state.popUntil((match) => predicate(match.route.name));
      _instance._delegate!.updateState(newState);
    });
  }
}
