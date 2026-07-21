import CoreBluetooth
import Flutter
import MultipeerConnectivity
import UIKit

/// MultipeerConnectivity P2P transport for BLBT backup frames.
///
/// Control packets: `[BLBC]` + UTF-8 JSON. Data packets: raw BLBT frames from Dart.
final class BackupMultipeerHandler: NSObject, FlutterPlugin {
  private static let channelName = "com.barrellock/backup_multipeer"
  private static let serviceType = "blbackup"
  private static let controlMagic = Data([0x42, 0x4C, 0x42, 0x43]) // BLBC
  private static let discoveryTimeout: TimeInterval = 120

  private var peerID: MCPeerID!
  private var session: MCSession!
  private var advertiser: MCNearbyServiceAdvertiser?
  private var browser: MCNearbyServiceBrowser?
  private var pendingResult: FlutterResult?
  private var timeoutTimer: Timer?
  private var hasInvitedPeer = false
  private var transferStarted = false

  private var sendSessionMeta: String?
  private var sendFrames: [Data] = []

  private var receivedFrames: [Data] = []
  private var receivedSessionMeta: String?
  private var expectedFrameCount: Int?

  private var localRole = ""
  private var expectedPeerRole = ""
  private var discoveredPeers: [String: MCPeerID] = [:]
  private var bluetoothMonitor: CBCentralManager?

  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = BackupMultipeerHandler()
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "transferSend":
      handleTransferSend(call, result: result)
    case "transferReceive":
      handleTransferReceive(result: result)
    case "cancel":
      cleanup()
      result(nil)
    case "connectPeer":
      handleConnectPeer(call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleConnectPeer(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard pendingResult != nil, localRole == "send" else {
      result(flutterError("当前不在发送会话中"))
      return
    }
    guard !hasInvitedPeer else {
      result(nil)
      return
    }
    guard let peerId = call.arguments as? String else {
      result(flutterError("设备 ID 无效"))
      return
    }
    guard let browser else {
      result(flutterError("尚未开始搜索设备"))
      return
    }
    guard let peerID = discoveredPeers[peerId] else {
      result(flutterError("设备不可用，请确认对端仍在接收"))
      return
    }
    hasInvitedPeer = true
    emitPhase("connecting", message: "正在连接 \(peerId)…")
    browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    result(nil)
  }

  private func handleTransferSend(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard pendingResult == nil else {
      result(flutterError("已有传输进行中"))
      return
    }
    guard let args = call.arguments as? [String: Any],
          let sessionMeta = args["sessionMeta"] as? String,
          let framesRaw = args["frames"] as? [FlutterStandardTypedData],
          !framesRaw.isEmpty
    else {
      result(flutterError("发送参数无效"))
      return
    }

    pendingResult = result
    sendSessionMeta = sessionMeta
    sendFrames = framesRaw.map(\.data)
    localRole = "send"
    expectedPeerRole = "receive"
    startDiscovery()
  }

  private func handleTransferReceive(result: @escaping FlutterResult) {
    guard pendingResult == nil else {
      result(flutterError("已有传输进行中"))
      return
    }

    pendingResult = result
    localRole = "receive"
    expectedPeerRole = "send"
    startDiscovery()
  }

  private func startDiscovery() {
    if localRole == "send" {
      resetDiscoveryState()
    } else {
      resetTransferState()
    }
    emitPhase("discovering")
    beginBluetoothMonitoring()
    peerID = MCPeerID(displayName: UIDevice.current.name)
    session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
    session.delegate = self

    advertiser = MCNearbyServiceAdvertiser(
      peer: peerID,
      discoveryInfo: ["role": localRole],
      serviceType: Self.serviceType
    )
    advertiser?.delegate = self
    advertiser?.startAdvertisingPeer()

    browser = MCNearbyServiceBrowser(peer: peerID, serviceType: Self.serviceType)
    browser?.delegate = self
    browser?.startBrowsingForPeers()

    timeoutTimer = Timer.scheduledTimer(withTimeInterval: Self.discoveryTimeout, repeats: false) { [weak self] _ in
      self?.fail(with: "连接超时，请确认对端已打开并开始传输")
    }
  }

  private func startTransferIfNeeded() {
    guard !transferStarted, !session.connectedPeers.isEmpty else { return }
    transferStarted = true

    if localRole == "send" {
      performSend()
    }
  }

  private func performSend() {
    guard let peer = session.connectedPeers.first,
          let sessionMeta = sendSessionMeta
    else {
      fail(with: "未找到已连接的对端")
      return
    }

    do {
      emitPhase("transferring", message: "正在发送备份…")
      try session.send(makeControlPacket(type: "meta", sessionMeta: sessionMeta), toPeers: [peer], with: .reliable)
      for (index, frame) in sendFrames.enumerated() {
        emitProgress(Double(index) / Double(max(sendFrames.count, 1)))
        try session.send(frame, toPeers: [peer], with: .reliable)
      }
      emitProgress(1)
      try session.send(
        makeControlPacket(type: "end", frameCount: sendFrames.count),
        toPeers: [peer],
        with: .reliable
      )
      emitPhase("completed", message: "发送完成")
      completeSuccess(nil)
    } catch {
      fail(with: "发送失败：\(error.localizedDescription)")
    }
  }

  private func tryCompleteReceive() {
    guard let expectedFrameCount,
          receivedFrames.count == expectedFrameCount
    else { return }

    let payload: [String: Any] = [
      "sessionMeta": receivedSessionMeta ?? "",
      "frames": receivedFrames.map { FlutterStandardTypedData(bytes: $0) },
    ]
    emitPhase("completed", message: "接收完成")
    emitProgress(1)
    completeSuccess(payload)
  }

  private func makeControlPacket(type: String, sessionMeta: String? = nil, frameCount: Int? = nil) -> Data {
    var json: [String: Any] = ["type": type]
    if let sessionMeta {
      json["sessionMeta"] = sessionMeta
    }
    if let frameCount {
      json["frameCount"] = frameCount
    }
    let body = (try? JSONSerialization.data(withJSONObject: json)) ?? Data()
    var packet = Self.controlMagic
    packet.append(body)
    return packet
  }

  private func parseControlPacket(_ data: Data) -> [String: Any]? {
    guard data.count > Self.controlMagic.count else { return nil }
    guard data.prefix(Self.controlMagic.count) == Self.controlMagic else { return nil }
    let jsonData = data.suffix(from: Self.controlMagic.count)
    guard let object = try? JSONSerialization.jsonObject(with: jsonData),
          let dict = object as? [String: Any]
    else { return nil }
    return dict
  }

  private func handleReceivedData(_ data: Data) {
    if let control = parseControlPacket(data) {
      let type = control["type"] as? String ?? ""
      switch type {
      case "meta":
        receivedSessionMeta = control["sessionMeta"] as? String
      case "end":
        expectedFrameCount = control["frameCount"] as? Int
        tryCompleteReceive()
      default:
        break
      }
      return
    }

    receivedFrames.append(data)
    tryCompleteReceive()
  }

  private func resetDiscoveryState() {
    hasInvitedPeer = false
    transferStarted = false
    discoveredPeers.removeAll()
  }

  private func resetTransferState() {
    hasInvitedPeer = false
    transferStarted = false
    sendSessionMeta = nil
    sendFrames = []
    receivedFrames = []
    receivedSessionMeta = nil
    expectedFrameCount = nil
  }

  private func cleanup() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
    stopBluetoothMonitoring()
    advertiser?.stopAdvertisingPeer()
    browser?.stopBrowsingForPeers()
    advertiser?.delegate = nil
    browser?.delegate = nil
    advertiser = nil
    browser = nil
    session?.disconnect()
    session?.delegate = nil
    session = nil
    pendingResult = nil
    resetTransferState()
  }

