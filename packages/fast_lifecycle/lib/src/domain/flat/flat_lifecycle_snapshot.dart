import 'flat_lifecycle_phase.dart';
import '../raw_lifecycle_event.dart';

/// 抹平版：最近一次跨平台生命周期快照。
final class FlatLifecycleSnapshot {
  const FlatLifecycleSnapshot({
    this.phase = FlatLifecyclePhase.unknown,
    this.lastEvent,
    this.updatedAt,
  });

  static const empty = FlatLifecycleSnapshot();

  final FlatLifecyclePhase phase;
  final RawLifeCycleEvent? lastEvent;
  final DateTime? updatedAt;

  bool get hasState => phase != FlatLifecyclePhase.unknown;

  FlatLifecycleSnapshot copyWith({
    FlatLifecyclePhase? phase,
    RawLifeCycleEvent? lastEvent,
    DateTime? updatedAt,
  }) {
    return FlatLifecycleSnapshot(
      phase: phase ?? this.phase,
      lastEvent: lastEvent ?? this.lastEvent,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'FlatLifecycleSnapshot(phase: $phase)';
}
