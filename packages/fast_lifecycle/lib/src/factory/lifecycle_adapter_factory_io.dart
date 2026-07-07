import 'dart:io' show Platform;

import '../adapter/lifecycle_adapter.dart';
import '../internal/lifecycle_init_options.dart';
import '../platform/desktop/desktop_lifecycle_adapter.dart';
import '../platform/mobile/mobile_lifecycle_adapter.dart';
import '../platform/noop/noop_lifecycle_adapter.dart';

LifeCycleAdapter createPlatformLifecycleAdapter(LifeCycleInitOptions options) {
  if (Platform.isAndroid || Platform.isIOS) {
    return MobileLifecycleAdapter(options: options);
  }

  if (Platform.isWindows) {
    // TODO: Windows 原生插件待单独实现，当前回退 noop 避免编译/链接错误。
    return NoopLifeCycleAdapter(options: options);
  }

  if (Platform.isMacOS || Platform.isLinux) {
    return DesktopLifecycleAdapter(options: options);
  }

  return NoopLifeCycleAdapter(options: options);
}
