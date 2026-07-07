package com.flutterbazaar.fast_lifecycle

import android.app.Activity
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner

/**
 * Android Activity 页面级生命周期 Mixin。
 *
 * 仅监听绑定的 Flutter [Activity]，rawState 使用 [androidx.lifecycle.Lifecycle.Event] 原名。
 */
internal class ActivityLifecycleTracker(
    private val emitter: LifecycleEventEmitter,
) : DefaultLifecycleObserver {

    private var boundActivity: Activity? = null

    fun bindActivity(activity: Activity) {
        unbindActivity()
        boundActivity = activity
        activity.lifecycle.addObserver(this)
    }

    fun unbindActivity() {
        boundActivity?.lifecycle?.removeObserver(this)
        boundActivity = null
    }

    override fun onCreate(owner: LifecycleOwner) {
        if (owner == boundActivity) emitter.emit("ON_CREATE", SCOPE)
    }

    override fun onStart(owner: LifecycleOwner) {
        if (owner == boundActivity) emitter.emit("ON_START", SCOPE)
    }

    override fun onResume(owner: LifecycleOwner) {
        if (owner == boundActivity) emitter.emit("ON_RESUME", SCOPE)
    }

    override fun onPause(owner: LifecycleOwner) {
        if (owner == boundActivity) emitter.emit("ON_PAUSE", SCOPE)
    }

    override fun onStop(owner: LifecycleOwner) {
        if (owner == boundActivity) emitter.emit("ON_STOP", SCOPE)
    }

    override fun onDestroy(owner: LifecycleOwner) {
        if (owner == boundActivity) {
            emitter.emit("ON_DESTROY", SCOPE)
            unbindActivity()
        }
    }

    private companion object {
        const val SCOPE = "activity"
    }
}
