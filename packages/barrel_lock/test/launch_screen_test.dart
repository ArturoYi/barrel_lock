import 'package:barrel_lock/barrel_lock.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
