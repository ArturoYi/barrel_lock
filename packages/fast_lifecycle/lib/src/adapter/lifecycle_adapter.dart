import '../domain/life_platform_source.dart';
import 'lifecycle_event_callback.dart';

/// 平台生命周期适配器抽象基类（架构第 ② 层）。
///
/// 所有平台实现必须：
/// 1. [listen]：初始化原生监听，收到事件后通过 [onEvent] **原样**分发
/// 2. [dispose]：销毁监听、释放 EventChannel / 原生订阅
///
/// ## 架构红线（CodeReview 卡点 §7）
/// - **禁止**在 Dart 适配层对 [rawState] 做 if/switch 映射或重命名
/// - 状态翻译仅在各端**系统原生层**完成（如 Android Lifecycle → AppLifecycleState 字符串）
abstract class LifeCycleAdapter {
  /// 当前适配器所属平台（兜底值；精确 source 以 EventChannel 载荷为准）。
  LifePlatformSource get platformSource;

  /// 初始化原生监听，收到事件后通过 [onEvent] 原样分发。
  Future<void> listen(LifeCycleEventCallback onEvent);

  /// 销毁监听，释放 EventChannel / MethodChannel 与原生资源。
  Future<void> dispose();
}
