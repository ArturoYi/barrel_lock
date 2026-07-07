import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import '../../adapter/lifecycle_adapter.dart';
import '../../adapter/lifecycle_event_callback.dart';
import '../../channels/lifecycle_channel_names.dart';
import '../../domain/life_platform_source.dart';
import '../../domain/raw_lifecycle_event.dart';
import '../../internal/lifecycle_init_options.dart';

/// Android / iOS 平台实现层适配器。
///
/// ## 通道分工（架构强制）
/// - [EventChannel]：唯一的事件推送通道，持续流式透传原生 `rawState`
/// - [MethodChannel]：仅承载 `startListening` / `stopListening` 控制指令
///
/// ## 架构红线
/// - 禁止在本类对 [RawLifeCycleEvent.rawState] 做 if/switch 映射或重命名
/// - 禁止用 MethodChannel 推送持续生命周期事件
/// - 移动端 rawState 由原生层直接输出平台原生标识：
///   iOS → UIApplicationDelegate 方法名；Android → `ON_*` + `lifecycleScope`
final class MobileLifecycleAdapter implements LifeCycleAdapter {
  MobileLifecycleAdapter({
    required this.options,
    EventChannel? eventChannel,
    MethodChannel? controlChannel,
  }) : _eventChannel =
           eventChannel ??
           const EventChannel(LifecycleChannelNames.eventChannel),
       _controlChannel =
           controlChannel ??
           const MethodChannel(LifecycleChannelNames.controlChannel);

  final LifeCycleInitOptions options;
  final EventChannel _eventChannel;
  final MethodChannel _controlChannel;

  StreamSubscription<dynamic>? _subscription;
  LifeCycleEventCallback? _onEvent;

  @override
  LifePlatformSource get platformSource {
    if (Platform.isIOS) {
      return LifePlatformSource.ios;
    }
    return LifePlatformSource.android;
  }

  @override
  Future<void> listen(LifeCycleEventCallback onEvent) async {
    _onEvent = onEvent;

    // 先通知原生注册系统监听，再订阅 EventChannel，避免丢失初始状态。
    await _controlChannel.invokeMethod<void>(
      LifecycleChannelNames.methodStartListening,
      _buildControlArguments(),
    );

    _subscription = _eventChannel.receiveBroadcastStream().listen(
      _handlePlatformEvent,
      onError: (_) {
        // 原生层异常不应中断 Dart 侧订阅；具体错误由原生日志定位。
      },
    );
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _onEvent = null;

    await _controlChannel.invokeMethod<void>(
      LifecycleChannelNames.methodStopListening,
    );
  }

  /// MethodChannel 启停参数：移动端通常无多窗口，仍透传以备扩展。
  Map<String, Object?>? _buildControlArguments() {
    if (options.windowId == null) {
      return null;
    }
    return {'windowId': options.windowId, 'isMainWindow': options.isMainWindow};
  }

  /// 解析 EventChannel 载荷并原样回调；不做任何状态翻译。
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
