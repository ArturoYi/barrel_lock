package com.flutterbazaar.fast_lifecycle

import android.app.Activity
import android.app.Application
import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Android 系统原生层入口（架构第 ④ 层）。
 *
 * ## 通道规范（需求文档 §3）
 * | 通道 | 名称 | 职责 |
 * |------|------|------|
 * | EventChannel | fast_lifecycle/events | 流式推送 rawState（唯一事件通道） |
 * | MethodChannel | fast_lifecycle/control | startListening / stopListening |
 *
 * ## 架构红线
 * - 禁止用 MethodChannel 推送持续生命周期事件
 * - 禁止翻译 / 重命名 rawState（输出 AppLifecycleState 原字符串）
 * - stopListening / Engine 分离时必须移除原生订阅
 */
class FastLifecyclePlugin :
    FlutterPlugin,
    MethodCallHandler,
    EventChannel.StreamHandler,
    ActivityAware {

    private lateinit var applicationContext: Context
    private lateinit var controlChannel: MethodChannel
    private var eventChannel: EventChannel? = null
    private var eventSink: EventChannel.EventSink? = null

    private var tracker: AppLifecycleTracker? = null
    private var pendingActivity: Activity? = null
    private var listeningRequested = false
    private var listenWindowId: String? = null
    private var listenIsMainWindow: Boolean = true

    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = binding.applicationContext

        controlChannel = MethodChannel(binding.binaryMessenger, CONTROL_CHANNEL)
        controlChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, EVENT_CHANNEL)
        eventChannel?.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            METHOD_START_LISTENING -> {
                parseListenArguments(call.arguments)
                requestNativeListening()
                result.success(null)
            }
            METHOD_STOP_LISTENING -> {
                stopNativeListening()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        parseListenArguments(arguments)
        requestNativeListening()
    }

    override fun onCancel(arguments: Any?) {
        stopNativeListening()
        eventSink = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        stopNativeListening()
        controlChannel.setMethodCallHandler(null)
        eventChannel?.setStreamHandler(null)
        eventSink = null
    }

    // ── ActivityAware：绑定 Flutter Activity 生命周期 ─────────────────

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        pendingActivity = binding.activity
        tracker?.bindActivity(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        tracker?.unbindActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        pendingActivity = binding.activity
        tracker?.bindActivity(binding.activity)
    }

    override fun onDetachedFromActivity() {
        pendingActivity = null
        tracker?.unbindActivity()
    }

    // ── 内部方法 ──────────────────────────────────────────────────────

    private fun parseListenArguments(arguments: Any?) {
        if (arguments !is Map<*, *>) return
        listenWindowId = arguments["windowId"] as? String
        listenIsMainWindow = arguments["isMainWindow"] as? Boolean ?: true
    }

    /**
     * 标记需要监听；仅当 [EventChannel] 已就绪（[eventSink] 非空）时才启动 Tracker，
     * 避免 MethodChannel 先于 EventChannel 订阅时丢失事件。
     */
    private fun requestNativeListening() {
        listeningRequested = true
        tryStartNativeListening()
    }

    private fun tryStartNativeListening() {
        if (tracker != null || !listeningRequested || eventSink == null) {
            return
        }

        val app = applicationContext.applicationContext as Application
        tracker = AppLifecycleTracker(
            onEvent = ::emitEvent,
            windowId = listenWindowId,
            isMainWindow = listenIsMainWindow,
        )
        tracker?.start(app)
        pendingActivity?.let { tracker?.bindActivity(it) }
    }

    private fun emitEvent(payload: Map<String, Any?>) {
        val sink = eventSink ?: return
        if (Looper.myLooper() == Looper.getMainLooper()) {
            sink.success(payload)
            return
        }
        mainHandler.post {
            eventSink?.success(payload)
        }
    }

    private fun stopNativeListening() {
        listeningRequested = false
        val app = applicationContext.applicationContext as? Application ?: return
        tracker?.stop(app)
        tracker?.unbindActivity()
        tracker = null
    }

    companion object {
        private const val EVENT_CHANNEL = "fast_lifecycle/events"
        private const val CONTROL_CHANNEL = "fast_lifecycle/control"
        private const val METHOD_START_LISTENING = "startListening"
        private const val METHOD_STOP_LISTENING = "stopListening"
    }
}
