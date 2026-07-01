import 'package:flutter/widgets.dart';
import '../domain/state/navigation_state.dart';
import '../page/page_factory.dart';

/// Navigator 2.0 页面栈管理者（RouterDelegate，核心中的核心）。
///
/// 职责：
/// - 持有唯一可变源 [NavigationState]（通过不可变替换更新）
/// - `build()` 通过 [PageFactory] 将 `matches` 映射为 `List<Page>` 驱动 [Navigator]
/// - 实现 `popRoute()` 兼容系统返回（物理键 / 手势 / Web 后退）
/// - 混入 [PopNavigatorRouterDelegateMixin] 绑定 navigatorKey
/// - 提供 `setNewRoutePath` 接收 Parser 传入的新状态
///
/// 状态：已实现（M1 + M2 过渡）
class FastRouterDelegate extends RouterDelegate<NavigationState>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<NavigationState> {
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  NavigationState _state;
  final PageFactory _pageFactory;

  FastRouterDelegate({
    NavigationState? initialState,
    GlobalKey<NavigatorState>? navigatorKey,
    this._pageFactory = const PageFactory(),
  })  : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
        _state = initialState ?? const NavigationState(matches: []);

  /// 获取当前导航状态的不可变拷贝
  NavigationState get state => _state;

  @override
  NavigationState? get currentConfiguration => _state;

  /// 更新栈状态并通知重建
  void updateState(NavigationState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  /// 响应操作系统的 pop 请求（物理返回键、Web 浏览器后退）
  @override
  Future<bool> popRoute() async {
    if (_state.matches.length > 1) {
      updateState(_state.pop());
      return true;
    }
    return false; // 交给系统处理（如退出应用）
  }

  /// 处理从 Parser 解析而来的新路由请求（例如地址栏输入或 Deep Link）
  @override
  Future<void> setNewRoutePath(NavigationState configuration) async {
    updateState(configuration);
  }

  /// AppBar 的返回按钮或者系统手势返回时触发
  void _onDidRemovePage(Page<Object?> page) {
    final removedKey = _pageKeyOf(page);
    if (removedKey != null) {
      var removed = false;
      final newMatches = _state.matches.where((m) {
        if (!removed && m.key == removedKey) {
          removed = true;
          return false;
        }
        return true;
      }).toList();
      updateState(NavigationState(matches: List.unmodifiable(newMatches)));
    } else if (_state.matches.isNotEmpty) {
      updateState(_state.pop());
    }
  }

  /// 从 Page.key 提取 match.key（所有 Page 经 [PageFactory] 统一设置 ValueKey）。
  String? _pageKeyOf(Page<Object?> page) {
    final key = page.key;
    if (key is ValueKey<String>) {
      return key.value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (_state.isEmpty) {
      return const SizedBox.shrink(); // 或全局加载页
    }

    final pages = _state.matches
        .map((match) => _pageFactory.build(context: context, match: match))
        .toList();

    return Navigator(
      key: navigatorKey,
      pages: pages,
      onDidRemovePage: _onDidRemovePage,
    );
  }
}