  private func completeSuccess(_ value: Any?) {
    let result = pendingResult
    cleanup()
    result?(value)
  }

  private func fail(with message: String) {
    guard pendingResult != nil else { return }
    emitError(message)
    let result = pendingResult
    cleanup()
    result?(flutterError(message))
  }

  private func beginBluetoothMonitoring() {
    stopBluetoothMonitoring()
    bluetoothMonitor = CBCentralManager(
      delegate: self,
      queue: nil,
      options: [CBCentralManagerOptionShowPowerAlertKey: false]
    )
  }

  private func stopBluetoothMonitoring() {
    bluetoothMonitor?.delegate = nil
    bluetoothMonitor = nil
  }

  private func flutterError(_ message: String) -> FlutterError {
    FlutterError(code: "backup_multipeer", message: message, details: nil)
  }

  private func emitPhase(_ phase: String, message: String? = nil) {
    var event: [String: Any] = ["type": "phase", "phase": phase]
    if let message {
      event["message"] = message
    }
    emit(event)
  }

  private func emitPeerFound(peerId: String, displayName: String) {
    emit([
      "type": "peerFound",
      "peerId": peerId,
      "displayName": displayName,
    ])
  }

  private func emitPeerLost(peerId: String) {
    emit(["type": "peerLost", "peerId": peerId])
  }

