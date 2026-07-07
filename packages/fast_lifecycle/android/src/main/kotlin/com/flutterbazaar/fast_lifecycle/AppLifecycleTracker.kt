package com.flutterbazaar.fast_lifecycle

import android.app.Activity
import android.app.Application

/**
 * Android 原生生命周期采集器（进程 + Activity 双层）。
 *
 * ## rawState 规范（需求文档 §4.2）
 * - 进程层：`ProcessLifecycleOwner` → `ON_*`，`lifecycleScope = process`
 * - Activity 层：Flutter Activity → `ON_*`，`lifecycleScope = activity`
 *
 * 禁止映射为 Flutter AppLifecycleState 四态。
 */
internal class AppLifecycleTracker(
    private val onEvent: (Map<String, Any?>) -> Unit,
    private val windowId: String? = null,
    private val isMainWindow: Boolean = true,
) {
    private val emitter = LifecycleEventEmitter(
        onEvent = onEvent,
        windowId = windowId,
        isMainWindow = isMainWindow,
    )
    private val processTracker = ProcessLifecycleTracker(emitter)
    private val activityTracker = ActivityLifecycleTracker(emitter)

    private var isListening = false
    private var pendingActivity: Activity? = null

    fun start(application: Application) {
        if (isListening) return
        isListening = true
        processTracker.start()
        pendingActivity?.let { activityTracker.bindActivity(it) }
    }

    fun stop(application: Application) {
        if (!isListening) return
        isListening = false
        processTracker.stop()
        activityTracker.unbindActivity()
        emitter.reset()
    }

    fun bindActivity(activity: Activity) {
        pendingActivity = activity
        if (isListening) {
            activityTracker.bindActivity(activity)
        }
    }

    fun unbindActivity() {
        pendingActivity = null
        activityTracker.unbindActivity()
    }
}
