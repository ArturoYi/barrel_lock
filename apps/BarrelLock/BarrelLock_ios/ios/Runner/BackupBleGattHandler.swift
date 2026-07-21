import CoreBluetooth
import Flutter
import UIKit

/// BLE GATT cross-platform backup transport (BLBG chunks).
///
/// Receive role: CBPeripheralManager (Peripheral). Send role: CBCentralManager (Central).
final class BackupBleGattHandler: NSObject, FlutterPlugin {
  private static let channelName = "com.barrellock/backup_ble_gatt"
  private static let serviceUUID = CBUUID(string: "A7B4C3D2-E5F6-4789-A012-3456789ABCDE")
  private static let controlUUID = CBUUID(string: "A7B4C3D2-E5F6-4789-A012-3456789ABC01")
  private static let dataUUID = CBUUID(string: "A7B4C3D2-E5F6-4789-A012-3456789ABC02")
  private static let discoveryTimeout: TimeInterval = 180
  private static let transferTimeout: TimeInterval = 600
  private static let blbgHeaderSize = 20

  private var pendingResult: FlutterResult?
  private var timeoutTimer: Timer?
  private var transferTimeoutTimer: Timer?

  private var localRole = ""
  private var sendMetaWritten = false
  private var sendSessionMeta: String?
  private var sendChunks: [Data] = []
  private var sendChunkIndex = 0

  private var receivedSessionMeta: String?
  private var receivedChunks: [Data] = []
  private var expectedChunkCount: Int?
  private var expectedTotalChunks: Int?

  private var peripheralManager: CBPeripheralManager?
  private var controlCharacteristic: CBMutableCharacteristic?
  private var dataCharacteristic: CBMutableCharacteristic?