  private func emitProgress(_ value: Double) {
    emit(["type": "progress", "value": value])
  }

  private func emitError(_ message: String) {
    emit(["type": "error", "message": message])
  }

  private func emit(_ event: [String: Any]) {
    BackupP2pEventBridge.shared.emit(event)
  }
}

extension BackupMultipeerHandler: MCSessionDelegate {
  func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      if state == .connected {
        self.emitPhase("connecting", message: "已连接，准备传输…")
        self.startTransferIfNeeded()
      } else if state == .notConnected, self.pendingResult != nil, self.transferStarted {
        self.fail(with: "连接已断开")
      }
    }
  }

  func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
    DispatchQueue.main.async { [weak self] in
      self?.handleReceivedData(data)
    }
  }

  func session(
    _ session: MCSession,
    didReceive stream: InputStream,
    withName streamName: String,
    fromPeer peerID: MCPeerID
  ) {}

  func session(
    _ session: MCSession,
    didStartReceivingResourceWithName resourceName: String,
    fromPeer peerID: MCPeerID,
    with progress: Progress
  ) {}

  func session(
    _ session: MCSession,
    didFinishReceivingResourceWithName resourceName: String,
    fromPeer peerID: MCPeerID,
    at localURL: URL?,
    withError error: Error?
  ) {}
}

extension BackupMultipeerHandler: MCNearbyServiceAdvertiserDelegate {
  func advertiser(
    _ advertiser: MCNearbyServiceAdvertiser,
    didReceiveInvitationFromPeer peerID: MCPeerID,
    withContext context: Data?,
    invitationHandler: @escaping (Bool, MCSession?) -> Void
  ) {
    invitationHandler(true, session)
  }
}

extension BackupMultipeerHandler: MCNearbyServiceBrowserDelegate {
  func browser(
    _ browser: MCNearbyServiceBrowser,
    foundPeer peerID: MCPeerID,
    withDiscoveryInfo info: [String: String]?
  ) {
    guard info?["role"] == expectedPeerRole else { return }
    discoveredPeers[peerID.displayName] = peerID
    emitPeerFound(peerId: peerID.displayName, displayName: peerID.displayName)
  }

  func browser(
    _ browser: MCNearbyServiceBrowser,
    lostPeer peerID: MCPeerID
  ) {
    emitPeerLost(peerId: peerID.displayName)
  }
}

extension BackupMultipeerHandler: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    guard pendingResult != nil else { return }
    switch central.state {
    case .poweredOff:
      fail(with: "蓝牙已关闭，请打开后重试")
    case .unsupported:
      fail(with: "本设备不支持蓝牙")
    case .unauthorized:
      fail(with: "蓝牙权限被拒绝")
    case .resetting:
      fail(with: "蓝牙暂时不可用，请稍后重试")
    default:
      break
    }
  }
}
