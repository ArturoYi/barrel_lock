import 'package:fast_toast/src/core/toast_queue.dart';
import 'package:fast_toast/src/domain/toast_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ToastQueue', () {
    late ToastQueue queue;

    setUp(() {
      queue = ToastQueue();
    });

    test('enqueue and dequeue follow FIFO', () {
      queue.enqueue(const ToastRequest(message: 'first'));
      queue.enqueue(const ToastRequest(message: 'second'));

      expect(queue.length, 2);
      expect(queue.dequeue()?.message, 'first');
      expect(queue.dequeue()?.message, 'second');
      expect(queue.dequeue(), isNull);
      expect(queue.isEmpty, isTrue);
    });

    test('first returns head without removing', () {
      queue.enqueue(const ToastRequest(message: 'only'));

      expect(queue.first?.message, 'only');
      expect(queue.length, 1);
    });

    test('clear removes all pending items', () {
      queue.enqueue(const ToastRequest(message: 'a'));
      queue.enqueue(const ToastRequest(message: 'b'));

      queue.clear();

      expect(queue.isEmpty, isTrue);
      expect(queue.dequeue(), isNull);
    });
  });
}
