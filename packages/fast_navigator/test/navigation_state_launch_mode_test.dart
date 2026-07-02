import 'package:fast_navigator/fast_navigator.dart';
import 'package:fast_navigator/src/domain/state/navigation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

RouteMatch _match({
  required String name,
  required String path,
  Map<String, String>? queryParams,
  Object? extra,
  String? uniqueId,
}) {
  final route = FastRoute(
    name: name,
    path: path.contains(':') ? path.replaceAll(RegExp(r'/\d+'), '/:id') : path,
    builder: (_, _) => const SizedBox.shrink(),
  );
  return RouteMatch(
    route: route,
    path: path,
    parameters: RouteParameters(
      queryParams: queryParams ?? const {},
      extra: extra,
    ),
    key: RouteMatch.generateKey(name, path, uniqueId: uniqueId),
  );
}

void main() {
  group('NavigationState.push', () {
    test('standard: push when route not in stack', () {
      const state = NavigationState(matches: []);
      final detail = _match(name: 'detail', path: '/detail');

      final result = state.push(detail);

      expect(result.matches, [detail]);
      expect(result, isNot(state));
    });

    test('standard: throws when route already in stack', () {
      final detail = _match(name: 'detail', path: '/detail');
      final state = NavigationState(matches: [detail]);

      expect(() => state.push(detail), throwsA(isA<DuplicateRouteException>()));
    });

    test('singleTop: updates params when target is stack top', () {
      final detail = _match(name: 'detail', path: '/detail');
      final state = NavigationState(matches: [detail]);
      final updated = _match(
        name: 'detail',
        path: '/detail',
        queryParams: {'tab': 'info'},
      );

      final result = state.push(updated, launchMode: LaunchMode.singleTop);

      expect(result.matches.length, 1);
      expect(result.matches.last.key, detail.key);
      expect(result.matches.last.parameters.queryParams, {'tab': 'info'});
    });

    test('singleTop: pushes with unique key when target exists below top', () {
      final home = _match(name: 'home', path: '/');
      final detail = _match(name: 'detail', path: '/detail');
      final settings = _match(name: 'settings', path: '/settings');
      final state = NavigationState(matches: [home, detail, settings]);

      final result = state.push(detail, launchMode: LaunchMode.singleTop);

      expect(result.matches.length, 4);
      expect(result.matches[1].key, detail.key);
      expect(result.matches.last.key, '${detail.key}[3]');
    });

    test('singleTask: pops upper pages and reuses existing route', () {
      final home = _match(name: 'home', path: '/');
      final detail = _match(name: 'detail', path: '/detail');
      final settings = _match(name: 'settings', path: '/settings');
      final state = NavigationState(matches: [home, detail, settings]);
      final updated = _match(
        name: 'detail',
        path: '/detail',
        queryParams: {'tab': 'info'},
      );

      final result = state.push(updated, launchMode: LaunchMode.singleTask);

      expect(result.matches.length, 2);
      expect(result.matches.last.route.name, 'detail');
      expect(result.matches.last.key, detail.key);
      expect(result.matches.last.parameters.queryParams, {'tab': 'info'});
    });

    test('singleTask: normal push when route not in stack', () {
      final home = _match(name: 'home', path: '/');
      final state = NavigationState(matches: [home]);
      final detail = _match(name: 'detail', path: '/detail');

      final result = state.push(detail, launchMode: LaunchMode.singleTask);

      expect(result.matches, [home, detail]);
    });

    test('multipleTop: pushes new instance with unique key', () {
      final detail = _match(name: 'detail', path: '/detail');
      final state = NavigationState(matches: [detail]);

      final result = state.push(detail, launchMode: LaunchMode.multipleTop);

      expect(result.matches.length, 2);
      expect(result.matches.first.key, detail.key);
      expect(result.matches.last.key, '${detail.key}[1]');
    });

    test('multipleTop: normal push when route not in stack', () {
      const state = NavigationState(matches: []);
      final detail = _match(name: 'detail', path: '/detail');

      final result = state.push(detail, launchMode: LaunchMode.multipleTop);

      expect(result.matches, [detail]);
    });
  });
}
