import '../../adapter/lifecycle_adapter.dart';
import '../../domain/life_platform_source.dart';
import '../../internal/lifecycle_init_options.dart';

/// 无原生能力的占位适配器（测试 / 未知平台）。
final class NoopLifeCycleAdapter implements LifeCycleAdapter {
  NoopLifeCycleAdapter({required this.options});

  final LifeCycleInitOptions options;

  @override
  LifePlatformSource get platformSource => LifePlatformSource.linux;

  @override
  Future<void> listen(_) async {}

  @override
  Future<void> dispose() async {}
}