  private var centralManager: CBCentralManager?
  private var connectedPeripheral: CBPeripheral?
  private var remoteControlCharacteristic: CBCharacteristic?
  private var remoteDataCharacteristic: CBCharacteristic?
  private var pendingStartAdvertising = false
  private var connectedCentralId: UUID?
  private var serviceDiscoveryTimer: Timer?
  private var serviceDiscoveryRetryCount = 0
  private var discoveredPeripherals: [String: CBPeripheral] = [:]
  private var pendingDataWriteBuffer = Data()
  private var pendingControlWriteBuffer = Data()

  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = BackupBleGattHandler()
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
    guard connectedPeripheral == nil else {
      result(nil)
      return
    }
    guard let peerId = call.arguments as? String,
          let peripheral = discoveredPeripherals[peerId]
    else {
      result(flutterError("设备不可用，请确认对端仍在接收"))
      return
    }
    connectedPeripheral = peripheral
    peripheral.delegate = self
    centralManager?.stopScan()
    emitPhase("connecting", message: "正在连接…")
    centralManager?.connect(peripheral, options: nil)
    result(nil)
  }

  private func handleTransferSend(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard pendingResult == nil else {
      result(flutterError("已有传输进行中"))
      return
    }
    guard let args = call.arguments as? [String: Any],
          let sessionMeta = args["sessionMeta"] as? String,
          let chunksRaw = args["chunks"] as? [FlutterStandardTypedData],
          !chunksRaw.isEmpty
    else {
      result(flutterError("发送参数无效"))
      return
    }

    pendingResult = result
    localRole = "send"
    sendSessionMeta = sessionMeta
    sendChunks = chunksRaw.map(\.data)
    sendChunkIndex = 0
    startCentralScan()
  }

  private func handleTransferReceive(result: @escaping FlutterResult) {
    guard pendingResult == nil else {
      result(flutterError("已有传输进行中"))
      return
    }

    pendingResult = result
    localRole = "receive"
    startPeripheralAdvertising()
  }

  private func startCentralScan() {
    resetDiscoveryState()
    serviceDiscoveryRetryCount = 0
    emitPhase("discovering")
    centralManager = CBCentralManager(delegate: self, queue: nil)
    scheduleTimeout()
  }

  private func resetDiscoveryState() {
    discoveredPeripherals.removeAll()
    remoteControlCharacteristic = nil
    remoteDataCharacteristic = nil
    connectedCentralId = nil
  }

  private func startPeripheralAdvertising() {
    resetTransferState()
    emitPhase("discovering")
    peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    scheduleTimeout()
  }

  private func scheduleTimeout() {
    timeoutTimer?.invalidate()
    timeoutTimer = Timer.scheduledTimer(withTimeInterval: Self.discoveryTimeout, repeats: false) { [weak self] _ in
      self?.fail(with: "未找到设备或传输超时")
    }
  }

  private func scheduleTransferTimeout() {
    transferTimeoutTimer?.invalidate()
    transferTimeoutTimer = Timer.scheduledTimer(withTimeInterval: Self.transferTimeout, repeats: false) { [weak self] _ in
      self?.fail(with: "传输超时，请重试")
    }
  }

  private func cancelTransferTimeout() {
    transferTimeoutTimer?.invalidate()
    transferTimeoutTimer = nil
  }

  private func parseChunkCount(from sessionMeta: String?) -> Int? {
    guard let sessionMeta,
          let data = sessionMeta.data(using: .utf8),
          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
          let count = json["chunkCount"] as? Int,
          count > 0
    else { return nil }
    return count
  }

  private func setupGattService() {
    guard let peripheralManager, peripheralManager.state == .poweredOn else { return }

    peripheralManager.removeAllServices()

    controlCharacteristic = CBMutableCharacteristic(
      type: Self.controlUUID,
      properties: [.write, .read],
      value: nil,
      permissions: [.writeable, .readable]
    )
    dataCharacteristic = CBMutableCharacteristic(
      type: Self.dataUUID,
      properties: [.write],
      value: nil,
      permissions: [.writeable]
    )

    let service = CBMutableService(type: Self.serviceUUID, primary: true)
    service.characteristics = [controlCharacteristic!, dataCharacteristic!]
    pendingStartAdvertising = true
    peripheralManager.add(service)
  }

  private func startAdvertisingIfReady(_ peripheral: CBPeripheralManager) {
    guard pendingStartAdvertising else { return }
    pendingStartAdvertising = false
    peripheral.startAdvertising([
      CBAdvertisementDataServiceUUIDsKey: [Self.serviceUUID],
      CBAdvertisementDataLocalNameKey: "BarrelLock",
    ])
    emitPhase("discovering", message: "等待跨平台发送端连接…")
  }

  private func scheduleServiceDiscoveryTimeout() {
    serviceDiscoveryTimer?.invalidate()
    serviceDiscoveryTimer = Timer.scheduledTimer(withTimeInterval: 12, repeats: false) { [weak self] _ in
      guard let self, self.pendingResult != nil, self.localRole == "send" else { return }
      if self.remoteControlCharacteristic == nil {
        if self.retryServiceDiscovery() {
          self.scheduleServiceDiscoveryTimeout()
          return
        }
        self.fail(with: "发现服务超时，请重试")
      }
    }
  }

  private func cancelServiceDiscoveryTimeout() {
    serviceDiscoveryTimer?.invalidate()
    serviceDiscoveryTimer = nil
  }

  private func retryServiceDiscovery() -> Bool {
    guard serviceDiscoveryRetryCount < 2,
          let peripheral = connectedPeripheral
    else { return false }
    serviceDiscoveryRetryCount += 1
    peripheral.discoverServices(nil)
    return true
  }

  private func resolveRemoteCharacteristics(for peripheral: CBPeripheral) -> CBService? {
    peripheral.services?.first(where: { $0.uuid == Self.serviceUUID })
  }

  private func markCentralConnected(_ central: CBCentral) {
    guard connectedCentralId != central.identifier else { return }
    connectedCentralId = central.identifier
    emitPhase("connecting", message: "已连接，准备接收…")
    emitPeerFound(peerId: central.identifier.uuidString, displayName: "跨平台设备")
  }

  private func startSendTransferIfReady() {
    guard localRole == "send",
          let peripheral = connectedPeripheral,
          let control = remoteControlCharacteristic,
          let data = remoteDataCharacteristic,
          let sessionMeta = sendSessionMeta,
          !sendChunks.isEmpty
    else { return }

    emitPhase("transferring")
    timeoutTimer?.invalidate()
    scheduleTransferTimeout()
    let metaPayload = makeControlPayload(type: "meta", sessionMeta: sessionMeta)
    peripheral.writeValue(metaPayload, for: control, type: .withResponse)
  }

  private func writeNextChunk(peripheral: CBPeripheral, dataCharacteristic: CBCharacteristic) {
    guard sendChunkIndex < sendChunks.count else {
      finishSend(peripheral: peripheral)
      return
    }

    let chunk = sendChunks[sendChunkIndex]
    peripheral.writeValue(chunk, for: dataCharacteristic, type: .withResponse)
  }

  private func finishSend(peripheral: CBPeripheral) {
    guard let control = remoteControlCharacteristic else { return }
    let endPayload = makeControlPayload(
      type: "end",
      chunkCount: sendChunks.count
    )
    peripheral.writeValue(endPayload, for: control, type: .withResponse)
  }

  private func handleControlWrite(_ data: Data) {
    guard let control = parseControlPayload(data) else { return }
    let type = control["type"] as? String ?? ""
    switch type {
    case "meta":
      receivedSessionMeta = control["sessionMeta"] as? String
      expectedTotalChunks = parseChunkCount(from: receivedSessionMeta)
      timeoutTimer?.invalidate()
      scheduleTransferTimeout()
      emitPhase("transferring", message: "正在接收备份… 0%")
    case "end":
      flushPendingDataWrite()
      expectedChunkCount = control["chunkCount"] as? Int
      tryCompleteReceive()
    default:
      break
    }
  }

  private func handleDataWrite(_ data: Data) {
    receivedChunks.append(data)
    let expected = expectedChunkCount ?? expectedTotalChunks
    if let expected, expected > 0 {
      emitProgress(Double(receivedChunks.count) / Double(expected))
    }
  }

  private func flushPendingDataWrite() {
    tryFlushCompleteBlbgChunks()
  }

  private func readU32(from data: Data, at offset: Int) -> Int {
    guard data.count >= offset + 4 else { return 0 }
    return Int(data[offset])
      | (Int(data[offset + 1]) << 8)
      | (Int(data[offset + 2]) << 16)
      | (Int(data[offset + 3]) << 24)
  }

  /// 按 BLBG 头中的 payloadLen 切出完整分片（支持 long write / prepare+execute 多段写入）。
  private func tryFlushCompleteBlbgChunks() {
    while pendingDataWriteBuffer.count >= Self.blbgHeaderSize {
      let payloadLen = readU32(from: pendingDataWriteBuffer, at: 16)
      let totalSize = Self.blbgHeaderSize + payloadLen
      guard pendingDataWriteBuffer.count >= totalSize else { break }
      let chunk = pendingDataWriteBuffer.prefix(totalSize)
      handleDataWrite(Data(chunk))
      pendingDataWriteBuffer.removeFirst(totalSize)
    }
  }

  private func mergeIncomingWrite(into buffer: inout Data, offset: Int, data: Data) {
    if offset == 0, buffer.isEmpty {
      buffer = data
      return
    }
    let end = offset + data.count
    if buffer.count < end {
      buffer.count = end
    }
    buffer.replaceSubrange(offset..<end, with: data)
  }

  private func tryCompleteReceive() {
    guard localRole == "receive" else { return }
    let expected = expectedChunkCount ?? expectedTotalChunks
    guard let expected, receivedChunks.count >= expected else { return }

    cancelTransferTimeout()
    emitProgress(1)
    emitPhase("completed")
    let payload: [String: Any] = [
      "sessionMeta": receivedSessionMeta ?? "",
      "chunks": receivedChunks.map { FlutterStandardTypedData(bytes: $0) },
    ]
    completeSuccess(payload)
  }

  private func makeControlPayload(type: String, sessionMeta: String? = nil, chunkCount: Int? = nil) -> Data {
    var dict: [String: Any] = ["type": type]
    if let sessionMeta {
      dict["sessionMeta"] = sessionMeta
    }
    if let chunkCount {
      dict["chunkCount"] = chunkCount
    }
    return (try? JSONSerialization.data(withJSONObject: dict)) ?? Data()
  }

  private func parseControlPayload(_ data: Data) -> [String: Any]? {
    guard let object = try? JSONSerialization.jsonObject(with: data),
          let dict = object as? [String: Any]
    else { return nil }
    return dict
  }

  private func resetTransferState() {
    sendMetaWritten = false
    sendSessionMeta = nil
    sendChunks = []
    sendChunkIndex = 0
    receivedSessionMeta = nil
    receivedChunks = []
    expectedChunkCount = nil
    expectedTotalChunks = nil
    connectedCentralId = nil
    pendingDataWriteBuffer = Data()
    pendingControlWriteBuffer = Data()
  }

  private func cleanup() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
    cancelTransferTimeout()
    cancelServiceDiscoveryTimeout()

    if let peripheralManager {
      peripheralManager.stopAdvertising()
      peripheralManager.removeAllServices()
      peripheralManager.delegate = nil
    }
    peripheralManager = nil
    controlCharacteristic = nil
    dataCharacteristic = nil
    pendingStartAdvertising = false
    connectedCentralId = nil

    if let centralManager {
      if let peripheral = connectedPeripheral {
        centralManager.cancelPeripheralConnection(peripheral)
      }
      centralManager.stopScan()
      centralManager.delegate = nil
    }
    centralManager = nil
    connectedPeripheral = nil
    remoteControlCharacteristic = nil
    remoteDataCharacteristic = nil
    discoveredPeripherals.removeAll()

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

  private func flutterError(_ message: String) -> FlutterError {
    FlutterError(code: "backup_ble_gatt", message: message, details: nil)
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

extension BackupBleGattHandler: CBPeripheralManagerDelegate {
  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    guard localRole == "receive" else { return }
    switch peripheral.state {
    case .poweredOn:
      setupGattService()
    case .unauthorized:
      fail(with: "蓝牙权限被拒绝")
    case .poweredOff:
      fail(with: "蓝牙已关闭，请打开后重试")
    case .unsupported:
      fail(with: "本设备不支持蓝牙")
    case .resetting:
      fail(with: "蓝牙暂时不可用，请稍后重试")
    default:
      break
    }
  }

  func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
    if let error {
      pendingStartAdvertising = false
      fail(with: "GATT 服务启动失败：\(error.localizedDescription)")
      return
    }
    guard service.uuid == Self.serviceUUID else { return }
    startAdvertisingIfReady(peripheral)
  }

  func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
    if let error {
      fail(with: "广播失败：\(error.localizedDescription)")
    }
  }

  func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
    markCentralConnected(central)
  }

  func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
    var controlWriteStarted = false

    // 必须先 ACK，再处理 payload，否则 Android Central 会卡住直至断连。
    for request in requests {
      markCentralConnected(request.central)
      peripheral.respond(to: request, withResult: .success)
    }

    for request in requests {
      if request.characteristic.uuid == Self.controlUUID {
        if request.value == nil || request.value!.isEmpty {
          continue
        }
        if request.offset == 0 {
          flushPendingDataWrite()
          pendingControlWriteBuffer = Data()
          controlWriteStarted = true
        }
        mergeIncomingWrite(
          into: &pendingControlWriteBuffer,
          offset: request.offset,
          data: request.value!
        )
      } else if request.characteristic.uuid == Self.dataUUID {
        if request.value == nil || request.value!.isEmpty {
          continue
        }
        if request.offset == 0 {
          flushPendingDataWrite()
          pendingDataWriteBuffer = Data()
        }
        mergeIncomingWrite(
          into: &pendingDataWriteBuffer,
          offset: request.offset,
          data: request.value!
        )
      }
    }

    tryFlushCompleteBlbgChunks()

    if controlWriteStarted {
      handleControlWrite(pendingControlWriteBuffer)
      pendingControlWriteBuffer = Data()
    }
  }
}

