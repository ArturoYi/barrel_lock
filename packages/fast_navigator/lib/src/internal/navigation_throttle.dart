/// 导航节流器：首次调用立即执行，窗口期内后续调用全部丢弃。
class NavigationThrottle {
  NavigationThrottle({this.durationMs = 0});

  /// 节流窗口（毫秒）。为 0 时不节流。
  final int durationMs;

  DateTime? _lastExecutedAt;

  bool get isEnabled => durationMs > 0;

  /// 尝试获取执行权。返回 `true` 表示允许执行，`false` 表示被节流拦截。
  bool tryAcquire() {
    if (!isEnabled) return true;

    final now = DateTime.now();
    final last = _lastExecutedAt;
    if (last != null && now.difference(last).inMilliseconds < durationMs) {
      return false;
    }
    _lastExecutedAt = now;
    return true;
  }
}
