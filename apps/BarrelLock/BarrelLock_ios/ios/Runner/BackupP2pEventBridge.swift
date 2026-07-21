import Flutter

/// Shared EventChannel sink for Multipeer + BLE GATT backup sessions.
final class BackupP2pEventBridge: NSObject, FlutterStreamHandler {
  static let shared = BackupP2pEventBridge()
  static let channelName = "com.barrellock/backup_p2p_events"

  private var eventSink: FlutterEventSink?

  static func register(with registrar: FlutterPluginRegistrar) {
    let eventChannel = FlutterEventChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    eventChannel.setStreamHandler(shared)
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  func emit(_ event: [String: Any]) {
    DispatchQueue.main.async { [weak self] in
      self?.eventSink?(event)
    }
  }
}
