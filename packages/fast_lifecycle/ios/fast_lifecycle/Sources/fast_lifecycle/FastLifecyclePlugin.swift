import Flutter
import UIKit

// MARK: - 跨端载荷构造（字段名与 Dart NativePayloadKeys 一致）

/// EventChannel 标准载荷构造器。
///
/// - Important: [rawState] 必须为 UIApplicationDelegate 方法名原字符串，禁止翻译。
private enum LifecycleEventPayload {
  static func build(
    rawState: String,
    source: String = "ios",
    lifecycleScope: String = "application",
    windowId: String? = nil,
    isMainWindow: Bool = true
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

// MARK: - UIApplication 生命周期采集

/// iOS 原生生命周期采集器。
///
/// rawState 一一对应 [UIApplicationDelegate] 方法名（需求文档 §4.1）：
/// - applicationDidFinishLaunching
/// - applicationDidBecomeActive
/// - applicationWillResignActive
/// - applicationDidEnterBackground
/// - applicationWillEnterForeground
/// - applicationWillTerminate
private final class AppLifecycleTracker {
  private var observers: [NSObjectProtocol] = []
  private var lastRawState: String?
  private let onEvent: ([String: Any]) -> Void
  private let windowId: String?
  private let isMainWindow: Bool

  init(
    onEvent: @escaping ([String: Any]) -> Void,
    windowId: String?,
    isMainWindow: Bool
  ) {
    self.onEvent = onEvent
    self.windowId = windowId
    self.isMainWindow = isMainWindow
  }

  func start() {
    guard observers.isEmpty else { return }

    let center = NotificationCenter.default
    let mappings: [(Notification.Name, String)] = [
      (UIApplication.didFinishLaunchingNotification, "applicationDidFinishLaunching"),
      (UIApplication.didBecomeActiveNotification, "applicationDidBecomeActive"),
      (UIApplication.willResignActiveNotification, "applicationWillResignActive"),
      (UIApplication.didEnterBackgroundNotification, "applicationDidEnterBackground"),
      (UIApplication.willEnterForegroundNotification, "applicationWillEnterForeground"),
      (UIApplication.willTerminateNotification, "applicationWillTerminate"),
    ]

    for (name, rawState) in mappings {
      let token = center.addObserver(
        forName: name,
        object: nil,
        queue: .main
      ) { [weak self] _ in
        self?.emit(rawState: rawState)
      }
      observers.append(token)
    }

    emitCurrentStateIfNeeded()
  }

  func stop() {
    let center = NotificationCenter.default
    for token in observers {
      center.removeObserver(token)
    }
    observers.removeAll()
    lastRawState = nil
  }

  private func emitCurrentStateIfNeeded() {
    let app = UIApplication.shared
    switch app.applicationState {
    case .active:
      emit(rawState: "applicationDidBecomeActive")
    case .inactive:
      emit(rawState: "applicationWillResignActive")
    case .background:
      emit(rawState: "applicationDidEnterBackground")
    @unknown default:
      break
    }
  }

  private func emit(rawState: String) {
    if lastRawState == rawState { return }
    lastRawState = rawState
    onEvent(
      LifecycleEventPayload.build(
        rawState: rawState,
        windowId: windowId,
        isMainWindow: isMainWindow
      )
    )
  }
}

// MARK: - Flutter Plugin（系统原生层入口）

/// iOS 系统原生层（架构第 ④ 层）。
///
/// - EventChannel `fast_lifecycle/events`：唯一事件推送通道
/// - MethodChannel `fast_lifecycle/control`：仅 startListening / stopListening
public class FastLifecyclePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var eventSink: FlutterEventSink?
  private var tracker: AppLifecycleTracker?
  private var listenWindowId: String?
  private var listenIsMainWindow = true

  public static func register(with registrar: FlutterPluginRegistrar) {
    let controlChannel = FlutterMethodChannel(
      name: "fast_lifecycle/control",
      binaryMessenger: registrar.messenger()
    )
    let eventChannel = FlutterEventChannel(
      name: "fast_lifecycle/events",
      binaryMessenger: registrar.messenger()
    )

    let instance = FastLifecyclePlugin()
    registrar.addMethodCallDelegate(instance, channel: controlChannel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "startListening":
      parseListenArguments(call.arguments)
      startNativeListening()
      result(nil)
    case "stopListening":
      stopNativeListening()
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
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

    tracker = AppLifecycleTracker(
      onEvent: { [weak self] payload in
        self?.eventSink?(payload)
      },
      windowId: listenWindowId,
      isMainWindow: listenIsMainWindow
    )
    tracker?.start()
  }

  private func stopNativeListening() {
    tracker?.stop()
    tracker = nil
  }
}
