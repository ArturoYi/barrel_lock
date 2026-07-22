package com.hulk.bazaarAndroid

import android.bluetooth.BluetoothAdapter
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import com.google.android.gms.nearby.Nearby
import com.google.android.gms.nearby.connection.AdvertisingOptions
import com.google.android.gms.nearby.connection.ConnectionInfo
import com.google.android.gms.nearby.connection.ConnectionLifecycleCallback
import com.google.android.gms.nearby.connection.ConnectionResolution
import com.google.android.gms.nearby.connection.ConnectionsClient
import com.google.android.gms.nearby.connection.ConnectionsStatusCodes
import com.google.android.gms.nearby.connection.DiscoveryOptions
import com.google.android.gms.nearby.connection.EndpointDiscoveryCallback
import com.google.android.gms.nearby.connection.Payload
import com.google.android.gms.nearby.connection.PayloadCallback
import com.google.android.gms.nearby.connection.PayloadTransferUpdate
import com.google.android.gms.nearby.connection.Strategy
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.nio.charset.StandardCharsets

/// Nearby Connections P2P transport for BLBT backup frames.
///
/// Control packets: `[BLBC]` + UTF-8 JSON. Data packets: raw BLBT frames from Dart.
class BackupNearbyHandler private constructor(
    private val activity: FlutterFragmentActivity,
    private val channel: MethodChannel,
) : MethodChannel.MethodCallHandler {
    private val connectionsClient: ConnectionsClient = Nearby.getConnectionsClient(activity)
    private val mainHandler = Handler(Looper.getMainLooper())

    private var pendingResult: MethodChannel.Result? = null
    private var localRole = ""
    private var expectedPeerRole = ""
    private var hasRequestedConnection = false
    private var transferStarted = false
    private var connectedEndpointId: String? = null

    private var sendSessionMeta: String? = null
    private var sendFrames: List<ByteArray> = emptyList()

    private var receivedFrames = mutableListOf<ByteArray>()
    private var receivedSessionMeta: String? = null
    private var expectedFrameCount: Int? = null

    private var pendingPermissionAction: (() -> Unit)? = null
    private var bluetoothStateMonitor: BackupBluetoothStateMonitor? = null
    private val bluetoothAdapter: BluetoothAdapter? = BluetoothAdapter.getDefaultAdapter()

    private val localDeviceId: String by lazy {
        Settings.Secure.getString(activity.contentResolver, Settings.Secure.ANDROID_ID)
            ?: Build.FINGERPRINT
    }

    private val timeoutRunnable = Runnable {
        fail("连接超时，请确认对端已打开并开始传输")
    }

    private val connectionLifecycleCallback = object : ConnectionLifecycleCallback() {
        override fun onConnectionInitiated(endpointId: String, connectionInfo: ConnectionInfo) {
            connectionsClient.acceptConnection(endpointId, payloadCallback)
        }

        override fun onConnectionResult(endpointId: String, result: ConnectionResolution) {
            mainHandler.post {
                when (result.status.statusCode) {
                    ConnectionsStatusCodes.STATUS_OK -> {
                        connectedEndpointId = endpointId
                        transferStarted = true
                        mainHandler.removeCallbacks(timeoutRunnable)
                        emitPhase("connecting", "已连接，准备传输…")
                        if (localRole == ROLE_SEND) {
                            performSend(endpointId)
                        } else {
                            emitPhase("transferring", "等待接收备份…")
                        }
                    }

                    else -> fail("连接失败：${result.status.statusMessage ?: result.status}")
                }
            }
        }

        override fun onDisconnected(endpointId: String) {
            mainHandler.post {
                if (transferStarted && localRole == ROLE_RECEIVE) {
                    fail("连接已断开")
                }
            }
        }
    }

    private val endpointDiscoveryCallback = object : EndpointDiscoveryCallback() {
        override fun onEndpointFound(endpointId: String, info: com.google.android.gms.nearby.connection.DiscoveredEndpointInfo) {
            val endpoint = parseEndpoint(info.endpointName)
            if (endpoint.deviceId == localDeviceId) {
                return
            }
            if (endpoint.role != expectedPeerRole) {
                return
            }
            emitPeerFound(endpointId, endpoint.displayName)
        }

        override fun onEndpointLost(endpointId: String) {
            emitPeerLost(endpointId)
        }
    }

    private val payloadCallback = object : PayloadCallback() {
        override fun onPayloadReceived(endpointId: String, payload: Payload) {
            if (payload.type != Payload.Type.BYTES) {
                return
            }
            val bytes = payload.asBytes() ?: return
            mainHandler.post { handleReceivedData(bytes) }
        }

        override fun onPayloadTransferUpdate(endpointId: String, update: PayloadTransferUpdate) {}
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

    fun onRequestPermissionsResult(
        requestCode: Int,
        grantResults: IntArray,
    ) {
        if (requestCode != PERMISSION_REQUEST_CODE) {
            return
        }
        val action = pendingPermissionAction
        pendingPermissionAction = null
        if (grantResults.isNotEmpty() && grantResults.all { it == android.content.pm.PackageManager.PERMISSION_GRANTED }) {
            action?.invoke()
        } else {
            fail("需要蓝牙与附近设备权限才能传输备份")
        }
    }

    private fun handleTransferSend(call: MethodCall, result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("backup_nearby", "已有传输进行中", null)
            return
        }
        val args = call.arguments as? Map<*, *>
        val sessionMeta = args?.get("sessionMeta") as? String
        @Suppress("UNCHECKED_CAST")
        val framesRaw = args?.get("frames") as? List<*>
        val frames = framesRaw?.mapNotNull { item ->
            when (item) {
                is ByteArray -> item
                else -> null
            }
        } ?: emptyList()
        if (sessionMeta == null || frames.isEmpty()) {
            result.error("backup_nearby", "发送参数无效", null)
            return
        }

        pendingResult = result
        sendSessionMeta = sessionMeta
        sendFrames = frames
        localRole = ROLE_SEND
        expectedPeerRole = ROLE_RECEIVE
        ensurePermissions { startDiscovery() }
    }

    private fun handleTransferReceive(result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("backup_nearby", "已有传输进行中", null)
            return
        }
        pendingResult = result
        localRole = ROLE_RECEIVE
        expectedPeerRole = ROLE_SEND
        ensurePermissions { startDiscovery() }
    }

    private fun handleConnectPeer(call: MethodCall, result: MethodChannel.Result) {
        val peerId = call.arguments as? String
        if (peerId.isNullOrBlank()) {
            result.error("backup_nearby", "设备 ID 无效", null)
            return
        }
        if (pendingResult == null || localRole != ROLE_SEND) {
            result.error("backup_nearby", "当前不在发送会话中", null)
            return
        }
        if (hasRequestedConnection) {
            result.success(null)
            return
        }
        hasRequestedConnection = true
        emitPhase("connecting", "正在连接…")
        connectionsClient.requestConnection(
            localEndpointName(),
            peerId,
            connectionLifecycleCallback,
        )
        result.success(null)
    }

    private fun startDiscovery() {
        if (localRole == ROLE_SEND) {
            resetDiscoveryState()
        } else {
            resetTransferState()
        }
        emitPhase("discovering")
        beginBluetoothSessionMonitoring()
        if (!isBluetoothEnabled(bluetoothAdapter)) {
            fail(BLUETOOTH_DISABLED_MESSAGE)
            return
        }
        val strategy = Strategy.P2P_POINT_TO_POINT
        val serviceId = SERVICE_ID

        connectionsClient.startAdvertising(
            localEndpointName(),
            serviceId,
            connectionLifecycleCallback,
            AdvertisingOptions.Builder().setStrategy(strategy).build(),
        )
        connectionsClient.startDiscovery(
            serviceId,
            endpointDiscoveryCallback,
            DiscoveryOptions.Builder().setStrategy(strategy).build(),
        )
        mainHandler.postDelayed(timeoutRunnable, DISCOVERY_TIMEOUT_MS)
    }

    private fun performSend(endpointId: String) {
        val sessionMeta = sendSessionMeta
        if (sessionMeta == null) {
            fail("未找到会话元数据")
            return
        }

        val payloads = buildList {
            add(makeControlPacket("meta", sessionMeta = sessionMeta))
            addAll(sendFrames)
            add(makeControlPacket("end", frameCount = sendFrames.size))
        }
        emitPhase("transferring", "正在发送备份…")
        sendPayloadsSequentially(
            endpointId = endpointId,
            payloads = payloads,
            index = 0,
            onComplete = {
                emitPhase("completed", "发送完成")
                completeSuccess(null)
            },
            onError = { fail("发送失败：${it.message ?: it}") },
        )
    }

    private fun sendPayloadsSequentially(
        endpointId: String,
        payloads: List<ByteArray>,
        index: Int,
        onComplete: () -> Unit,
        onError: (Exception) -> Unit,
    ) {
        if (index >= payloads.size) {
            onComplete()
            return
        }
        emitProgress(index.toDouble() / payloads.size.toDouble())
        connectionsClient
            .sendPayload(endpointId, Payload.fromBytes(payloads[index]))
            .addOnSuccessListener {
                sendPayloadsSequentially(endpointId, payloads, index + 1, onComplete, onError)
            }
            .addOnFailureListener { onError(it as? Exception ?: Exception(it.message)) }
    }

    private fun handleReceivedData(data: ByteArray) {
        val control = parseControlPacket(data)
        if (control != null) {
            when (control.optString("type")) {
                "meta" -> receivedSessionMeta = control.optString("sessionMeta")
                "end" -> expectedFrameCount = control.optInt("frameCount")
            }
            tryCompleteReceive()
            return
        }
        receivedFrames.add(data)
        tryCompleteReceive()
    }

    private fun tryCompleteReceive() {
        val expected = expectedFrameCount ?: return
        if (receivedFrames.size != expected) {
            return
        }
        emitPhase("completed", "接收完成")
        emitProgress(1.0)
        completeSuccess(
            mapOf(
                "sessionMeta" to (receivedSessionMeta ?: ""),
                "frames" to receivedFrames.toList(),
            ),
        )
    }

    private fun makeControlPacket(
        type: String,
        sessionMeta: String? = null,
        frameCount: Int? = null,
    ): ByteArray {
        val json = JSONObject()
        json.put("type", type)
        if (sessionMeta != null) {
            json.put("sessionMeta", sessionMeta)
        }
        if (frameCount != null) {
            json.put("frameCount", frameCount)
        }
        val body = json.toString().toByteArray(StandardCharsets.UTF_8)
        return CONTROL_MAGIC + body
    }

    private fun parseControlPacket(data: ByteArray): JSONObject? {
        if (data.size <= CONTROL_MAGIC.size) {
            return null
        }
        for (index in CONTROL_MAGIC.indices) {
            if (data[index] != CONTROL_MAGIC[index]) {
                return null
            }
        }
        val jsonText = String(data, CONTROL_MAGIC.size, data.size - CONTROL_MAGIC.size, StandardCharsets.UTF_8)
        return runCatching { JSONObject(jsonText) }.getOrNull()
    }

    private data class ParsedEndpoint(
        val displayName: String,
        val deviceId: String,
        val role: String,
    )

    /// Format: `{displayName}|{deviceId}|{role}` — deviceId filters self during discovery.
    private fun parseEndpoint(endpointName: String): ParsedEndpoint {
        val roleSeparator = endpointName.lastIndexOf('|')
        if (roleSeparator < 0 || roleSeparator >= endpointName.length - 1) {
            return ParsedEndpoint(endpointName, "", "")
        }
        val role = endpointName.substring(roleSeparator + 1)
        val rest = endpointName.substring(0, roleSeparator)
        val deviceSeparator = rest.lastIndexOf('|')
        if (deviceSeparator < 0) {
            return ParsedEndpoint(rest, "", role)
        }
        return ParsedEndpoint(
            displayName = rest.substring(0, deviceSeparator),
            deviceId = rest.substring(deviceSeparator + 1),
            role = role,
        )
    }

    private fun emitPhase(phase: String, message: String? = null) {
        val event = mutableMapOf<String, Any?>(
            "type" to "phase",
            "phase" to phase,
        )
        if (message != null) {
            event["message"] = message
        }
        emit(event)
    }

    private fun emitPeerFound(peerId: String, displayName: String) {
        emit(
            mapOf(
                "type" to "peerFound",
                "peerId" to peerId,
                "displayName" to displayName,
            ),
        )
    }

    private fun emitPeerLost(peerId: String) {
        emit(mapOf("type" to "peerLost", "peerId" to peerId))
    }

    private fun emitProgress(value: Double) {
        emit(mapOf("type" to "progress", "value" to value))
    }

    private fun emitError(message: String) {
        emit(mapOf("type" to "error", "message" to message))
    }

    private fun emit(event: Map<String, Any?>) {
        BackupP2pEventBridge.emit(event)
    }

    private fun localEndpointName(): String = "${Build.MODEL}|$localDeviceId|$localRole"

    private fun resetDiscoveryState() {
        hasRequestedConnection = false
        transferStarted = false
        connectedEndpointId = null
    }

    private fun resetTransferState() {
        hasRequestedConnection = false
        transferStarted = false
        connectedEndpointId = null
        sendSessionMeta = null
        sendFrames = emptyList()
        receivedFrames = mutableListOf()
        receivedSessionMeta = null
        expectedFrameCount = null
    }

    private fun cleanup() {
        mainHandler.removeCallbacks(timeoutRunnable)
        bluetoothStateMonitor?.stop()
        bluetoothStateMonitor = null
        connectionsClient.stopAdvertising()
        connectionsClient.stopDiscovery()
        connectedEndpointId?.let { connectionsClient.disconnectFromEndpoint(it) }
        connectionsClient.stopAllEndpoints()
        pendingResult = null
        pendingPermissionAction = null
        resetTransferState()
        localRole = ""
        expectedPeerRole = ""
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
        result?.error("backup_nearby", message, null)
    }

    private fun beginBluetoothSessionMonitoring() {
        bluetoothStateMonitor?.stop()
        bluetoothStateMonitor = BackupBluetoothStateMonitor(activity, mainHandler) {
            fail(BLUETOOTH_DISABLED_MESSAGE)
        }.also { it.start() }
    }

    private fun ensurePermissions(onGranted: () -> Unit) {
        val missing = requiredPermissions().filter {
            androidx.core.content.ContextCompat.checkSelfPermission(activity, it) !=
                android.content.pm.PackageManager.PERMISSION_GRANTED
        }
        if (missing.isEmpty()) {
            onGranted()
            return
        }
        pendingPermissionAction = onGranted
        androidx.core.app.ActivityCompat.requestPermissions(
            activity,
            missing.toTypedArray(),
            PERMISSION_REQUEST_CODE,
        )
    }

    private fun requiredPermissions(): List<String> {
        val permissions = mutableListOf(
            android.Manifest.permission.ACCESS_WIFI_STATE,
            android.Manifest.permission.CHANGE_WIFI_STATE,
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            permissions += listOf(
                android.Manifest.permission.BLUETOOTH_SCAN,
                android.Manifest.permission.BLUETOOTH_ADVERTISE,
                android.Manifest.permission.BLUETOOTH_CONNECT,
            )
        } else {
            permissions += listOf(
                android.Manifest.permission.BLUETOOTH,
                android.Manifest.permission.BLUETOOTH_ADMIN,
                android.Manifest.permission.ACCESS_FINE_LOCATION,
                android.Manifest.permission.ACCESS_COARSE_LOCATION,
            )
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            permissions += android.Manifest.permission.NEARBY_WIFI_DEVICES
        }
        return permissions
    }

    companion object {
        private const val CHANNEL = "com.barrellock/backup_nearby"
        private const val EVENT_CHANNEL = "com.barrellock/backup_p2p_events"
        private const val SERVICE_ID = "com.hulk.bazaarAndroid.backup"
        private val CONTROL_MAGIC = byteArrayOf(0x42, 0x4C, 0x42, 0x43)
        private const val DISCOVERY_TIMEOUT_MS = 120_000L
        private const val PERMISSION_REQUEST_CODE = 0x424C42
        private const val ROLE_SEND = "send"
        private const val ROLE_RECEIVE = "receive"
        private const val BLUETOOTH_DISABLED_MESSAGE = "蓝牙已关闭，请打开后重试"

        fun register(
            activity: FlutterFragmentActivity,
            messenger: BinaryMessenger,
        ): BackupNearbyHandler {
            val channel = MethodChannel(messenger, CHANNEL)
            val handler = BackupNearbyHandler(activity, channel)
            channel.setMethodCallHandler(handler)
            return handler
        }
    }
}
