package com.hulk.bazaarAndroid

import android.bluetooth.BluetoothAdapter
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import io.flutter.embedding.android.FlutterFragmentActivity

/** 监听系统蓝牙开关，会话进行中关闭蓝牙时及时 fail。 */
internal class BackupBluetoothStateMonitor(
    private val activity: FlutterFragmentActivity,
    private val mainHandler: Handler,
    private val onBluetoothDisabled: () -> Unit,
) {
    private var receiver: BroadcastReceiver? = null

    fun start() {
        stop()
        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                if (intent.action != BluetoothAdapter.ACTION_STATE_CHANGED) {
                    return
                }
                when (
                    intent.getIntExtra(
                        BluetoothAdapter.EXTRA_STATE,
                        BluetoothAdapter.ERROR,
                    )
                ) {
                    BluetoothAdapter.STATE_OFF,
                    BluetoothAdapter.STATE_TURNING_OFF,
                    -> mainHandler.post { onBluetoothDisabled() }

                    else -> Unit
                }
            }
        }
        val filter = IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            activity.registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            activity.registerReceiver(receiver, filter)
        }
    }

    fun stop() {
        val active = receiver ?: return
        try {
            activity.unregisterReceiver(active)
        } catch (_: IllegalArgumentException) {
            // already unregistered
        }
        receiver = null
    }
}

internal fun isBluetoothEnabled(adapter: BluetoothAdapter?): Boolean {
    return adapter != null && adapter.isEnabled
}
