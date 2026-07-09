import 'package:fast_toast/fast_toast.dart';
import 'package:fast_toast/src/core/toast_controller.dart';
import 'package:fast_toast/src/core/toast_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final controller = ToastController.instance;

  setUp(controller.resetForTest);

  tearDown(controller.resetForTest);

  group('ToastController queue', () {
    test('enqueue before attach keeps pending requests', () {
      controller.enqueue(message: 'pending');

      expect(controller.pendingCount, 1);
      expect(controller.isShowing, isFalse);
    });

    test('shows one at a time in FIFO order', () {
      controller.enqueue(message: 'first');
      controller.enqueue(message: 'second');

      expect(controller.pendingCount, 2);
      expect(controller.totalCount, 2);
    });

    test('drop-oldest caps pending at maxPending without overlay', () {
      for (var i = 0; i < ToastQueue.maxPending + 1; i++) {
        controller.enqueue(message: 'msg$i');
      }

      expect(controller.pendingCount, ToastQueue.maxPending);
      expect(controller.totalCount, ToastQueue.maxPending);
    });

    test('high priority prepends without dropping other pending', () {
      controller.enqueue(message: 'first');
      controller.enqueue(message: 'second');
      controller.enqueue(
        message: 'urgent',
        config: const ToastConfig(priority: ToastPriority.high),
      );

      expect(controller.pendingCount, 3);
      expect(controller.current, isNull);
    });

    test('dismissAll clears queue and showing state', () {
      controller.enqueue(message: 'a');
      controller.enqueue(message: 'b');

      controller.dismissAll();

      expect(controller.pendingCount, 0);
      expect(controller.isShowing, isFalse);
      expect(controller.totalCount, 0);
    });

    test('overlayLayerResolver elevates during lock session context', () {
      ToastController.overlayLayerResolver = (_) => ToastOverlayLayer.elevated;

      controller.enqueue(message: 'locked');

      expect(
        controller.pendingRequest?.config.overlayLayer,
        ToastOverlayLayer.elevated,
      );
    });

    test('explicit elevated overlayLayer skips resolver', () {
      ToastController.overlayLayerResolver = (_) => ToastOverlayLayer.elevated;

      controller.enqueue(
        message: 'already-elevated',
        config: const ToastConfig(overlayLayer: ToastOverlayLayer.elevated),
      );

      expect(
        controller.pendingRequest?.config.overlayLayer,
        ToastOverlayLayer.elevated,
      );
    });

    test('dismiss at idle is no-op', () {
      controller.dismiss();
      expect(controller.isShowing, isFalse);
    });
  });

  group('FastToast facade', () {
    test('delegates to controller', () {
      FastToast.success('ok');
      expect(FastToast.pendingCount, 1);

      FastToast.dismissAll();
      expect(FastToast.isShowing, isFalse);
    });
  });
}
