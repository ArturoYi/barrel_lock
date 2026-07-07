import '../adapter/lifecycle_adapter.dart';
import '../internal/lifecycle_init_options.dart';

import 'lifecycle_adapter_factory_stub.dart'
    if (dart.library.io) 'lifecycle_adapter_factory_io.dart'
    if (dart.library.html) 'lifecycle_adapter_factory_web.dart';

/// 按当前运行平台创建对应 [LifeCycleAdapter] 实现。
LifeCycleAdapter createLifecycleAdapter(LifeCycleInitOptions options) {
  return createPlatformLifecycleAdapter(options);
}
