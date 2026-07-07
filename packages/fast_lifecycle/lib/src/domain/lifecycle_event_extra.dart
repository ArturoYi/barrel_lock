/// 生命周期事件扩展参数（窗口标识、主窗口标记、作用域等）。
///
/// 桌面多窗口场景下 [windowId] 用于事件溯源；[lifecycleScope] 区分同平台不同层级
///（如 Android `process` / `activity`，iOS `application`，macOS `window` / `application`）。
final class LifeCycleEventExtra {
  const LifeCycleEventExtra({
    this.windowId,
    this.isMainWindow,
    this.lifecycleScope,
    this.metadata = const {},
  });

  final String? windowId;
  final bool? isMainWindow;

  /// 生命周期作用域：`process` / `activity` / `application` / `window` 等。
  final String? lifecycleScope;
  final Map<String, Object?> metadata;

  /// 从原生 EventChannel 载荷解析；字段缺失时保持 null / 空 map。
  factory LifeCycleEventExtra.fromPlatformMap(Map<dynamic, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return const LifeCycleEventExtra();
    }

    final metadataRaw = map['metadata'];
    final metadata = metadataRaw is Map
        ? Map<String, Object?>.from(metadataRaw.cast<String, Object?>())
        : const <String, Object?>{};

    return LifeCycleEventExtra(
      windowId: map['windowId'] as String?,
      isMainWindow: map['isMainWindow'] as bool?,
      lifecycleScope: map['lifecycleScope'] as String?,
      metadata: metadata,
    );
  }

  Map<String, Object?> toPlatformMap() {
    return {
      if (windowId != null) 'windowId': windowId,
      if (isMainWindow != null) 'isMainWindow': isMainWindow,
      if (lifecycleScope != null) 'lifecycleScope': lifecycleScope,
      if (metadata.isNotEmpty) 'metadata': metadata,
    };
  }

  LifeCycleEventExtra copyWith({
    String? windowId,
    bool? isMainWindow,
    String? lifecycleScope,
    Map<String, Object?>? metadata,
  }) {
    return LifeCycleEventExtra(
      windowId: windowId ?? this.windowId,
      isMainWindow: isMainWindow ?? this.isMainWindow,
      lifecycleScope: lifecycleScope ?? this.lifecycleScope,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'LifeCycleEventExtra('
        'windowId: $windowId, '
        'isMainWindow: $isMainWindow, '
        'lifecycleScope: $lifecycleScope, '
        'metadata: $metadata)';
  }
}
