import '../domain/toast_request.dart';

/// FIFO Toast 请求队列。
final class ToastQueue {
  final List<ToastRequest> _items = <ToastRequest>[];

  int get length => _items.length;

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  ToastRequest? get first => isEmpty ? null : _items.first;

  void enqueue(ToastRequest request) {
    _items.add(request);
  }

  ToastRequest? dequeue() {
    if (_items.isEmpty) {
      return null;
    }
    return _items.removeAt(0);
  }

  void clear() {
    _items.clear();
  }
}
