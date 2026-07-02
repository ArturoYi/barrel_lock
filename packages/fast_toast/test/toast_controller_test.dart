import 'package:fast_toast/fast_toast.dart';
import 'package:fast_toast/src/core/toast_controller.dart';
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

    test('dismissAll clears queue and showing state', () {
      controller.enqueue(message: 'a');
      controller.enqueue(message: 'b');

      controller.dismissAll();

      expect(controller.pendingCount, 0);
      expect(controller.isShowing, isFalse);
      expect(controller.totalCount, 0);
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
