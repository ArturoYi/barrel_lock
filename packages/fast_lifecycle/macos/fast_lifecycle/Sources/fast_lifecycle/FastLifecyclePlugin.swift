import Cocoa
import FlutterMacOS

// MARK: - 跨端载荷构造

/// EventChannel 标准载荷；[rawState] 必须为 NSNotification 名原字符串。
private enum LifecycleEventPayload {
  static func build(
    rawState: String,
    source: String = "macos",
    lifecycleScope: String,
    windowId: String?,
    isMainWindow: Bool
  ) -> [String: Any] {
    var extra: [String: Any] = [
      "lifecycleScope": lifecycleScope,
      "isMainWindow": isMainWindow,
    ]
    if let windowId {
      extra["windowId"] = windowId
    }
    return [
      "source": source,
      "rawState": rawState,
      "extra": extra,
    ]
  }
}

// MARK: - NSWindow / NSApplication 监听

/// macOS 原生窗口 / App 生命周期采集器。
///
/// ## rawState 规范（需求文档 §4.4，禁止重命名）
/// **单窗口事件**（绑定 [targetWindow]）：
/// - NSWindowDidBecomeKeyNotification
/// - NSWindowDidResignKeyNotification
/// - NSWindowDidMiniaturizeNotification
/// - NSWindowDidDeminiaturizeNotification
/// - NSWindowWillCloseNotification
///
/// **App 全局事件**（object = nil，所有 Engine 均会收到，业务层需去重 §5.3）：
/// - NSApplicationDidHideNotification
/// - NSApplicationDidUnhideNotification
private final class MacOSLifecycleTracker {
  private var observers: [NSObjectProtocol] = []
  private let onEvent: ([String: Any]) -> Void
  private let windowId: String?
  private let isMainWindow: Bool
  private weak var targetWindow: NSWindow?
  private let windowLifecycleScope = "window"
  private let applicationLifecycleScope = "application"

  init(
    onEvent: @escaping ([String: Any]) -> Void,
    windowId: String?,
    isMainWindow: Bool,
    targetWindow: NSWindow?
  ) {
    self.onEvent = onEvent
    self.windowId = windowId
    self.isMainWindow = isMainWindow
    self.targetWindow = targetWindow
  }

  func start() {
    guard observers.isEmpty else { return }
    let center = NotificationCenter.default

    // 单窗口级通知：rawState = notification.name.rawValue（系统原名）
    let windowNotificationNames: [Notification.Name] = [
      NSWindow.didBecomeKeyNotification,
      NSWindow.didResignKeyNotification,
      NSWindow.didMiniaturizeNotification,
      NSWindow.didDeminiaturizeNotification,
      NSWindow.willCloseNotification,
    ]

    for name in windowNotificationNames {
      let token = center.addObserver(
        forName: name,
        object: targetWindow,
        queue: .main
      ) { [weak self] notification in
        self?.emit(
          notificationName: notification.name,
          lifecycleScope: self?.windowLifecycleScope ?? "window"
        )
      }
      observers.append(token)
    }

    let appNotificationNames: [Notification.Name] = [
      NSApplication.didHideNotification,
      NSApplication.didUnhideNotification,
    ]

    for name in appNotificationNames {
      let token = center.addObserver(
        forName: name,
        object: nil,
        queue: .main
      ) { [weak self] notification in
        self?.emit(
          notificationName: notification.name,
          lifecycleScope: self?.applicationLifecycleScope ?? "application"
        )
      }
      observers.append(token)
    }
  }

  func stop() {
    let center = NotificationCenter.default
    for token in observers {
      center.removeObserver(token)
    }
    observers.removeAll()
  }

  private func emit(notificationName: Notification.Name, lifecycleScope: String) {
    onEvent(
      LifecycleEventPayload.build(
        rawState: notificationName.rawValue,
        lifecycleScope: lifecycleScope,
        windowId: windowId,
        isMainWindow: isMainWindow
      )
    )
  }
}

// MARK: - Flutter Plugin

/// macOS 系统原生层（架构第 ④ 层）。
///
/// 多窗口：Flutter 官方 **一窗口一 Engine 一 NSWindow**；
/// 每个 Engine 独立插件实例 + 独立 EventChannel 连接。
/// [onListen] 入参携带 windowId / isMainWindow，事件写入 extra 供业务溯源。
public class FastLifecyclePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var tracker: MacOSLifecycleTracker?
  private var listenWindowId: String?
  private var listenIsMainWindow = true
  private weak var flutterViewController: FlutterViewController?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let eventChannel = FlutterEventChannel(
      name: "fast_lifecycle/events",
      binaryMessenger: registrar.messenger
    )

    let instance = FastLifecyclePlugin()
    instance.flutterViewController = registrar.viewController as? FlutterViewController
    eventChannel.setStreamHandler(instance)
  }

  public func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    parseListenArguments(arguments)
    startNativeListening()
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    stopNativeListening()
    eventSink = nil
    return nil
  }

  private func parseListenArguments(_ arguments: Any?) {
    guard let map = arguments as? [String: Any] else { return }
    listenWindowId = map["windowId"] as? String
    listenIsMainWindow = map["isMainWindow"] as? Bool ?? true
  }

  private func startNativeListening() {
    guard tracker == nil else { return }

    // 绑定当前 Engine 对应 NSWindow，实现单窗口事件隔离（§5.1）
    let window = flutterViewController?.view.window

    tracker = MacOSLifecycleTracker(
      onEvent: { [weak self] payload in
        self?.eventSink?(payload)
      },
      windowId: listenWindowId,
      isMainWindow: listenIsMainWindow,
      targetWindow: window
    )
    tracker?.start()
  }

  private func stopNativeListening() {
    tracker?.stop()
    tracker = nil
  }
}
