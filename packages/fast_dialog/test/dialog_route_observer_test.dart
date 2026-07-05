import 'package:fast_dialog/src/api/dialog_route_guard.dart';
import 'package:fast_dialog/src/core/dialog_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final manager = DialogManager.instance;

  setUp(manager.resetForTest);
  tearDown(manager.resetForTest);

  MaterialPageRoute<void> route(String name) {
    return MaterialPageRoute<void>(
      settings: RouteSettings(name: name),
      builder: (_) => const SizedBox(),
    );
  }

  group('DialogRouteObserver', () {
    test('didPush invokes onRoutePushed with route name', () {
      Object? pushed;
      final observer = DialogRouteObserver(onRoutePushed: (id) => pushed = id);

      observer.didPush(route('home'), null);
      expect(pushed, 'home');
    });

    test('didPop invokes onRouteRemoved and rebinds previous route', () {
      Object? removed;
      Object? pushed;
      final observer = DialogRouteObserver(
        onRoutePushed: (id) => pushed = id,
        onRouteRemoved: (id) => removed = id,
      );

      final home = route('home');
      final detail = route('detail');

      observer.didPush(home, null);
      observer.didPush(detail, home);
      observer.didPop(detail, home);

      expect(removed, 'detail');
      expect(pushed, 'home');
    });

    test('forManager dismisses dialogs bound to popped route', () {
      final observer = DialogRouteObserver.forManager(manager);

      observer.didPush(route('home'), null);
      manager.bindRoute('home');
      manager.show(builder: (_) => const SizedBox());
      manager.show(builder: (_) => const SizedBox());
      expect(manager.stack.length, 2);

      observer.didPop(route('home'), null);
      expect(manager.stack, isEmpty);
    });

    test('routeIdentityOf prefers RouteSettings.name', () {
      final r = route('settings');
      expect(DialogRouteObserver.routeIdentityOf(r), 'settings');
    });
  });
}
