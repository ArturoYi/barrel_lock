package com.flutterbazaar.fast_lifecycle

/**
 * 原生事件发射基类：封装载荷构造与按作用域去重。
 *
 * 各平台 Tracker 通过此类发射事件，禁止在发射前翻译 rawState。
 */
internal class LifecycleEventEmitter(
    private val onEvent: (Map<String, Any?>) -> Unit,
    private val windowId: String? = null,
    private val isMainWindow: Boolean = true,
) {
    private val lastRawStateByScope = mutableMapOf<String, String>()

    fun emit(rawState: String, lifecycleScope: String) {
        if (lastRawStateByScope[lifecycleScope] == rawState) {
            return
        }
        lastRawStateByScope[lifecycleScope] = rawState
        onEvent(
            LifecycleEventPayload.build(
                rawState = rawState,
                lifecycleScope = lifecycleScope,
                windowId = windowId,
                isMainWindow = isMainWindow,
            ),
        )
    }

    fun reset() {
        lastRawStateByScope.clear()
    }
}
