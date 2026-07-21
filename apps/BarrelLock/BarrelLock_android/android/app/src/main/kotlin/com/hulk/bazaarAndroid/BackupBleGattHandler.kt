package com.hulk.bazaarAndroid

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCallback
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattServer
import android.bluetooth.BluetoothGattServerCallback
import android.bluetooth.BluetoothGattService
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.BluetoothStatusCodes
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.bluetooth.le.BluetoothLeScanner
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanFilter
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.ParcelUuid
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.UUID

/** BLE GATT cross-platform backup transport (BLBG chunks). */
class BackupBleGattHandler private constructor(
    private val activity: FlutterFragmentActivity,
    private val channel: MethodChannel,
) : MethodChannel.MethodCallHandler {
    private val mainHandler = Handler(Looper.getMainLooper())
    private val bluetoothManager: BluetoothManager =
        activity.getSystemService(BluetoothManager::class.java)
    private val bluetoothAdapter: BluetoothAdapter? = bluetoothManager.adapter

    private val localDeviceId: String by lazy {
        Settings.Secure.getString(activity.contentResolver, Settings.Secure.ANDROID_ID)
            ?: Build.FINGERPRINT
    }

    private var pendingResult: MethodChannel.Result? = null
    private var pendingPermissionAction: (() -> Unit)? = null
    private var localRole = ""

    private var sendSessionMeta: String? = null
    private var sendChunks: List<ByteArray> = emptyList()
    private var sendChunkIndex = 0
    private var sendMetaWritten = false

    private var receivedSessionMeta: String? = null
    private var receivedChunks = mutableListOf<ByteArray>()
    private var expectedChunkCount: Int? = null

    private var gattServer: BluetoothGattServer? = null
    private var advertiser: BluetoothLeAdvertiser? = null
    private var scanner: BluetoothLeScanner? = null
    private var gattClient: BluetoothGatt? = null
    private var remoteControlCharacteristic: BluetoothGattCharacteristic? = null
    private var remoteDataCharacteristic: BluetoothGattCharacteristic? = null
    private var pendingStartAdvertising = false
    private var bluetoothStateMonitor: BackupBluetoothStateMonitor? = null
    private var servicesDiscoveryStarted = false
    private var serviceDiscoveryRetryCount = 0
    private var serviceDiscoveryTimeoutRunnable: Runnable? = null
    private val preparedWriteBuffers = mutableMapOf<String, ByteArray>()
    private val incomingWriteBuffers = mutableMapOf<String, ByteArray>()
    private val discoveredDevices = mutableMapOf<String, BluetoothDevice>()
    private var negotiatedMtu = 23
    private var isMtuReady = false
    private var sendTransferStarted = false
    private var pendingSendGatt: BluetoothGatt? = null
    private var mtuTimeoutRunnable: Runnable? = null
    private var mtuRequestAttempts = 0
    private var mtuQueueRetryCount = 0

    private val timeoutRunnable = Runnable {
        fail("未找到设备或传输超时")
    }

    private val transferTimeoutRunnable = Runnable {
        fail("传输超时，请重试")
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "transferSend" -> handleTransferSend(call, result)
            "transferReceive" -> handleTransferReceive(result)
            "cancel" -> {
                cleanup()
                result.success(null)
            }

            "connectPeer" -> handleConnectPeer(call, result)

            else -> result.notImplemented()
        }
    }

    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray) {
        if (requestCode != PERMISSION_REQUEST_CODE) {
            return
        }
        val granted = grantResults.isNotEmpty() &&
            grantResults.all { it == PackageManager.PERMISSION_GRANTED }
        if (granted) {
            pendingPermissionAction?.invoke()
        } else {
            fail("蓝牙权限被拒绝")
        }
        pendingPermissionAction = null
    }

    private fun handleTransferSend(call: MethodCall, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("backup_ble_gatt", "已有传输进行中", null)
            return
        }
        val args = call.arguments as? Map<*, *>
        val sessionMeta = args?.get("sessionMeta") as? String
        @Suppress("UNCHECKED_CAST")
        val chunksRaw = args?.get("chunks") as? List<*>
        val chunks = chunksRaw?.mapNotNull { item ->
            when (item) {
                is ByteArray -> item
                else -> null
            }
        } ?: emptyList()
        if (sessionMeta.isNullOrEmpty() || chunks.isEmpty()) {
            result.error("backup_ble_gatt", "发送参数无效", null)
            return
        }

        pendingResult = result
        localRole = ROLE_SEND
        sendSessionMeta = sessionMeta
        sendChunks = chunks
        sendChunkIndex = 0
        sendMetaWritten = false
        ensurePermissions { startCentralScan() }
    }

    private fun handleConnectPeer(call: MethodCall, result: MethodChannel.Result) {
        val peerId = call.arguments as? String
        if (peerId.isNullOrBlank()) {
            result.error("backup_ble_gatt", "设备 ID 无效", null)
            return
        }
        if (pendingResult == null || localRole != ROLE_SEND) {
            result.error("backup_ble_gatt", "当前不在发送会话中", null)
            return
        }
        if (gattClient != null) {
            result.success(null)
            return
        }
        val device = discoveredDevices[peerId]
        if (device == null) {
            result.error("backup_ble_gatt", "设备不可用，请确认对端仍在接收", null)
            return
        }
        scanner?.stopScan(scanCallback)
        emitPhase("connecting", "正在连接…")
        gattClient = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            device.connectGatt(
                activity,
                false,
                gattClientCallback,
                BluetoothDevice.TRANSPORT_LE,
            )
        } else {
            device.connectGatt(activity, false, gattClientCallback)
        }
        result.success(null)
    }

    private fun handleTransferReceive(result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("backup_ble_gatt", "已有传输进行中", null)
            return
        }
        pendingResult = result
        localRole = ROLE_RECEIVE
        ensurePermissions { startPeripheralAdvertising() }
    }

    private fun startCentralScan() {
        resetDiscoveryState()
        emitPhase("discovering")
        scheduleTimeout()
        beginBluetoothSessionMonitoring()
        val adapter = bluetoothAdapter
        if (!isBluetoothEnabled(adapter)) {
            fail(BLUETOOTH_DISABLED_MESSAGE)
            return
        }
        scanner = adapter?.bluetoothLeScanner
        if (scanner == null) {
            fail(BLUETOOTH_DISABLED_MESSAGE)
            return
        }
        val filter = ScanFilter.Builder()
            .setServiceUuid(ParcelUuid(SERVICE_UUID))
            .build()
        val settings = ScanSettings.Builder()
            .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
            .build()
        scanner?.startScan(listOf(filter), settings, scanCallback)
    }

    private fun startPeripheralAdvertising() {
        resetTransferState()
        emitPhase("discovering", "等待跨平台发送端连接…")
        scheduleTimeout()
        beginBluetoothSessionMonitoring()
        val adapter = bluetoothAdapter
        if (!isBluetoothEnabled(adapter)) {
            fail(BLUETOOTH_DISABLED_MESSAGE)
            return
        }
        if (adapter?.bluetoothLeAdvertiser == null) {
            fail("本设备不支持 BLE 广播")
            return
        }
        pendingStartAdvertising = true
        setupGattServer()
    }

    private fun startAdvertisingInternal() {
        val adapter = bluetoothAdapter
        if (!isBluetoothEnabled(adapter)) {
            fail(BLUETOOTH_DISABLED_MESSAGE)
            return
        }
        advertiser = adapter?.bluetoothLeAdvertiser
        if (advertiser == null) {
            fail("本设备不支持 BLE 广播")
            return
        }
        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setConnectable(true)
            .setTimeout(0)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
            .build()
        // 仅广播 Service UUID；勿含 deviceName，否则易超过 31 字节导致 DATA_TOO_LARGE。
        val data = AdvertiseData.Builder()
            .addServiceUuid(ParcelUuid(SERVICE_UUID))
            .build()
        val scanResponse = AdvertiseData.Builder()
            .addServiceData(ParcelUuid(SERVICE_UUID), localDeviceMarker())
            .build()
        advertiser?.startAdvertising(settings, data, scanResponse, advertiseCallback)
    }

    private fun localDeviceMarker(): ByteArray {
        val bytes = localDeviceId.toByteArray(Charsets.UTF_8)
        return bytes.copyOf(minOf(bytes.size, 8))
    }

    private fun isSelfPeripheral(result: ScanResult): Boolean {
        val marker = localDeviceMarker()
        val serviceData = result.scanRecord?.getServiceData(ParcelUuid(SERVICE_UUID))
        if (serviceData != null && serviceData.contentEquals(marker)) {
            return true
        }
        val adapterAddress = bluetoothAdapter?.address
        val deviceAddress = result.device?.address
        return !adapterAddress.isNullOrBlank() &&
            adapterAddress != "02:00:00:00:00:00" &&
            adapterAddress.equals(deviceAddress, ignoreCase = true)
    }

    private fun setupGattServer() {
        gattServer?.close()
        gattServer = bluetoothManager.openGattServer(activity, gattServerCallback)
        if (gattServer == null) {
            pendingStartAdvertising = false
            fail("无法启动 GATT 服务")
            return
        }
        val service = BluetoothGattService(
            SERVICE_UUID,
            BluetoothGattService.SERVICE_TYPE_PRIMARY,
        )
        val controlChar = BluetoothGattCharacteristic(
            CONTROL_UUID,
            BluetoothGattCharacteristic.PROPERTY_WRITE or
                BluetoothGattCharacteristic.PROPERTY_READ,
            BluetoothGattCharacteristic.PERMISSION_WRITE or
                BluetoothGattCharacteristic.PERMISSION_READ,
        )
        val dataChar = BluetoothGattCharacteristic(
            DATA_UUID,
            BluetoothGattCharacteristic.PROPERTY_WRITE,
            BluetoothGattCharacteristic.PERMISSION_WRITE,
        )
        service.addCharacteristic(controlChar)
        service.addCharacteristic(dataChar)
        gattServer?.addService(service)
    }

    private val scanCallback = object : ScanCallback() {
        override fun onScanResult(callbackType: Int, result: ScanResult) {
            if (gattClient != null) {
                return
            }
            if (isSelfPeripheral(result)) {
                return
            }
            val device = result.device ?: return
            val address = device.address ?: return
            discoveredDevices[address] = device
            emitPeerFound(address, device.name ?: "跨平台设备")
        }

        override fun onScanFailed(errorCode: Int) {
            fail("扫描失败：$errorCode")
        }
    }

    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
            // 广播已就绪，等待 Central 连接。
        }

        override fun onStartFailure(errorCode: Int) {
            fail(advertiseFailureMessage(errorCode))
        }
    }

    private val gattServerCallback = object : BluetoothGattServerCallback() {
        override fun onServiceAdded(status: Int, service: BluetoothGattService) {
            if (status != BluetoothGatt.GATT_SUCCESS) {
                pendingStartAdvertising = false
                fail("GATT 服务注册失败：$status")
                return
            }
            if (pendingStartAdvertising && service.uuid == SERVICE_UUID) {
                pendingStartAdvertising = false
                startAdvertisingInternal()
            }
        }

        override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
            when (newState) {
                BluetoothProfile.STATE_CONNECTED -> {
                    emitPeerFound(device.address, device.name ?: "跨平台设备")
                    emitPhase("connecting", "已连接，准备接收…")
                }

                BluetoothProfile.STATE_DISCONNECTED -> {
                    if (pendingResult != null && localRole == ROLE_RECEIVE) {
                        fail("连接已断开")
                    }
                }
            }
        }

        override fun onCharacteristicWriteRequest(
            device: BluetoothDevice,
            requestId: Int,
            characteristic: BluetoothGattCharacteristic,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray,
        ) {
            val deviceAddress = device.address ?: return
            val bufferKey = incomingWriteKey(deviceAddress, characteristic.uuid)
            if (preparedWrite) {
                val existing = preparedWriteBuffers[bufferKey]
                val combined = if (offset == 0 && existing == null) {
                    value.copyOf()
                } else {
                    val base = existing ?: ByteArray(offset + value.size)
                    val sized = if (base.size < offset + value.size) {
                        base.copyOf(offset + value.size)
                    } else {
                        base
                    }
                    value.copyInto(sized, offset)
                    sized
                }
                preparedWriteBuffers[bufferKey] = combined
            } else if (offset == 0) {
                if (characteristic.uuid == DATA_UUID) {
                    flushIncomingWrite(deviceAddress, DATA_UUID)
                    incomingWriteBuffers[bufferKey] = value.copyOf()
                } else if (characteristic.uuid == CONTROL_UUID) {
                    flushIncomingWrite(deviceAddress, DATA_UUID)
                }
            } else {
                mergeIncomingWrite(bufferKey, offset, value)
            }

            // Respond before handling so the central gets didWriteValueFor / write ack.
            if (responseNeeded) {
                gattServer?.sendResponse(
                    device,
                    requestId,
                    BluetoothGatt.GATT_SUCCESS,
                    offset,
                    value,
                )
            }

            if (preparedWrite) {
                return
            }
            if (characteristic.uuid == CONTROL_UUID && offset == 0) {
                handleControlWrite(value)
            }
        }

        override fun onExecuteWrite(device: BluetoothDevice, requestId: Int, execute: Boolean) {
            val deviceAddress = device.address ?: return
            gattServer?.sendResponse(
                device,
                requestId,
                if (execute) BluetoothGatt.GATT_SUCCESS else BluetoothGatt.GATT_FAILURE,
                0,
                null,
            )
            val prefix = "$deviceAddress:"
            if (execute) {
                preparedWriteBuffers.keys.filter { it.startsWith(prefix) }.toList().forEach { key ->
                    val payload = preparedWriteBuffers.remove(key) ?: return@forEach
                    when (key) {
                        "$prefix$CONTROL_UUID" -> handleControlWrite(payload)
                        "$prefix$DATA_UUID" -> handleDataWrite(payload)
                    }
                }
                flushIncomingWrite(deviceAddress, DATA_UUID)
            } else {
                preparedWriteBuffers.keys.removeAll { it.startsWith(prefix) }
                incomingWriteBuffers.keys.removeAll { it.startsWith(prefix) }
            }
        }
    }

    private val gattClientCallback = object : BluetoothGattCallback() {
        override fun onConnectionStateChange(gatt: BluetoothGatt, status: Int, newState: Int) {
            when (newState) {
                BluetoothProfile.STATE_CONNECTED -> {
                    if (status != BluetoothGatt.GATT_SUCCESS) {
                        fail("连接失败：$status")
                        return
                    }
                    servicesDiscoveryStarted = false
                    serviceDiscoveryRetryCount = 0
                    emitPhase("connecting", "已连接，发现服务…")
                    scheduleServiceDiscoveryTimeout(gatt)
                    gatt.requestConnectionPriority(BluetoothGatt.CONNECTION_PRIORITY_HIGH)
                    startServiceDiscovery(gatt)
                }

                BluetoothProfile.STATE_DISCONNECTED -> {
                    cancelServiceDiscoveryTimeout()
                    if (pendingResult != null) {
                        fail("连接已断开")
                    }
                }
            }
        }

        override fun onMtuChanged(gatt: BluetoothGatt, mtu: Int, status: Int) {
            val resolvedMtu = if (status == BluetoothGatt.GATT_SUCCESS) {
                mtu
            } else {
                negotiatedMtu.coerceAtLeast(23)
            }
            markMtuReady(gatt, resolvedMtu)
        }

        override fun onServicesDiscovered(gatt: BluetoothGatt, status: Int) {
            if (status != BluetoothGatt.GATT_SUCCESS) {
                if (retryServiceDiscovery(gatt)) {
                    return
                }
                cancelServiceDiscoveryTimeout()
                fail("发现服务失败")
                return
            }
            if (!resolveRemoteCharacteristics(gatt)) {
                if (retryServiceDiscovery(gatt)) {
                    return
                }
                cancelServiceDiscoveryTimeout()
                fail("未找到备份 GATT 服务")
                return
            }
            cancelServiceDiscoveryTimeout()
            pendingSendGatt = gatt
            mtuRequestAttempts = 0
            beginMtuExchange(gatt)
            tryStartSendTransfer(gatt)
        }

        override fun onCharacteristicWrite(
            gatt: BluetoothGatt,
            characteristic: BluetoothGattCharacteristic,
            status: Int,
        ) {
            if (status != BluetoothGatt.GATT_SUCCESS) {
                fail("写入失败")
                return
            }
            if (localRole != ROLE_SEND) {
                return
            }
            when (characteristic.uuid) {
                CONTROL_UUID -> {
                    if (!sendMetaWritten) {
                        sendMetaWritten = true
                        emitProgress(0.01)
                        mainHandler.postDelayed({ writeNextChunk(gatt) }, 50L)
                        return
                    }
                    emitProgress(1.0)
                    emitPhase("completed", "传输完成")
                    completeSuccess(null)
                }

                DATA_UUID -> onDataChunkWriteComplete(gatt)
            }
        }
    }

    private fun onDataChunkWriteComplete(gatt: BluetoothGatt) {
        sendChunkIndex += 1
        if (sendChunks.isNotEmpty()) {
            emitProgress(sendChunkIndex.toDouble() / sendChunks.size.toDouble())
        }
        if (sendChunkIndex >= sendChunks.size) {
            finishSend(gatt)
        } else {
            writeNextChunk(gatt)
        }
    }

    private fun mtuFallback(): Int {
        return negotiatedMtu.coerceAtLeast(23)
    }

    private fun cancelMtuTimeout() {
        mtuTimeoutRunnable?.let { mainHandler.removeCallbacks(it) }
        mtuTimeoutRunnable = null
    }

    private fun markMtuReady(gatt: BluetoothGatt, mtu: Int) {
        cancelMtuTimeout()
        negotiatedMtu = mtu.coerceAtLeast(23)
        isMtuReady = true
        tryStartSendTransfer(gatt)
    }

    private fun scheduleMtuTimeout(gatt: BluetoothGatt) {
        cancelMtuTimeout()
        mtuTimeoutRunnable = Runnable {
            mtuTimeoutRunnable = null
            if (isMtuReady || pendingResult == null || localRole != ROLE_SEND) {
                return@Runnable
            }
            if (mtuRequestAttempts < 2) {
                beginMtuExchange(gatt)
                return@Runnable
            }
            markMtuReady(gatt, mtuFallback())
        }
        mainHandler.postDelayed(mtuTimeoutRunnable!!, MTU_TIMEOUT_MS)
    }

    private fun beginMtuExchange(gatt: BluetoothGatt) {
        if (isMtuReady || localRole != ROLE_SEND || pendingResult == null) {
            return
        }
        if (!gatt.requestMtu(REQUESTED_MTU)) {
            mtuQueueRetryCount += 1
            if (mtuQueueRetryCount >= 5) {
                mtuQueueRetryCount = 0
                markMtuReady(gatt, mtuFallback())
                return
            }
            mainHandler.postDelayed({ beginMtuExchange(gatt) }, 300L)
            return
        }
        mtuQueueRetryCount = 0
        mtuRequestAttempts += 1
        scheduleMtuTimeout(gatt)
    }

    private fun tryStartSendTransfer(gatt: BluetoothGatt) {
        if (sendTransferStarted || localRole != ROLE_SEND || pendingResult == null) {
            return
        }
        if (!isMtuReady || remoteControlCharacteristic == null) {
            return
        }
        val maxWriteBytes = negotiatedMtu - ATT_WRITE_OVERHEAD - ATT_WRITE_SAFETY_MARGIN
        if (maxWriteBytes < HEADER_SIZE + 1) {
            fail("蓝牙 MTU 过小（$negotiatedMtu），无法传输备份")
            return
        }
        val oversized = sendChunks.firstOrNull { it.size > maxWriteBytes }
        if (oversized != null) {
            fail(
                "分片 ${oversized.size} 字节超过当前 MTU 单包上限 $maxWriteBytes，请更新应用后重试",
            )
            return
        }
        sendTransferStarted = true
        pendingSendGatt = null
        startSendTransfer(gatt)
    }

    private fun startSendTransfer(gatt: BluetoothGatt) {
        val control = remoteControlCharacteristic ?: return
        val sessionMeta = sendSessionMeta ?: return
        if (sendChunks.isEmpty()) {
            fail("发送参数无效")
            return
        }
        mainHandler.removeCallbacks(timeoutRunnable)
        scheduleTransferTimeout()
        emitPhase("transferring", "正在传输… 0%")
        val metaPayload = makeControlPayload(type = "meta", sessionMeta = sessionMeta)
        if (!gattWrite(
                gatt,
                control,
                metaPayload,
                BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT,
            )
        ) {
            fail("写入失败")
        }
    }

    private fun scheduleTransferTimeout() {
        mainHandler.removeCallbacks(transferTimeoutRunnable)
        mainHandler.postDelayed(transferTimeoutRunnable, TRANSFER_TIMEOUT_MS)
    }

    private fun cancelTransferTimeout() {
        mainHandler.removeCallbacks(transferTimeoutRunnable)
    }

    private fun writeNextChunk(gatt: BluetoothGatt) {
        val dataChar = remoteDataCharacteristic ?: return
        if (sendChunkIndex >= sendChunks.size) {
            finishSend(gatt)
            return
        }
        val chunk = sendChunks[sendChunkIndex]
        if (!gattWrite(
                gatt,
                dataChar,
                chunk,
                BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT,
            )
        ) {
            fail("写入失败")
        }
    }

    private fun finishSend(gatt: BluetoothGatt) {
        val control = remoteControlCharacteristic ?: return
        val endPayload = makeControlPayload(type = "end", chunkCount = sendChunks.size)
        if (!gattWrite(
                gatt,
                control,
                endPayload,
                BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT,
            )
        ) {
            fail("写入失败")
        }
    }

    private fun startServiceDiscovery(gatt: BluetoothGatt) {
        if (servicesDiscoveryStarted) {
            return
        }
        servicesDiscoveryStarted = true
        if (!gatt.discoverServices()) {
            servicesDiscoveryStarted = false
            fail("无法启动服务发现")
        }
    }

    private fun retryServiceDiscovery(gatt: BluetoothGatt): Boolean {
        if (serviceDiscoveryRetryCount >= 2) {
            return false
        }
        serviceDiscoveryRetryCount += 1
        servicesDiscoveryStarted = false
        mainHandler.postDelayed({ startServiceDiscovery(gatt) }, 400L)
        return true
    }

    private fun resolveRemoteCharacteristics(gatt: BluetoothGatt): Boolean {
        val service = gatt.services?.firstOrNull { it.uuid == SERVICE_UUID } ?: return false
        remoteControlCharacteristic = service.getCharacteristic(CONTROL_UUID)
        remoteDataCharacteristic = service.getCharacteristic(DATA_UUID)
        if (remoteControlCharacteristic == null || remoteDataCharacteristic == null) {
            return false
        }
        return true
    }

    private fun scheduleServiceDiscoveryTimeout(gatt: BluetoothGatt) {
        cancelServiceDiscoveryTimeout()
        serviceDiscoveryTimeoutRunnable = Runnable {
            if (pendingResult != null &&
                localRole == ROLE_SEND &&
                remoteControlCharacteristic == null
            ) {
                if (retryServiceDiscovery(gatt)) {
                    scheduleServiceDiscoveryTimeout(gatt)
                    return@Runnable
                }
                fail("发现服务超时，请重试")
            }
        }
        mainHandler.postDelayed(serviceDiscoveryTimeoutRunnable!!, 12_000L)
    }

    private fun cancelServiceDiscoveryTimeout() {
        serviceDiscoveryTimeoutRunnable?.let { mainHandler.removeCallbacks(it) }
        serviceDiscoveryTimeoutRunnable = null
    }

    private fun gattWrite(
        gatt: BluetoothGatt,
        characteristic: BluetoothGattCharacteristic,
        value: ByteArray,
        writeType: Int,
    ): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            gatt.writeCharacteristic(
                characteristic,
                value,
                writeType,
            ) == BluetoothStatusCodes.SUCCESS
        } else {
            @Suppress("DEPRECATION")
            characteristic.value = value
            @Suppress("DEPRECATION")
            characteristic.writeType = writeType
            @Suppress("DEPRECATION")
            gatt.writeCharacteristic(characteristic)
        }
    }

    private fun handleControlWrite(data: ByteArray) {
        val control = parseControlPayload(data) ?: return
        when (control.optString("type")) {
            "meta" -> {
                mainHandler.removeCallbacks(timeoutRunnable)
                scheduleTransferTimeout()
                receivedSessionMeta = control.optString("sessionMeta")
                expectedChunkCount = parseChunkCountFromSessionMeta(receivedSessionMeta)
                    ?: expectedChunkCount
                emitPhase("transferring", "正在接收备份… 0%")
            }

            "end" -> {
                val endCount = control.optInt("chunkCount")
                if (endCount > 0) {
                    expectedChunkCount = endCount
                }
                tryCompleteReceive()
            }
        }
    }

    private fun handleDataWrite(data: ByteArray) {
        receivedChunks.add(data)
        expectedChunkCount?.let { expected ->
            if (expected > 0) {
                emitProgress(receivedChunks.size.toDouble() / expected.toDouble())
            }
        }
    }

    private fun incomingWriteKey(deviceAddress: String, uuid: UUID): String =
        "$deviceAddress:$uuid"

    private fun mergeIncomingWrite(key: String, offset: Int, value: ByteArray) {
        val end = offset + value.size
        val existing = incomingWriteBuffers[key]
        val combined = if (offset == 0 && existing == null) {
            value.copyOf()
        } else {
            val base = existing ?: ByteArray(end)
            val sized = if (base.size < end) base.copyOf(end) else base
            value.copyInto(sized, offset)
            sized
        }
        incomingWriteBuffers[key] = combined
    }

    private fun flushIncomingWrite(deviceAddress: String, uuid: UUID) {
        val key = incomingWriteKey(deviceAddress, uuid)
        val payload = incomingWriteBuffers.remove(key) ?: return
        if (payload.isEmpty()) {
            return
        }
        when (uuid) {
            CONTROL_UUID -> handleControlWrite(payload)
            DATA_UUID -> handleDataWrite(payload)
        }
    }

    private fun tryCompleteReceive() {
        if (localRole != ROLE_RECEIVE) {
            return
        }
        val expected = expectedChunkCount ?: return
        if (receivedChunks.size < expected) {
            return
        }
        emitProgress(1.0)
        emitPhase("completed")
        completeSuccess(
            mapOf(
                "sessionMeta" to (receivedSessionMeta ?: ""),
                "chunks" to receivedChunks.toList(),
            ),
        )
    }

    private fun makeControlPayload(
        type: String,
        sessionMeta: String? = null,
        chunkCount: Int? = null,
    ): ByteArray {
        val json = JSONObject()
        json.put("type", type)
        if (sessionMeta != null) {
            json.put("sessionMeta", sessionMeta)
        }
        if (chunkCount != null) {
            json.put("chunkCount", chunkCount)
        }
        return json.toString().toByteArray(Charsets.UTF_8)
    }

    private fun parseControlPayload(data: ByteArray): JSONObject? {
        return try {
            JSONObject(String(data, Charsets.UTF_8))
        } catch (_: Exception) {
            null
        }
    }

    private fun parseChunkCountFromSessionMeta(sessionMeta: String?): Int? {
        if (sessionMeta.isNullOrBlank()) {
            return null
        }
        return try {
            val count = JSONObject(sessionMeta).optInt("chunkCount", -1)
            if (count > 0) count else null
        } catch (_: Exception) {
            null
        }
    }

    private fun scheduleTimeout() {
        mainHandler.removeCallbacks(timeoutRunnable)
        mainHandler.postDelayed(timeoutRunnable, DISCOVERY_TIMEOUT_MS)
    }

    private fun resetDiscoveryState() {
        servicesDiscoveryStarted = false
        serviceDiscoveryRetryCount = 0
        discoveredDevices.clear()
        remoteControlCharacteristic = null
        remoteDataCharacteristic = null
        negotiatedMtu = 23
        isMtuReady = false
        sendTransferStarted = false
        pendingSendGatt = null
        mtuRequestAttempts = 0
        mtuQueueRetryCount = 0
        cancelMtuTimeout()
    }

    private fun resetTransferState() {
        sendMetaWritten = false
        sendSessionMeta = null
        sendChunks = emptyList()
        sendChunkIndex = 0
        receivedSessionMeta = null
        receivedChunks = mutableListOf()
        expectedChunkCount = null
        preparedWriteBuffers.clear()
        incomingWriteBuffers.clear()
    }

    private fun cleanup() {
        mainHandler.removeCallbacks(timeoutRunnable)
        cancelTransferTimeout()
        cancelServiceDiscoveryTimeout()
        cancelMtuTimeout()
        bluetoothStateMonitor?.stop()
        bluetoothStateMonitor = null
        pendingStartAdvertising = false
        advertiser?.stopAdvertising(advertiseCallback)
        scanner?.stopScan(scanCallback)
        gattClient?.close()
        gattClient = null
        gattServer?.close()
        gattServer = null
        remoteControlCharacteristic = null
        remoteDataCharacteristic = null
        discoveredDevices.clear()
        pendingResult = null
        pendingPermissionAction = null
        resetTransferState()
        localRole = ""
    }

    private fun completeSuccess(value: Any?) {
        val result = pendingResult
        cleanup()
        result?.success(value)
    }

    private fun fail(message: String) {
        if (pendingResult == null) {
            return
        }
        emitError(message)
        val result = pendingResult
        cleanup()
        result?.error("backup_ble_gatt", message, null)
    }

    private fun beginBluetoothSessionMonitoring() {
        bluetoothStateMonitor?.stop()
        bluetoothStateMonitor = BackupBluetoothStateMonitor(activity, mainHandler) {
            fail(BLUETOOTH_DISABLED_MESSAGE)
        }.also { it.start() }
    }

    private fun ensurePermissions(onGranted: () -> Unit) {
        val missing = requiredPermissions().filter {
            ContextCompat.checkSelfPermission(activity, it) != PackageManager.PERMISSION_GRANTED
        }
        if (missing.isEmpty()) {
            onGranted()
            return
        }
        pendingPermissionAction = onGranted
        ActivityCompat.requestPermissions(
            activity,
            missing.toTypedArray(),
            PERMISSION_REQUEST_CODE,
        )
    }

    private fun requiredPermissions(): List<String> {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            listOf(
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_ADVERTISE,
                Manifest.permission.BLUETOOTH_CONNECT,
            )
        } else {
            listOf(
                Manifest.permission.BLUETOOTH,
                Manifest.permission.BLUETOOTH_ADMIN,
                Manifest.permission.ACCESS_FINE_LOCATION,
            )
        }
    }

    private fun emitPhase(phase: String, message: String? = null) {
        val event = mutableMapOf<String, Any?>(
            "type" to "phase",
            "phase" to phase,
        )
        if (message != null) {
            event["message"] = message
        }
        BackupP2pEventBridge.emit(event)
    }

    private fun emitPeerFound(peerId: String, displayName: String) {
        BackupP2pEventBridge.emit(
            mapOf(
                "type" to "peerFound",
                "peerId" to peerId,
                "displayName" to displayName,
            ),
        )
    }

    private fun emitProgress(value: Double) {
        BackupP2pEventBridge.emit(mapOf("type" to "progress", "value" to value))
    }

    private fun emitError(message: String) {
        BackupP2pEventBridge.emit(mapOf("type" to "error", "message" to message))
    }

    private fun advertiseFailureMessage(errorCode: Int): String {
        val reason = when (errorCode) {
            AdvertiseCallback.ADVERTISE_FAILED_DATA_TOO_LARGE -> "广播数据过大"
            AdvertiseCallback.ADVERTISE_FAILED_TOO_MANY_ADVERTISERS -> "广播占用过多"
            AdvertiseCallback.ADVERTISE_FAILED_ALREADY_STARTED -> "广播已在进行"
            AdvertiseCallback.ADVERTISE_FAILED_INTERNAL_ERROR -> "系统内部错误"
            AdvertiseCallback.ADVERTISE_FAILED_FEATURE_UNSUPPORTED -> "不支持 BLE 广播"
            else -> "未知错误($errorCode)"
        }
        return "广播失败：$reason"
    }

    companion object {
        private const val CHANNEL = "com.barrellock/backup_ble_gatt"
        private val SERVICE_UUID =
            UUID.fromString("A7B4C3D2-E5F6-4789-A012-3456789ABCDE")
        private val CONTROL_UUID =
            UUID.fromString("A7B4C3D2-E5F6-4789-A012-3456789ABC01")
        private val DATA_UUID =
            UUID.fromString("A7B4C3D2-E5F6-4789-A012-3456789ABC02")
        private const val DISCOVERY_TIMEOUT_MS = 180_000L
        private const val TRANSFER_TIMEOUT_MS = 600_000L
        private const val MTU_TIMEOUT_MS = 3_000L
        private const val REQUESTED_MTU = 517
        private const val ATT_WRITE_OVERHEAD = 3
        private const val ATT_WRITE_SAFETY_MARGIN = 2
        private const val HEADER_SIZE = 20
        private const val PERMISSION_REQUEST_CODE = 0x424C47
        private const val ROLE_SEND = "send"
        private const val ROLE_RECEIVE = "receive"
        private const val BLUETOOTH_DISABLED_MESSAGE = "蓝牙已关闭，请打开后重试"

        fun register(
            activity: FlutterFragmentActivity,
            messenger: BinaryMessenger,
        ): BackupBleGattHandler {
            val channel = MethodChannel(messenger, CHANNEL)
            val handler = BackupBleGattHandler(activity, channel)
            channel.setMethodCallHandler(handler)
            return handler
        }
    }
}
