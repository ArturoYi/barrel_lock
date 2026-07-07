/// 全平台 Flutter Channel 命名规范（架构 SSOT）。
///
/// | 平台 | EventChannel | MethodChannel |
/// |------|--------------|---------------|
/// | Android / iOS | [eventChannel] | [controlChannel]（启停控制） |
/// | Windows / macOS / Linux | [eventChannelForWindow] | 无 |
/// | Web | 不使用 Channel | 不使用 Channel |
abstract final class LifecycleChannelNames {
  /// 移动端 / 桌面单窗口默认 EventChannel。
  static const String eventChannel = 'fast_lifecycle/events';

  /// 移动端启停监听控制（禁止用于持续推送事件）。
  static const String controlChannel = 'fast_lifecycle/control';

  /// 桌面多窗口：每窗口独立 EventChannel，携带唯一 [windowId]。
  static String eventChannelForWindow(String windowId) {
    return '$eventChannel/$windowId';
  }

  /// MethodChannel 控制指令：启动原生监听。
  static const String methodStartListening = 'startListening';

  /// MethodChannel 控制指令：停止原生监听。
  static const String methodStopListening = 'stopListening';
}
