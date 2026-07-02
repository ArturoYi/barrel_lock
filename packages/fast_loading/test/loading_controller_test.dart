import 'package:fast_loading/fast_loading.dart';
import 'package:fast_loading/src/core/loading_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final controller = LoadingController.instance;

  setUp(controller.resetForTest);

  tearDown(controller.resetForTest);

  group('LoadingController ref count', () {
    test('show increases refCount and isShowing', () {
      controller.show();
      expect(controller.refCount, 1);
      expect(controller.isShowing, isTrue);
    });

    test('multiple show only increments refCount', () {
      controller.show();
      controller.show();
      controller.show();

      expect(controller.refCount, 3);
      expect(controller.isShowing, isTrue);
    });

    test('dismiss decrements refCount and hides at zero', () {
      controller.show();
      controller.show();

      controller.dismiss();
      expect(controller.refCount, 1);
      expect(controller.isShowing, isTrue);

      controller.dismiss();
      expect(controller.refCount, 0);
      expect(controller.isShowing, isFalse);
    });

    test('dismiss at zero is no-op', () {
      controller.dismiss();
      expect(controller.refCount, 0);
      expect(controller.isShowing, isFalse);
    });

    test('dismissAll resets refCount immediately', () {
      controller.show();
      controller.show();
      controller.show();

      controller.dismissAll();

      expect(controller.refCount, 0);
      expect(controller.isShowing, isFalse);
    });

    test('show before attach keeps pending refCount', () {
      controller.show(config: const LoadingConfig(message: 'pending'));
      expect(controller.refCount, 1);
      expect(controller.config.message, 'pending');
    });

    test('run dismisses even when task throws', () async {
      await expectLater(
        controller.run(() async {
          throw StateError('boom');
        }),
        throwsStateError,
      );

      expect(controller.refCount, 0);
      expect(controller.isShowing, isFalse);
    });

    test(
      'dismiss with success without custom widget shows built-in result',
      () async {
        controller.show(config: const LoadingConfig(message: 'loading'));

        controller.dismiss(result: LoadingDismissResult.success);

        expect(controller.refCount, 0);
        expect(controller.isShowing, isTrue);
        expect(controller.displayPhase, LoadingDisplayPhase.success);
        expect(controller.resultWidget, isNull);

        await Future<void>.delayed(const Duration(seconds: 1));

        expect(controller.isShowing, isFalse);
        expect(controller.displayPhase, LoadingDisplayPhase.loading);
      },
    );

    test('dismiss with success and widget keeps showing until timer', () async {
      controller.show(
        config: LoadingConfig(
          style: LoadingStyle(successWidget: const Icon(Icons.check)),
        ),
      );

      controller.dismiss(result: LoadingDismissResult.success);

      expect(controller.refCount, 0);
      expect(controller.isShowing, isTrue);
      expect(controller.displayPhase, LoadingDisplayPhase.success);

      await Future<void>.delayed(const Duration(seconds: 1));

      expect(controller.isShowing, isFalse);
      expect(controller.displayPhase, LoadingDisplayPhase.loading);
    });

    test('dismiss resultMessage is stored for result phase', () {
      controller.show();

      controller.dismiss(result: LoadingDismissResult.success, message: '完成');

      expect(controller.resultMessage, '完成');
    });

    test('dismiss during result phase closes immediately', () {
      controller.show();

      controller.dismiss(result: LoadingDismissResult.success);

      expect(controller.isShowing, isTrue);
      expect(controller.displayPhase, LoadingDisplayPhase.success);

      controller.dismiss();

      expect(controller.isShowing, isFalse);
      expect(controller.displayPhase, LoadingDisplayPhase.loading);
    });

    test('detach cancels result phase when refCount is zero', () {
      controller.show();
      controller.dismiss(result: LoadingDismissResult.success);

      expect(controller.isShowing, isTrue);

      controller.detach();

      expect(controller.isShowing, isFalse);
      expect(controller.displayPhase, LoadingDisplayPhase.loading);
    });

    test('dismiss resultWidget overrides style widget', () {
      controller.show(
        config: const LoadingConfig(
          style: LoadingStyle(successWidget: Text('style')),
        ),
      );

      controller.dismiss(
        result: LoadingDismissResult.success,
        resultWidget: const Text('override'),
      );

      expect(controller.resultWidget, isA<Text>());
    });

    test('run returns task result', () async {
      final result = await controller.run(() async => 42);
      expect(result, 42);
      expect(controller.isShowing, isFalse);
    });
  });

  group('FastLoading facade', () {
    test('delegates to controller', () {
      FastLoading.show(message: 'hello');
      expect(FastLoading.refCount, 1);
      expect(FastLoading.isShowing, isTrue);

      FastLoading.dismiss();
      expect(FastLoading.isShowing, isFalse);
    });
  });
}
