import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import '../../adapter/lifecycle_adapter.dart';
import '../../adapter/lifecycle_event_callback.dart';
import '../../channels/lifecycle_channel_names.dart';
import '../../domain/life_platform_source.dart';
import '../../domain/raw_lifecycle_event.dart';
import '../../internal/lifecycle_init_options.dart';

/// macOS / Linux 桌面平台实现层适配器。
///
/// ## 多窗口隔离策略
/// Flutter 官方多窗口模型为 **一窗口一 Engine 一原生窗口**。
/// 每个 Engine 拥有独立插件实例与独立 [EventChannel] 连接，因此：
/// - 物理通道统一使用 [LifecycleChannelNames.eventChannel]
/// - 逻辑窗口标识通过 `receiveBroadcastStream` 入参及事件 `extra.windowId` 透传
///
/// 若业务强制要求通道名携带 windowId，可使用
/// [LifecycleChannelNames.eventChannelForWindow]，
/// 但原生层需在对应 Engine 启动时注册同名通道（当前架构以 Engine 隔离为主）。
///
/// ## 桌面 rawState 规范
/// - Linux：`window_minimize` / `window_restore` / `window_focus` /
///   `window_blur` / `window_close`
/// - macOS：NSWindow / NSApplication 系统通知名（见需求文档 §4.4）
/// - Windows：TODO，待原生插件实现
final class DesktopLifecycleAdapter implements LifeCycleAdapter {
  DesktopLifecycleAdapter({required this.options, EventChannel? eventChannel})
    : _eventChannel =
          eventChannel ?? EventChannel(_resolveChannelName(options));

  final LifeCycleInitOptions options;
  final EventChannel _eventChannel;

  StreamSubscription<dynamic>? _subscription;
  LifeCycleEventCallback? _onEvent;

  @override
  LifePlatformSource get platformSource {
    if (Platform.isLinux) {
      return LifePlatformSource.linux;
    }
    return LifePlatformSource.macos;
  }

  /// 解析 EventChannel 名称。
  ///
  /// Flutter 多窗口为 **一 Engine 一通道连接**，物理层统一使用基础通道名；
  /// 逻辑 [windowId] 通过 stream 入参及事件 extra 透传（需求文档 §5.1）。
  static String _resolveChannelName(LifeCycleInitOptions options) {
    return LifecycleChannelNames.eventChannel;
  }

  @override
  Future<void> listen(LifeCycleEventCallback onEvent) async {
    _onEvent = onEvent;

    // 将 windowId / isMainWindow 传给原生 onListen，用于注册窗口级监听。
    _subscription = _eventChannel
        .receiveBroadcastStream({
          'windowId': options.windowId,
          'isMainWindow': options.isMainWindow,
        })
        .listen(
          _handlePlatformEvent,
          onError: (_) {
            // 桌面端原生订阅异常不应导致 Dart 侧崩溃。
          },
        );
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _onEvent = null;
  }

  /// 原样透传原生 Map 载荷，禁止在本层修改 [rawState]。
  void _handlePlatformEvent(dynamic payload) {
    if (payload is! Map) {
      return;
    }

    final sourceRaw = payload['source'];
    final source = sourceRaw is String
        ? LifePlatformSource.values.byName(sourceRaw)
        : platformSource;

    final event = RawLifeCycleEvent.fromPlatformMap(
      payload.cast<dynamic, dynamic>(),
      source: source,
    );

    _onEvent?.call(event);
  }
}
