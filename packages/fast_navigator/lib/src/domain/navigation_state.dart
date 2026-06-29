import 'package:flutter/foundation.dart';
import 'duplicate_route_exception.dart';
import 'launch_mode.dart';
import 'route_match.dart';

/// 不可变导航状态（NavigationState，SSOT 唯一真相源）。
///
/// 职责：
/// - 持有 `List<RouteMatch> matches`（从底到顶的页面栈）
/// - 提供纯函数式栈操作，均返回新实例：
///   push / pop / replace / go / popUntil / pushAndPopUntil
/// - 暴露 `location` 供 Web URL 回写（通常为栈顶 URI）
///
/// 设计原则：
/// - @immutable，禁止直接 mutate matches 列表
/// - 所有变更必须新 List 拷贝，保证 Page Diff 机制生效
///
/// 状态：已实现（M1）
@immutable
class NavigationState {
  /// 当前路由栈列表（不可变），最底部的在索引 0，栈顶在最后一个。
  final List<RouteMatch> matches;

  const NavigationState({required this.matches});

  /// 获取当前栈顶位置的 URI。如果栈为空，则返回 /
  Uri get location {
    if (matches.isEmpty) return Uri(path: '/');
    return matches.last.uri;
  }

  /// 获取栈顶路由匹配结果
  RouteMatch? get topMatch => matches.isNotEmpty ? matches.last : null;

  /// 判断当前是否为空栈
  bool get isEmpty => matches.isEmpty;

  /// Push 路由入栈。
  ///
  /// [launchMode] 控制相同路由重复入栈时的行为，默认 [LaunchMode.standard]。
  NavigationState push(
    RouteMatch match, {
    LaunchMode launchMode = LaunchMode.standard,
  }) {
    final existingIndex = _findLastIndexByIdentity(match.identity);

    switch (launchMode) {
      case LaunchMode.standard:
        if (existingIndex != -1) {
          throw DuplicateRouteException(
            identity: match.identity,
            index: existingIndex,
          );
        }
        return _append(match);

      case LaunchMode.singleTop:
        if (existingIndex == matches.length - 1) {
          return _replaceMatchAt(existingIndex, match);
        }
        return _append(_ensureUniqueKey(match));

      case LaunchMode.singleTask:
        if (existingIndex != -1) {
          final reused = matches[existingIndex].copyWith(
            parameters: match.parameters,
          );
          final newMatches = [...matches.take(existingIndex), reused];
          return NavigationState(matches: List.unmodifiable(newMatches));
        }
        return _append(match);

      case LaunchMode.multipleTop:
        if (existingIndex != -1) {
          return _append(_withUniqueKey(match));
        }
        return _append(match);
    }
  }

  /// 无条件追加到栈顶（内部 primitive，不处理 LaunchMode 策略）。
  NavigationState _append(RouteMatch match) {
    return NavigationState(matches: List.unmodifiable([...matches, match]));
  }

  int _findLastIndexByIdentity(String identity) {
    for (var i = matches.length - 1; i >= 0; i--) {
      if (matches[i].identity == identity) {
        return i;
      }
    }
    return -1;
  }

  NavigationState _replaceMatchAt(int index, RouteMatch match) {
    final newMatches = List<RouteMatch>.from(matches);
    newMatches[index] = matches[index].copyWith(parameters: match.parameters);
    return NavigationState(matches: List.unmodifiable(newMatches));
  }

  RouteMatch _ensureUniqueKey(RouteMatch match) {
    if (matches.any((m) => m.key == match.key)) {
      return _withUniqueKey(match);
    }
    return match;
  }

  RouteMatch _withUniqueKey(RouteMatch match) {
    return match.copyWith(
      key: RouteMatch.generateKey(
        match.route.name,
        match.path,
        uniqueId: '${matches.length}',
      ),
    );
  }

  /// 弹出栈顶页面（Pop）
  NavigationState pop() {
    if (matches.isEmpty) return this;
    return NavigationState(
      matches: List.unmodifiable(matches.take(matches.length - 1)),
    );
  }

  /// 替换栈顶页面（Replace）
  NavigationState replace(RouteMatch match) {
    if (matches.isEmpty) {
      return NavigationState(matches: List.unmodifiable([match]));
    }
    final newMatches = List<RouteMatch>.from(matches);
    newMatches[newMatches.length - 1] = match;
    return NavigationState(matches: List.unmodifiable(newMatches));
  }

  /// 清空现有栈并压入一系列新页面（Go）
  /// 常用于 BottomNavigationBar 切换或者深度链接打开
  NavigationState go(List<RouteMatch> newMatches) {
    return NavigationState(matches: List.unmodifiable(newMatches));
  }

  /// 持续弹出页面，直到条件满足（PopUntil）
  NavigationState popUntil(bool Function(RouteMatch) predicate) {
    final newMatches = List<RouteMatch>.from(matches);
    while (newMatches.isNotEmpty && !predicate(newMatches.last)) {
      newMatches.removeLast();
    }
    return NavigationState(matches: List.unmodifiable(newMatches));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NavigationState && listEquals(other.matches, matches);
  }

  @override
  int get hashCode => Object.hashAll(matches);

  @override
  String toString() {
    return 'NavigationState(matches: ${matches.map((m) => m.route.name).join(' -> ')})';
  }
}
