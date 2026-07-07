import '../../adapter/lifecycle_event_callback.dart';
import '../../internal/lifecycle_init_options.dart';

/// Web 监听占位实现（非浏览器环境 / 单测）。
final class WebLifecycleListener {
  WebLifecycleListener({required this.options});

  final LifeCycleInitOptions options;

  Future<void> attach(LifeCycleEventCallback onEvent) async {}

  Future<void> detach() async {}
}
