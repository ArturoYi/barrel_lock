import '../domain/toast_request.dart';

/// FIFO Toast 请求队列。
final class ToastQueue {
  /// 待展示队列上限（不含当前正在展示的一条）。
  static const int maxPending = 5;

  final List<ToastRequest> _items = <ToastRequest>[];

  int get length => _items.length;

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  ToastRequest? get first => isEmpty ? null : _items.first;

  /// 普通入队；满时丢弃最旧 pending（drop-oldest），再追加新条。
  void enqueue(ToastRequest request) {
    if (_items.length >= maxPending) {
      _items.removeAt(0);
    }
    _items.add(request);
  }

  /// 高优插队到队首；超出 [maxPending] 时从队尾裁剪。
  void enqueueFront(ToastRequest request) {
    _items.insert(0, request);
    while (_items.length > maxPending) {
      _items.removeLast();
    }
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
