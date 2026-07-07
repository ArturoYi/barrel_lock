import 'life_platform_source.dart';
import 'lifecycle_event_extra.dart';

/// 全平台统一生命周期事件实体（架构 SSOT，需求文档 §2.2）。
///
/// ## 字段语义
/// - [source]：事件所属平台，由原生层写入
/// - [rawState]：**核心字段**，系统原生原始字符串，禁止 Dart 适配层翻译
/// - [extra]：窗口 ID、主窗口标记等扩展信息（桌面多窗口溯源）
///
/// ## 载荷示例
/// ```dart
/// RawLifeCycleEvent(
///   source: LifePlatformSource.macos,
///   rawState: 'NSWindowDidBecomeKeyNotification',
///   extra: LifeCycleEventExtra(windowId: 'win-1', isMainWindow: false),
/// )
/// ```
final class RawLifeCycleEvent {
  const RawLifeCycleEvent({
    required this.source,
    required this.rawState,
    this.extra = const LifeCycleEventExtra(),
  });

  final LifePlatformSource source;
  final String rawState;
  final LifeCycleEventExtra extra;

  /// 从 EventChannel Map 载荷解析；[rawState] 原样透传，不做任何映射。
  factory RawLifeCycleEvent.fromPlatformMap(
    Map<dynamic, dynamic> map, {
    required LifePlatformSource source,
  }) {
    final rawState = map['rawState'];
    if (rawState is! String || rawState.isEmpty) {
      throw FormatException(
        'Invalid lifecycle event: rawState must be a non-empty String.',
        map,
      );
    }

    final extraRaw = map['extra'];
    final extra = extraRaw is Map
        ? LifeCycleEventExtra.fromPlatformMap(extraRaw.cast<dynamic, dynamic>())
        : const LifeCycleEventExtra();

    return RawLifeCycleEvent(source: source, rawState: rawState, extra: extra);
  }

  /// 序列化为跨端 Map（调试 / 日志用途）。
  Map<String, Object?> toPlatformMap() {
    return {
      'source': source.name,
      'rawState': rawState,
      'extra': extra.toPlatformMap(),
    };
  }

  @override
  String toString() {
    return 'RawLifeCycleEvent(source: $source, rawState: $rawState, extra: $extra)';
  }
}
