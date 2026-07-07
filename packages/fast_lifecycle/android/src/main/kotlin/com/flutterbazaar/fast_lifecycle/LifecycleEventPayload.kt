package com.flutterbazaar.fast_lifecycle

/**
 * 跨端 EventChannel 载荷构造器（字段名与 Dart [NativePayloadKeys] 保持一致）。
 */
internal object LifecycleEventPayload {
    private const val SOURCE = "source"
    private const val RAW_STATE = "rawState"
    private const val EXTRA = "extra"
    private const val LIFECYCLE_SCOPE = "lifecycleScope"
    private const val WINDOW_ID = "windowId"
    private const val IS_MAIN_WINDOW = "isMainWindow"

    /**
     * @param rawState 系统原生原始字符串，禁止翻译或映射为其他命名
     * @param lifecycleScope 生命周期作用域，如 `process` / `activity`
     */
    fun build(
        rawState: String,
        source: String = "android",
        lifecycleScope: String? = null,
        windowId: String? = null,
        isMainWindow: Boolean = true,
    ): Map<String, Any?> {
        val extra = mutableMapOf<String, Any?>(
            IS_MAIN_WINDOW to isMainWindow,
        )
        if (lifecycleScope != null) {
            extra[LIFECYCLE_SCOPE] = lifecycleScope
        }
        if (windowId != null) {
            extra[WINDOW_ID] = windowId
        }

        return mapOf(
            SOURCE to source,
            RAW_STATE to rawState,
            EXTRA to extra,
        )
    }
}
