import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRoutes', () {
    test('simple routes expose name and path', () {
      expect(AppRoutes.home.name, 'home');
      expect(AppRoutes.home.path, '/');
      expect(AppRoutes.settings.path, '/settings');
    });

    test('DetailRoute call builds parameterized path', () {
      expect(AppRoutes.detail.path, '/detail/:id');
      expect(AppRoutes.detail(id: '42'), '/detail/42');
    });
  });

  group('LaunchScreenModel', () {
    test('prepare delegates to injected callback', () async {
      var called = false;
      final container = ProviderContainer(
        overrides: [
          launchScreenPrepareProvider.overrideWith(
            (_) => () async {
              called = true;
            },
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(launchScreenModelProvider).prepare();
      expect(called, isTrue);
    });
  });

  group('AppRouter', () {
    test('routerConfig throws before configure', () {
      expect(() => AppRouter.routerConfig, throwsStateError);
    });
  });
}
