import '../life_platform_source.dart';
import '../raw_lifecycle_event.dart';

/// 平台差异版：最近一次原生生命周期快照。
final class PlatformLifecycleSnapshot {
  const PlatformLifecycleSnapshot({
    this.platform,
    this.rawState,
    this.lifecycleScope,
    this.lastEvent,
    this.updatedAt,
  });

  static const empty = PlatformLifecycleSnapshot();

  final LifePlatformSource? platform;
  final String? rawState;
  final String? lifecycleScope;
  final RawLifeCycleEvent? lastEvent;
  final DateTime? updatedAt;

  bool get hasState => rawState != null;

  factory PlatformLifecycleSnapshot.from(RawLifeCycleEvent event) {
    return PlatformLifecycleSnapshot(
      platform: event.source,
      rawState: event.rawState,
      lifecycleScope: event.extra.lifecycleScope,
      lastEvent: event,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'PlatformLifecycleSnapshot('
        'platform: $platform, '
        'rawState: $rawState, '
        'lifecycleScope: $lifecycleScope)';
  }
}
