package com.flutterbazaar.fast_lifecycle

import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ProcessLifecycleOwner

/**
 * Android 进程级生命周期 Mixin。
 *
 * 监听 [ProcessLifecycleOwner]，rawState 使用 [androidx.lifecycle.Lifecycle.Event] 原名。
 */
internal class ProcessLifecycleTracker(
    private val emitter: LifecycleEventEmitter,
) : DefaultLifecycleObserver {

    fun start() {
        ProcessLifecycleOwner.get().lifecycle.addObserver(this)
    }

    fun stop() {
        ProcessLifecycleOwner.get().lifecycle.removeObserver(this)
    }

    override fun onCreate(owner: LifecycleOwner) = emitter.emit("ON_CREATE", SCOPE)

    override fun onStart(owner: LifecycleOwner) = emitter.emit("ON_START", SCOPE)

    override fun onResume(owner: LifecycleOwner) = emitter.emit("ON_RESUME", SCOPE)

    override fun onPause(owner: LifecycleOwner) = emitter.emit("ON_PAUSE", SCOPE)

    override fun onStop(owner: LifecycleOwner) = emitter.emit("ON_STOP", SCOPE)

    override fun onDestroy(owner: LifecycleOwner) = emitter.emit("ON_DESTROY", SCOPE)

    private companion object {
        const val SCOPE = "process"
    }
}
