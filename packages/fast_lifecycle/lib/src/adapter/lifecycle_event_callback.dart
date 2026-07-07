import '../domain/raw_lifecycle_event.dart';

/// 全局唯一生命周期事件分发回调。
typedef LifeCycleEventCallback = void Function(RawLifeCycleEvent event);