extension BackupBleGattHandler: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    guard localRole == "send" else { return }
    switch central.state {
    case .poweredOn:
      central.scanForPeripherals(withServices: [Self.serviceUUID], options: nil)
    case .unauthorized:
      fail(with: "蓝牙权限被拒绝")
    case .poweredOff:
      fail(with: "蓝牙已关闭，请打开后重试")
    case .unsupported:
      fail(with: "本设备不支持蓝牙")
    case .resetting:
      fail(with: "蓝牙暂时不可用，请稍后重试")
    default:
      break
    }
  }

  func centralManager(
    _ central: CBCentralManager,
    didDiscover peripheral: CBPeripheral,
    advertisementData: [String: Any],
    rssi RSSI: NSNumber
  ) {
    guard connectedPeripheral == nil else { return }
    discoveredPeripherals[peripheral.identifier.uuidString] = peripheral
    emitPeerFound(
      peerId: peripheral.identifier.uuidString,
      displayName: advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? "跨平台设备"
    )
  }

  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    serviceDiscoveryRetryCount = 0
    emitPhase("connecting", message: "已连接，发现服务…")
    peripheral.delegate = self
    scheduleServiceDiscoveryTimeout()
    peripheral.discoverServices(nil)
  }

  func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
    fail(with: error?.localizedDescription ?? "连接失败")
  }

  func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    if pendingResult != nil {
      fail(with: error?.localizedDescription ?? "连接已断开")
    }
  }
}

