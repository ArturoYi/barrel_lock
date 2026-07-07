import '../adapter/lifecycle_adapter.dart';
import '../internal/lifecycle_init_options.dart';
import '../platform/web/web_lifecycle_adapter.dart';

LifeCycleAdapter createPlatformLifecycleAdapter(LifeCycleInitOptions options) {
  return WebLifecycleAdapter(options: options);
}
