import 'package:fast_loading/fast_loading.dart';
import 'package:fast_loading/src/core/loading_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
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

    test('delegates to original dispatcher when loading is hidden', () async {
      var delegateCalled = false;
      final delegate = _RecordingBackButtonDispatcher(
        onInvoke: () => delegateCalled = true,
        result: true,
      );
      dispatcher = LoadingRootBackButtonDispatcher(delegate: delegate);

      final handled = await dispatcher.invokeCallback(Future<bool>.value(false));

      expect(handled, isTrue);
      expect(delegateCalled, isTrue);
    });

    test('blocks before delegating when loading is showing', () async {
      var delegateCalled = false;
      final delegate = _RecordingBackButtonDispatcher(
        onInvoke: () => delegateCalled = true,
        result: false,
      );
      dispatcher = LoadingRootBackButtonDispatcher(delegate: delegate);

      controller.show(config: const LoadingConfig(interceptRouteBack: true));

      final handled = await dispatcher.invokeCallback(Future<bool>.value(false));

      expect(handled, isTrue);
      expect(delegateCalled, isFalse);
    });
  });
}

final class _RecordingBackButtonDispatcher extends RootBackButtonDispatcher {
  _RecordingBackButtonDispatcher({
    required this.onInvoke,
    required this.result,
  });

  final VoidCallback onInvoke;
  final bool result;

  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) {
    onInvoke();
    return SynchronousFuture(result);
  }
}
