import 'package:flutter/foundation.dart';

import '../adapter/lifecycle_adapter.dart';
import '../adapter/lifecycle_event_callback.dart';
import '../domain/raw_lifecycle_event.dart';
import '../factory/lifecycle_adapter_factory.dart';
import '../internal/lifecycle_init_options.dart';

/// 业务门面层：全局单例生命周期管理器（架构第 ① 层）。
///
/// ## 职责边界
/// - 统一注册 / 移除 [LifeCycleEventCallback]
/// - 初始化 / 销毁底层 [LifeCycleAdapter]
/// - 将 [RawLifeCycleEvent] 分发给所有监听者
///
/// ## 禁止事项（架构红线）
/// - 禁止在此类做平台 if/switch 判断
/// - 禁止将 [RawLifeCycleEvent.rawState] 映射为统一枚举
/// - 禁止封装业务差异化逻辑（完全放权上层 §6）
///
/// ## 多窗口（macOS / Windows）
/// 每个 Flutter Engine 独立调用 [initialize]，传入唯一 [LifeCycleInitOptions.windowId]。
/// App 级全局事件（如 NSApplicationDidHideNotification）可能被多个 Engine 重复推送，
/// 业务层需按 `rawState + windowId` 自行去重（需求文档 §5.3）。
final class RawLifeCycleManager {
  RawLifeCycleManager._();

  static final RawLifeCycleManager instance = RawLifeCycleManager._();

  /// 单测注入适配器工厂；生产环境保持 null，走 [createLifecycleAdapter]。
  @visibleForTesting
  static LifeCycleAdapter Function(LifeCycleInitOptions options)?
  adapterFactoryOverride;

  LifeCycleAdapter? _adapter;
  final List<LifeCycleEventCallback> _listeners = [];
  bool _initialized = false;

  /// 底层原生监听是否已启动。
  bool get isInitialized => _initialized;

  /// 当前注册的 Dart 侧监听者数量。
  int get listenerCount => _listeners.length;

  /// 注册生命周期事件监听；同一回调不会重复添加。
  void addListener(LifeCycleEventCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  /// 移除已注册监听者。
  void removeListener(LifeCycleEventCallback listener) {
    _listeners.remove(listener);
  }

  /// 初始化底层平台适配器并开始监听。
  ///
  /// 桌面多窗口：每个 Engine 在启动时调用一次，传入唯一 [options.windowId]。
  /// 重复调用会被忽略（幂等）。
  Future<void> initialize({
    LifeCycleInitOptions options = const LifeCycleInitOptions(),
  }) async {
    if (_initialized) {
      return;
    }

    final factory = adapterFactoryOverride ?? createLifecycleAdapter;
    _adapter = factory(options);
    await _adapter!.listen(_dispatch);
    _initialized = true;
  }

  /// 销毁底层监听；不会自动 [removeListener]。
  Future<void> dispose() async {
    await _adapter?.dispose();
    _adapter = null;
    _initialized = false;
  }

  /// 重置单例（仅供单测）。
  @visibleForTesting
  void resetForTesting() {
    _adapter = null;
    _listeners.clear();
    _initialized = false;
    adapterFactoryOverride = null;
  }

  /// 向所有监听者分发事件；使用快照避免回调中修改列表。
  void _dispatch(RawLifeCycleEvent event) {
    if (_listeners.isEmpty) {
      return;
    }

    for (final listener in List<LifeCycleEventCallback>.of(_listeners)) {
      listener(event);
    }
  }
}
