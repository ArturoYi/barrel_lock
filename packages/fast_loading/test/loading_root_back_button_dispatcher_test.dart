import 'package:fast_loading/fast_loading.dart';
import 'package:fast_loading/src/core/loading_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final controller = LoadingController.instance;
  late LoadingRootBackButtonDispatcher dispatcher;

  setUp(() {
    controller.resetForTest();
    dispatcher = LoadingRootBackButtonDispatcher();
  });

  tearDown(controller.resetForTest);

  group('LoadingRootBackButtonDispatcher', () {
    test('blocks system back when interceptRouteBack is true', () async {
      controller.show(config: const LoadingConfig(interceptRouteBack: true));

      final handled = await dispatcher.invokeCallback(Future<bool>.value(false));

      expect(handled, isTrue);
    });

    test('allows system back when interceptRouteBack is false', () async {
      controller.show(config: const LoadingConfig(interceptRouteBack: false));

      final handled = await dispatcher.invokeCallback(Future<bool>.value(false));

      expect(handled, isFalse);
    });

    test('allows system back when loading is dismissed', () async {
      controller.show(config: const LoadingConfig(interceptRouteBack: true));
      controller.dismiss();

      final handled = await dispatcher.invokeCallback(Future<bool>.value(false));

      expect(handled, isFalse);
    });
  });
}
