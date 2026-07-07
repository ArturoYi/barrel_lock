import '../adapter/lifecycle_adapter.dart';
import '../internal/lifecycle_init_options.dart';
import '../platform/noop/noop_lifecycle_adapter.dart';

LifeCycleAdapter createPlatformLifecycleAdapter(LifeCycleInitOptions options) {
  return NoopLifeCycleAdapter(options: options);
}
