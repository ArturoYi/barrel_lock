package com.hulk.bazaarAndroid

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel

/** Shared EventChannel sink for Nearby + BLE GATT backup sessions. */
object BackupP2pEventBridge : EventChannel.StreamHandler {
    private const val EVENT_CHANNEL = "com.barrellock/backup_p2p_events"

    private val mainHandler = Handler(Looper.getMainLooper())
    private var eventSink: EventChannel.EventSink? = null

    fun register(messenger: BinaryMessenger) {
        EventChannel(messenger, EVENT_CHANNEL).setStreamHandler(this)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun emit(event: Map<String, Any?>) {
        mainHandler.post { eventSink?.success(event) }
    }
}