extension BackupBleGattHandler: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    if let error {
      if retryServiceDiscovery() {
        return
      }
      cancelServiceDiscoveryTimeout()
      fail(with: error.localizedDescription)
      return
    }
    guard let service = resolveRemoteCharacteristics(for: peripheral) else {
      if retryServiceDiscovery() {
        return
      }
      cancelServiceDiscoveryTimeout()
      fail(with: "未找到备份 GATT 服务")
      return
    }
    peripheral.discoverCharacteristics([Self.controlUUID, Self.dataUUID], for: service)
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    if let error {
      cancelServiceDiscoveryTimeout()
      fail(with: error.localizedDescription)
      return
    }
    for characteristic in service.characteristics ?? [] {
      if characteristic.uuid == Self.controlUUID {
        remoteControlCharacteristic = characteristic
      } else if characteristic.uuid == Self.dataUUID {
        remoteDataCharacteristic = characteristic
      }
    }
    guard remoteControlCharacteristic != nil, remoteDataCharacteristic != nil else {
      cancelServiceDiscoveryTimeout()
      fail(with: "GATT 特征值不完整")
      return
    }
    cancelServiceDiscoveryTimeout()
    startSendTransferIfReady()
  }

  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    if let error {
      fail(with: error.localizedDescription)
      return
    }

    guard localRole == "send" else { return }

    if characteristic.uuid == Self.controlUUID {
      if !sendMetaWritten {
        sendMetaWritten = true
        if !sendChunks.isEmpty {
          emitProgress(1.0 / Double(sendChunks.count))
        }
        if let dataChar = remoteDataCharacteristic {
          writeNextChunk(peripheral: peripheral, dataCharacteristic: dataChar)
        }
        return
      }
      cancelTransferTimeout()
      emitProgress(1)
      emitPhase("completed")
      completeSuccess(nil)
      return
    }

    guard characteristic.uuid == Self.dataUUID else { return }
    sendChunkIndex += 1
    if !sendChunks.isEmpty {
      emitProgress(Double(sendChunkIndex) / Double(sendChunks.count))
    }
    if sendChunkIndex >= sendChunks.count {
      finishSend(peripheral: peripheral)
    } else if let dataChar = remoteDataCharacteristic {
      writeNextChunk(peripheral: peripheral, dataCharacteristic: dataChar)
    }
  }
}
