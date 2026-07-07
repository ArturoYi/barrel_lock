import '../../adapter/lifecycle_adapter.dart';
import '../../adapter/lifecycle_event_callback.dart';
import '../../domain/life_platform_source.dart';
import '../../internal/lifecycle_init_options.dart';

import 'web_lifecycle_listener_stub.dart'
    if (dart.library.html) 'web_lifecycle_listener_html.dart';

/// Web 生命周期适配器（纯 Dart，无 Flutter Channel）。
final class WebLifecycleAdapter implements LifeCycleAdapter {
  WebLifecycleAdapter({required this.options});

  final LifeCycleInitOptions options;
  WebLifecycleListener? _listener;

  @override
  LifePlatformSource get platformSource => LifePlatformSource.web;

  @override
  Future<void> listen(LifeCycleEventCallback onEvent) async {
    _listener = WebLifecycleListener(options: options);
    await _listener!.attach(onEvent);
  }

  @override
  Future<void> dispose() async {
    await _listener?.detach();
    _listener = null;
  }
}
